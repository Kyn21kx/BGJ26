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
		this.entityQuery.Each<RigidBody, WorldTransform>(scope (entityRef) => {
			RigidBody* rig = entityRef.GetComponent<RigidBody>();
			Hush.Transform* xform = entityRef.GetComponent<WorldTransform>();

			if (!rig.dynamic) {
				return;
			}
			//NOTE(cris): Version hecha por claudio
			rig.vel += rig.acc * delta;


			Hush.Vector3 p = xform.GetPositionValue();
			p.x += rig.vel.x * delta;
			p.y += rig.vel.y * delta;
			p.z += rig.vel.z * delta;


			xform.SetPosition(p);
			rig.aabb.pos = .(p.x, p.y, p.z);

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