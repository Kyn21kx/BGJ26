namespace BeefHush;

using Hush;
using System;

[RegisterSystem]
public class MovementSytem : GameSystem
{

	// Fixing player scale at runtime, lol
	const Hush.Vector3 PLAYER_SCALE = Constants.Vector3_ONE * 0.05f;

	private Query entityQuery;
	private Vector3 position = .();
	
	public void Init()
	{
		Console.WriteLine("Movement system was initialized!");
		QueryBuilder builder = .();
		EntityRegistry.s_PlayerTag = builder.With<PlayerTag>();
		EntityRegistry.s_Rig = builder.With<RigidBody>();
		builder.With<Controller>();
		builder.With<MovementStat>();
		
		this.entityQuery = builder.Build();

		this.entityQuery.EachEntity(scope (entityRef) => {
			LocalTransform* xform = entityRef.GetComponent<LocalTransform>();
			RigidBody* rig = entityRef.GetComponent<RigidBody>();
			*rig = .();
			xform.SetScale(PLAYER_SCALE);
			rig.aabb.pos = xform.GetPositionValue();
		});

	}

	public void OnShutdown()
	{
		Console.WriteLine("Movement system was shutdown!");
	}

	public void OnUpdate(float delta){
		this.entityQuery.Each<PlayerTag, RigidBody, Controller, MovementStat>(scope (entityRef,
			 tag, rigidBody, controller, movementStat) => {
				Vector3 movement = .();

				if(Hush.InputManager.IsKeyDown((EKeyCode)controller.up)){
					movement.z = -1;
				}
				 
				if(Hush.InputManager.IsKeyDown((EKeyCode)controller.down)){
					movement.z = 1;
				}
				 
				if(Hush.InputManager.IsKeyDown((EKeyCode)controller.left)){
					movement.x = -1;
				}
				 
				if(Hush.InputManager.IsKeyDown((EKeyCode)controller.right)){
					movement.x = 1;
				}
				 
				if(movement != Constants.Vector3_ZERO){
					movement = movement.normalized();
				}

				 rigidBody.SetVelocity(movement * movementStat.speed);
			});
	}

	public void OnFixedUpdate(float delta)
	{

	}

	public void OnRender()
	{

	}

	public void OnPreRender()
	{

	}

	public void OnPostRender()
	{

	}
}