namespace BeefHush;

using System;
using System.Diagnostics;
using System.Collections;
using Hush;

// Utility
public struct ColliderArgs {
	public uint64 id;
	public RigidBody* rig;
	public Collider* collider;

	public this(uint64 id, RigidBody* rig, Collider* collider) {
		this.id = id;
		this.rig = rig;
		this.collider = collider;
	}
}

[RegisterSystem]
public class PhysicsSystem : GameSystem{
	private Query entityQuery;
	private Query m_collidersQuery;
	private SpatialGrid m_spatialGrid;
	private Hush.Vector3 position = .();
	private void* m_scene;
	private uint64 m_rigTerm;
	private uint64 m_colliderTerm;

	public static Event<delegate void(ColliderArgs a, ColliderArgs b)> OnCollisionEvent = default;

	public void Init() {
		Console.WriteLine("Physics system was initialized!");
		QueryBuilder builder = .();
		this.m_rigTerm = builder.With<RigidBody>();
		builder.With<WorldTransform>();
		builder.With<LocalTransform>();
		this.entityQuery = builder.Build();

		this.entityQuery.Each<RigidBody, WorldTransform, LocalTransform>(scope (entityRef, rig, world, local) => {
			rig.aabb.pos = local.GetPositionValue();
		});

		this.m_scene = HushEngine.GetScene(EngineDependencies.Instance.Engine);
		Scene.AddComponentObserverRaw(this.m_scene, this.m_rigTerm, sizeof(RigidBody), EComponentObserverType.EComponentObserverType_Add, (id, data) => {
			// Set the rig's AABB to be the scale
			var rig = (RigidBody*)data;
			rig.physicsImpulse = .();
			void* scene = HushEngine.GetScene(EngineDependencies.Instance.Engine);
			BeefHush.Entity ent = .(Scene.EntityFromIdUnchecked(scene, id));
			// Local xform
			LocalTransform* xform = ent.GetComponent<LocalTransform>();
			BeefHush.MeshReference* meshRef = ent.GetComponent<BeefHush.MeshReference>();
			Debug.Assert(meshRef != null, "There was no mesh ref attached to this entity, a Mesh must precede the rigidbody!");
			meshRef.CalculateBounds(&(rig.aabb.pos), &(rig.aabb.size));
			rig.aabb.size *= xform.GetScale();
			rig.aabb.pos = xform.GetPositionValue();
		});


		builder = .();
		builder.With<RigidBody>();
		this.m_colliderTerm = builder.With<Collider>();
		this.m_collidersQuery = builder.Build();
		this.m_spatialGrid = .();
		this.m_spatialGrid.Init();

		PhysicsSystem.OnCollisionEvent.Add(new (a, b) => {
			ColliderArgs* wall = &b;
			ColliderArgs* other = &a;
			if (a.collider.identifierTag == (int32)EEntityTag.Wall) {
				wall = &a;
				other = &b;
			}
			else if (b.collider.identifierTag != (int32)EEntityTag.Wall) {
				return;
			}

			// Snap entity to wall surface
			Vector3 mtv = other.rig.aabb.CalcMTV(wall.rig.aabb);
			other.rig.aabb.pos += mtv;

			// Impulse to cancel the component of vel projecting into the wall next frame
			Vector3 wallNormal = mtv.normalized();
			float velIntoWall = other.rig.vel.dot(wallNormal);
			if (velIntoWall < 0f)
				other.rig.physicsImpulse -= wallNormal * velIntoWall;
		});

		builder = .();
		builder.With<BeefHush.MeshReference>();
		builder.With<RigidBody>();
		builder.With<Collider>();
		builder.With<LocalTransform>();
		builder.With<WorldTransform>();
		Query pendingBodiesQ = builder.Build();
		pendingBodiesQ.Each<BeefHush.MeshReference, RigidBody, Collider, LocalTransform, WorldTransform>(scope (entityRef, mesh, rig, coll, localXform, globalXform) => {
		   	// Local xform
			mesh.CalculateBounds(&(rig.aabb.pos), &(rig.aabb.size));
			rig.physicsImpulse = .();
			rig.aabb.pos = localXform.GetPositionValue();
			rig.aabb.size *= globalXform.GetScale();
			rig.aabb.size *= localXform.GetScale();
		});
	}

	public void OnShutdown(){
		//NOTE(cris):Aqui el sistema de fisicas deberia hacer algo?
		Console.WriteLine("Physics system was shutdown!");
		this.m_spatialGrid.Dispose();
	}

	public void CheckCollisions(RigidBody* rig, Collider* coll, uint64 id) {
		this.m_spatialGrid.EachNeighborAt(rig.aabb.pos, 1, id, scope (otherId) => {
			// A depth of 2 neighbors will check if their AABB collides
			BeefHush.Entity other = .(Scene.EntityFromIdUnchecked(this.m_scene, otherId));
			RigidBody* otherRig = other.GetComponent<RigidBody>(this.m_rigTerm);
			Collider* otherColl = other.GetComponent<Collider>(this.m_colliderTerm);
			if (otherRig == null || !rig.aabb.intersects(otherRig.aabb)) {
				return;
			}
			// Emit collision event
			OnCollisionEvent(.(id, rig, coll), .(otherId, otherRig, otherColl));
		});
	}
	
	public void OnUpdate(float delta) {
		this.m_spatialGrid.ClearNoFree();

		// physicsImpulse is a velocity correction accumulated last frame; apply it alongside vel
		this.entityQuery.Each<RigidBody, WorldTransform, LocalTransform>(scope (entityRef, rig, xformRaw, localXform) => {
			if (!rig.dynamic) return;

			Vector3 effectiveVel = rig.vel + rig.physicsImpulse;
			rig.physicsImpulse = .();
			effectiveVel += rig.acc * delta;

			rig.aabb.pos += effectiveVel * delta;
			xformRaw.SetPosition(rig.aabb.pos);
			Vector3 euler = localXform.GetEulerAngles();
			euler += rig.angularVel;
			xformRaw.SetEulerAngles(&euler);
		});

		// Insertion loop
		this.m_collidersQuery.Each<RigidBody, Collider>(scope (entityRef, rig, coll) => {
			this.m_spatialGrid.RegisterEntityAt(entityRef.Id, rig.aabb.pos);
		});

		// Check loop — collision handler corrects aabb.pos and accumulates physicsImpulse
		this.m_collidersQuery.Each<RigidBody, Collider>(scope (entityRef, rig, coll) => {
			this.CheckCollisions(rig, coll, entityRef.Id);
		});

		// Sync collision-corrected positions to transforms before render
		this.entityQuery.Each<RigidBody, WorldTransform, LocalTransform>(scope (entityRef, rig, xformRaw, localXform) => {
			if (!rig.dynamic) return;
			xformRaw.SetPosition(rig.aabb.pos);
		});
	}

	public void OnFixedUpdate(float delta) {

	}

	public void OnRender(){

	}

	
	public void OnPreRender(){

	}

	
	public void OnPostRender(){

	}


}
