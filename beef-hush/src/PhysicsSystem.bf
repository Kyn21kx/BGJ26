namespace beef_hush;
namespace BeefHush;

using System;
using Hush;

[RegisterSystem]
public class PhysicsSystem : GameSystem{
	private Query entityQuery;
	private Hush.Vector3 position = .();

	public	void Init(){
		Console.WriteLine("Physics system was initialized!");
		QueryBuilder builder = .();
		builder.With<RigidBody>();
		builder.With<WorldTransform>();
		this.entityQuery = builder.Build();
	}

	public void OnShutdown(){
		//NOTE(cris):Aqui el sistema de fisicas deberia hacer algo?
		Console.WriteLine("Physics system was shutdown!");
	}
	public void OnUpdate(float delta){
		this.entityQuery.Each<RigidBody, WorldTransform>(scope (entityRef, rig, xformRaw) => {
			if (!rig.dynamic) {
				return;
			}
			Console.WriteLine(scope $"Matched on entity: {entityRef.Id}");
			//NOTE(cris): Version hecha por claudio
			rig.vel += rig.acc * delta;

			rig.aabb.pos += rig.vel * delta;
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
