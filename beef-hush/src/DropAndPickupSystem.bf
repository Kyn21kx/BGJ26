namespace BeefHush;

using Hush;
using System;

public struct DropArgs {
	public uint64 sourceId;
	public Vector3 position;
	public float dropChance;

	public this(uint64 sourceId, Vector3 position, float dropChance) {
		this.sourceId   = sourceId;
		this.position   = position;
		this.dropChance = dropChance;
	}
}

public struct PickupArgs {
	public uint64 pickupId;
	public uint64 playerId;
	public Pickup* pickup;

	public this(uint64 pickupId, uint64 playerId, Pickup* pickup) {
		this.pickupId = pickupId;
		this.playerId = playerId;
		this.pickup   = pickup;
	}
}

[RegisterSystem]
public class DropAndPickupSystem : GameSystem
{
	public static Event<delegate void(DropArgs args)>   OnDropEvent   = default;
	public static Event<delegate void(PickupArgs args)> OnPickupEvent = default;

	// Call from any system when a CanDrop entity should attempt a drop (e.g. on death).
	public static void TriggerDrop(BeefHush.Entity entity) {
		RigidBody* rig     = entity.GetComponent<RigidBody>();
		CanDrop*   canDrop = entity.GetComponent<CanDrop>();
		if (rig == null || canDrop == null) return;
		OnDropEvent(.(entity.Id, rig.aabb.pos, canDrop.dropChance));
	}

	public void Init()
	{
		PhysicsSystem.OnCollisionEvent.Add(new (a, b) => {
			void* scene = HushEngine.GetScene(EngineDependencies.Instance.Engine);
			BeefHush.Entity entA = .(Scene.EntityFromIdUnchecked(scene, a.id));
			BeefHush.Entity entB = .(Scene.EntityFromIdUnchecked(scene, b.id));

			// Determine which side is the pickup and which is the player
			Pickup* pickup    = entA.GetComponent<Pickup>();
			uint64  pickupId  = a.id;
			uint64  playerId  = b.id;
			BeefHush.Entity playerEnt = entB;

			if (pickup == null) {
				pickup    = entB.GetComponent<Pickup>();
				pickupId  = b.id;
				playerId  = a.id;
				playerEnt = entA;
			}

			if (pickup == null) return;
			if (playerEnt.GetComponent<PlayerTag>() == null) return;

			OnPickupEvent(.(pickupId, playerId, pickup));
		});
	}

	public void OnShutdown() {}
	public void OnUpdate(float delta) {}
	public void OnFixedUpdate(float delta) {}
	public void OnRender() {}
	public void OnPreRender() {}
	public void OnPostRender() {}
}
