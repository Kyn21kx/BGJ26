namespace BeefHush;

using Hush;
using System;
using System.Collections;

public struct DropArgs {
	public uint64 sourceId;
	public Vector3 position;
	public float dropChance;
	
	public this(uint64 sourceId, Vector3 position, float dropChance ) {
		this.sourceId   = sourceId;
		this.position   = position;
		this.dropChance = dropChance;
	}
}

public struct PickupArgs {
	public uint64 pickupId;
	public uint64 playerId;
	public PickUp* pickup;

	public this(uint64 pickupId, uint64 playerId, PickUp* pickup) {
		this.pickupId = pickupId;
		this.playerId = playerId;
		this.pickup  = pickup;
	}
}

public struct SpawnArgs {
	public uint64 sourceId;
	public Vector3 position;

	public this(uint64 sourceId, Vector3 position) {
		this.sourceId = sourceId;
		this.position = position;
	}
}

[RegisterSystem]
public class DropAndPickupSystem : GameSystem
{
	public static Event<delegate void(DropArgs args)>   OnDropEvent   = default;
	public static Event<delegate void(PickupArgs args)> OnPickupEvent = default;
	public static Event<delegate void()				  > OnPickupRangeEvent = default;


	private const uint8 MAX_PICKUP_COUNT = 2;
	private const PickUp[MAX_PICKUP_COUNT] AvailablePickupsMesh = .(
	.("res://Box.glb", 1.0f, 4f),
	.("res://Kalaka MODEL.glb", 0.1f, 4f)
);

	Query m_playersQuery;
	List<uint64> m_entitiesToDestroy;
	List<SpawnArgs> m_pendingSpawns;

	void* m_scene;
	RenderingSystemAPI m_renderAPI;
	private Random m_random;
	private bool m_subscribedDeath = false;

	public uint32 GetRandomPickupIndex()
	{
		return (uint32)m_random.Next(0, MAX_PICKUP_COUNT);
	}

	private void SpawnPickup(uint64 sourceId, Vector3 position){

		uint32 index  = GetRandomPickupIndex();

		PickUp definition = AvailablePickupsMesh[index];
	
		uint64 rootEntId = m_renderAPI.instantiateMeshEntities((char8*)definition.meshPath.Ptr,m_renderAPI.instance);

		BeefHush.Entity pickupEnt = .(Scene.EntityFromIdUnchecked(m_scene, rootEntId));

		LocalTransform* xform = pickupEnt.GetComponent<LocalTransform>();

		
		if (xform != null){
			xform.SetScale(Constants.Vector3_ONE * definition.scale);
			xform.SetPosition(position);
		}

		PickUp* pickup = pickupEnt.AddComponent<PickUp>();
		pickup.meshPath = definition.meshPath;
		pickup.scale = definition.scale;

	
		Spell* spell = pickupEnt.AddComponent<Spell>();
		setSpell((EMesh)index, spell);

		Collider* collider = pickupEnt.AddComponent<Collider>();
		collider.identifierTag = (int32)EEntityTag.PickUp;

		RigidBody* rig = pickupEnt.AddComponent<RigidBody>();
		*rig = .();
		rig.aabb.pos = position;
		rig.aabb.size = xform.GetScale();
	}


	public void setSpell(EMesh mesh, Spell* spell){

		switch (mesh)
		{
		case EMesh.Box:
			*spell = Spell.makeBox();
		case EMesh.Kalaka:
		    *spell = Spell.makeKalaka();
		default:

		}
	}

	public bool RollChance(float chance){
		float roll = (float)this.m_random.NextDouble();

		if(roll < chance){
			Console.WriteLine("Spawn pickup!");
			return true;
		}
		Console.WriteLine("No pickup :(");
		return false;
	}
	
	public bool TriggerDrop(uint64 id, RigidBody* rig, CanDrop* canDrop) {

		if (rig == null || canDrop == null) { return false; }

		if(!this.RollChance(canDrop.dropChance)){ return false; }
		
		return true;
	}

