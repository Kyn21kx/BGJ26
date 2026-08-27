namespace BeefHush;

using System;
using Hush;

[RegisterSystem]
public class PhysicsSystem : GameSystem{
	private Query entityQuery;
	private Query m_collidersQuery;
	private SpatialGrid m_spatialGrid;
	private Hush.Vector3 position = .();

	public	void Init(){
		Console.WriteLine("Physics system was initialized!");
		QueryBuilder builder = .();
		builder.With<RigidBody>();
		builder.With<WorldTransform>();
		builder.With<LocalTransform>();
		this.entityQuery = builder.Build();

		builder = .();
		builder.With<RigidBody>();
		builder.With<Collider>();
		this.m_collidersQuery = builder.Build();
		this.m_spatialGrid = .();
		this.m_spatialGrid.Init();
	}

	public void OnShutdown(){
		//NOTE(cris):Aqui el sistema de fisicas deberia hacer algo?
		Console.WriteLine("Physics system was shutdown!");
		this.m_spatialGrid.Dispose();
	}
	public void OnUpdate(float delta) {
		this.m_spatialGrid.ClearNoFree();
		this.entityQuery.Each<RigidBody, WorldTransform, LocalTransform>(scope (entityRef, rig, xformRaw, localXform) => {
			if (!rig.dynamic) {
				return;
			}
			//NOTE(cris): Version hecha por claudio
			rig.vel += rig.acc * delta;

			rig.aabb.pos += rig.vel * delta;
			xformRaw.SetPosition(rig.aabb.pos);
			Vector3 euler = localXform.GetEulerAngles();
			euler += rig.angularVel;
			xformRaw.SetEulerAngles(&euler);
			// TODO: Do angular rotation
		});
		this.m_collidersQuery.Each<RigidBody, Collider>(scope (entityRef, rig, coll) => {
			// Register the entity at the current position
			this.m_spatialGrid.RegisterEntityAt(entityRef.Id, rig.aabb.pos);

			// Any entity is only ever checking their immediate neighbors for collisions
			
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
