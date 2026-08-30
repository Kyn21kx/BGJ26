namespace BeefHush;

using Hush;
using System;
using System.Collections;

public struct DropArgs {
	public uint64 sourceId;
	public Vector3 position;
	public uint32 itemDropped;
	public float dropChance;
	
	public this(uint64 sourceId, Vector3 position, uint32 meshIndex, float dropChance ) {
		this.sourceId   = sourceId;
		this.position   = position;
		this.itemDropped   = meshIndex;
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

[RegisterSystem]
public class DropAndPickupSystem : GameSystem
{

	public static Event<delegate void(DropArgs args)>   OnDropEvent   = default;
	public static Event<delegate void(PickupArgs args)> OnPickupEvent = default;
	
	private const uint8 MAX_PICKUP_COUNT = 2;
	private const PickUp[MAX_PICKUP_COUNT] AvailablePickups = .(
	.("res://Box.glb", 1.0f),
	.("res://Kalaka MODEL.glb", 0.1f)
);

	Query m_droppersQuery;
	List<uint64> m_entitiesToDestroy;
	void* m_scene;
	RenderingSystemAPI m_renderAPI;
	private BeefHush.Entity m_renderingSystem;
	private BeefHush.Entity [MAX_PICKUP_COUNT] m_pickupsMeshRef;
	private Random m_random;
	public float timer;

	public uint32 GetRandomPickupIndex()
	{
		return (uint32)m_random.Next(0, MAX_PICKUP_COUNT);
	}

	// Call from any system when a CanDrop entity should attempt a drop (e.g. on death).
	public void TriggerDrop(BeefHush.Entity entity) {
		RigidBody* rig     = entity.GetComponent<RigidBody>();
		CanDrop*   canDrop = entity.GetComponent<CanDrop>();
		uint32 index = this.GetRandomPickupIndex();
	
		if (rig == null || canDrop == null) return;
		OnDropEvent(.(entity.Id, rig.aabb.pos, index, canDrop.dropChance));
	}


	// Instantiates a pickup entity with a mesh + AABB at the given position.
	private void SpawnPickup(uint64 sourceId, Vector3 position, uint32 index,float dropChance){

		PickUp definition = AvailablePickups[index];

		uint64 rootEntId = m_renderAPI.instantiateMeshEntities(
			(char8*)definition.meshPath.Ptr,
			m_renderAPI.instance
		);

		BeefHush.Entity pickupEnt =
			.(Scene.EntityFromIdUnchecked(m_scene, rootEntId));

		LocalTransform* xform =
			pickupEnt.GetComponent<LocalTransform>();

		
		if (xform != null){
			xform.SetScale(Constants.Vector3_ONE * definition.scale);
			xform.SetPosition(position);
	}
		PickUp* pickup = pickupEnt.AddComponent<PickUp>();
		pickup.meshPath = definition.meshPath;
		pickup.scale = definition.scale;

		Collider* collider = pickupEnt.AddComponent<Collider>();
		collider.identifierTag = (int32)EEntityTag.PickUp;

		RigidBody* rig = pickupEnt.AddComponent<RigidBody>();
		//*rig = .();
		rig.aabb.pos = position;

		OnDropEvent(.(sourceId, position, index, dropChance));
	}

	public void InitializePickupsMesh(){
		const StringView renderSystemName = "RenderingSystem";
		this.m_renderingSystem = BeefHush.Entity(Scene.CreateEntityWithKey(this.m_scene,(char8*)renderSystemName.ToRawData().Ptr, (uint64)renderSystemName.Length));

		let handle = this.m_renderingSystem.GetComponent<RenderingSystemAPI>();

		for(uint8 index = 0; index < MAX_PICKUP_COUNT; index++){
			uint64 rootEntId = handle.instantiateMeshEntities(&(AvailablePickups[index].meshPath.Ptr[0]), handle.instance);
			this.m_pickupsMeshRef[index] = .(Scene.EntityFromIdUnchecked(this.m_scene, rootEntId));
			LocalTransform* localXform = this.m_pickupsMeshRef[index].AddComponent<LocalTransform>();
			//hack to keep the reference
			localXform.SetScale(Constants.Vector3_ONE * Constants.EPSILON);
		}
	}

	public void Init()
	{
		this.timer = 0f;
		this.m_scene = HushEngine.GetScene(EngineDependencies.Instance.Engine);
		m_random = new .();

		this.m_entitiesToDestroy = new .(32);

		const StringView renderSystemName = "RenderingSystem";
		BeefHush.Entity renderingSystem = .(Scene.CreateEntityWithKey(this.m_scene, (char8*)renderSystemName.ToRawData().Ptr, (uint64)renderSystemName.Length));
		this.m_renderAPI = *renderingSystem.GetComponent<RenderingSystemAPI>();

		QueryBuilder builder = .();
		builder.With<CanDrop>();
		builder.With<RigidBody>();
		this.m_droppersQuery = builder.Build();
	//	this.InitializePickupsMesh();

		PhysicsSystem.OnCollisionEvent.Add(new (a, b) => {
			
			void* scene = HushEngine.GetScene(EngineDependencies.Instance.Engine);
			BeefHush.Entity entA = .(Scene.EntityFromIdUnchecked(scene, a.id));
			BeefHush.Entity entB = .(Scene.EntityFromIdUnchecked(scene, b.id));

			// Determine which side is the pickup and which is the player
			PickUp* pickup    = entA.GetComponent<PickUp>();
			uint64  pickupId  = a.id;
			uint64  playerId  = b.id;
			BeefHush.Entity playerEnt = entB;

			if (pickup == null) {
				pickup    = entB.GetComponent<PickUp>();
				pickupId  = b.id;
				playerId  = a.id;
				playerEnt = entA;
			}

			if (pickup == null) return;

			if (playerEnt.GetComponent<PlayerTag>() == null) return;
			
			
			this.m_entitiesToDestroy.Add(pickupId);
			OnPickupEvent(.(pickupId, playerId, pickup));
		});
	}



	public void OnShutdown() {
		delete m_random;
		for(uint8 index = 0; index < MAX_PICKUP_COUNT; index++ ){
			Scene.DestroyEntity(this.m_scene, this.m_pickupsMeshRef[index].InnerEntity());
		}
		this.m_entitiesToDestroy.Clear();
	}

	public void OnUpdate(float delta)
	{
		this.timer += delta;

		if(this.timer > 15f){
			this.timer = 0f;
			
			this.m_droppersQuery.Each<CanDrop, RigidBody>(scope (entityRef, canDrop, rig) => {

				uint32 index = this.GetRandomPickupIndex();
				this.SpawnPickup(entityRef.Id, rig.aabb.pos, index, canDrop.dropChance);
			});
		}

	}


	public void OnFixedUpdate(float delta) {}
	public void OnRender() {}
	public void OnPreRender() {}
	public void OnPostRender() {
		for (uint64 id in this.m_entitiesToDestroy) {
        let e = Scene.EntityFromIdUnchecked(this.m_scene, id);
        Scene.DestroyEntity(this.m_scene, &e);
    }
    this.m_entitiesToDestroy.Clear();
}
}