	public void Init()
	{
		this.m_scene = HushEngine.GetScene(EngineDependencies.Instance.Engine);
		m_random = new .();

		this.m_entitiesToDestroy = new .(64);
		this.m_pendingSpawns = new .(64);

		const StringView renderSystemName = "RenderingSystem";
		BeefHush.Entity renderingSystem = .(Scene.CreateEntityWithKey(this.m_scene, (char8*)renderSystemName.ToRawData().Ptr, (uint64)renderSystemName.Length));
		this.m_renderAPI = *renderingSystem.GetComponent<RenderingSystemAPI>();

		QueryBuilder builder = .();
		builder.With<PlayerTag>();
		builder.With<RigidBody>();
		builder.With<Controller>();
		builder.With<Inventory>();
		this.m_playersQuery = builder.Build();

		if (!m_subscribedDeath) {
		    m_subscribedDeath = true;

		HealthSystem.OnDeathEvent.Add(new (entityRef) => {
			Console.WriteLine("Listening death event");
			RigidBody* rig = entityRef.GetComponent<RigidBody>();
			CanDrop* canDrop = entityRef.GetComponent<CanDrop>();

			if(this.TriggerDrop(entityRef.Id, rig, canDrop)){
				Console.WriteLine("Drop succeed");
				OnDropEvent(.(entityRef.Id, rig.aabb.pos, canDrop.dropChance));
				this.m_pendingSpawns.Add(.(entityRef.Id, rig.aabb.pos));
				}
			});
		}

	}
	public void ProcessPickup(uint64 pickupId, uint64 playerId, PickUp* pickup, Inventory* inv){
		InventorySystem.AddToSlot(inv, pickup.toSpell());
		if(!this.m_entitiesToDestroy.Contains(pickupId)){
			this.m_entitiesToDestroy.Add(pickupId);
		}
	}

	public void OnShutdown() {
		delete m_random;
		delete m_entitiesToDestroy;
		delete m_pendingSpawns;
	}

	public void OnUpdate(float delta){
		for (SpawnArgs spawn in this.m_pendingSpawns) {
			SpawnPickup(spawn.sourceId, spawn.position);
		}
		this.m_pendingSpawns.Clear();

		this.m_playersQuery.Each<PlayerTag, RigidBody, Controller, Inventory>(scope (entityRef, tag, rig, controller, inv) => {
		    if (InputManager.IsKeyDownThisFrame((EKeyCode)controller.pickup)) {
				float minDistSqr = float.MaxValue;
				uint64 bestPickupId = 0;
				PickUp* bestPickup = null;

				PhysicsSystem.s_SpatialGrid.EachNeighborAt(rig.aabb.pos, 2, entityRef.Id, scope [&](neighborId) => {
				    let neighborEnt = BeefHush.Entity(Scene.EntityFromIdUnchecked(this.m_scene, neighborId));
				    let pickup = neighborEnt.GetComponent<PickUp>();
				    if (pickup == null) return;
				    float distSqr = (rig.aabb.pos - neighborEnt.GetComponent<RigidBody>().aabb.pos).length_squared();
				    if (distSqr < minDistSqr) {
				        minDistSqr = distSqr;
				        bestPickupId = neighborId;
				        bestPickup = pickup;
				    }
				});

				if (bestPickupId != 0){
					 ProcessPickup(bestPickupId, entityRef.Id, bestPickup, inv);
				}
		    }
		});

	}
	public void OnFixedUpdate(float delta) {}
	public void OnRender() {}
	public void OnPreRender() {}

	public void OnPostRender() {
		for (uint64 id in this.m_entitiesToDestroy) {
        let e = Scene.EntityFromIdUnchecked(this.m_scene, id);
        Scene.DestroyEntity(this.m_scene, &e);
		Console.WriteLine("Entity Destroyed");
    }
    this.m_entitiesToDestroy.Clear();
}

}
