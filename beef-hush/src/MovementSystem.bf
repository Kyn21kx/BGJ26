namespace BeefHush;

using Hush;
using System;

[RegisterSystem]
public class MovementSsytem : GameSystem
{

	// Fixing player scale at runtime, lol
	const Hush.Vector3 PLAYER_SCALE = Constants.Vector3_ONE * 0.05f;

	private Query entityQuery;
	private Vector3 position = .();
	
	public void Init()
	{
		Console.WriteLine("Movement system was initialized!");
		QueryBuilder builder = .();
		builder.With<PlayerTag>();
		builder.With<RigidBody>();
		builder.With<Controller>();
		builder.With<MovementStat>();
		builder.With<IsStunned>();
		this.entityQuery = builder.Build();

		this.entityQuery.EachEntity(scope (entityRef) => {
			if (entityRef.GetComponent<IsStunned>() == null) {
				entityRef.AddComponent<IsStunned>();
			}

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
		//Query.Each<>() Overload to support 5 components
		this.entityQuery.Each<PlayerTag, RigidBody, Controller, MovementStat, IsStunned>(scope (entityRef,
			 tag, rigidBody, controller, movementStat, stun) => {
				 //early return and input is ignored
				if(stun.currentlyStunned){
					rigidBody.SetVelocity(Constants.Vector3_ZERO);
					return;
				}

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



	public void checkStunStatus(){

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