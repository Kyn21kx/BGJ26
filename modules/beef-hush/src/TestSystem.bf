namespace BeefHush;

using System;
using Hush;

[RegisterSystem]
public class SmallSystem : GameSystem {
	private Query m_entityQuery;
	// Fixing player scale at runtime, lol
	const Hush.Vector3 PLAYER_SCALE = Constants.Vector3_ONE * 0.001f;

	public void Init() {
		Console.WriteLine("Small System was initialized!");
		QueryBuilder builder = .();
		builder.With<LocalTransform>();
		builder.With<PlayerTag>();
		builder.With<Controller>();
		this.m_entityQuery = builder.Build();

		const StringView renderSystemName = "RenderingSystem";
		void* scene = HushEngine.GetScene(EngineDependencies.Instance.Engine);
		let renderingSystem = BeefHush.Entity(Scene.CreateEntityWithKey(scene, (char8*)renderSystemName.ToRawData().Ptr, (uint64)renderSystemName.Length));

		// TODO: Use the entity registry to fetch this, bc this performs a string hash
		let handle = renderingSystem.GetComponent<RenderingSystemAPI>();
		StringView path = "res://FireBallPURPLE.glb";
		uint64 rootEntId = handle.instantiateMeshEntities(&(path[0]), handle.instance);
	}

	/// OnShutdown() is called when the system is shutting down.
	public void OnShutdown() {
		Console.WriteLine("Small System was shutdown!");
	}

	/// OnRender() is called when the system should render.
	/// @param delta Time since last frame
	public void OnUpdate(float delta) {
		this.m_entityQuery.Each<LocalTransform, PlayerTag, Controller>(scope (entityRef, rawXform, tag, controller) => {
			// Downcast
			Hush.Transform* xform = (Hush.Transform*)rawXform;
			//xform.SetScale(PLAYER_SCALE);
			Vector3 pos = xform.GetPositionValue();
			// let controller = entityRef.GetComponent<Controller>();
			if (Hush.InputManager.IsKeyDown((EKeyCode)controller.up)) {
				pos.z -= delta * 2f;
			}
			if (Hush.InputManager.IsKeyDown((EKeyCode)controller.down)) {
				pos.z += delta * 2f;
			}
			if (Hush.InputManager.IsKeyDown((EKeyCode)controller.left)) {
				pos.x -= delta * 2f;
			}
			if (Hush.InputManager.IsKeyDown((EKeyCode)controller.right)) {
				pos.x += delta * 2f;
			}
			xform.SetPosition(pos);
		});
	}

	/// OnFixedUpdate() is called when the system should update its state.
	/// @param delta Time since last fixed frame
	public void OnFixedUpdate(float delta) {
		
	}

	/// OnRender() is called when the system should render.
	public void OnRender() {
		
	}

	/// OnPreRender() is called before rendering.
	public void OnPreRender() {
		
	}

	/// OnPostRender() is called after rendering.
	public void OnPostRender() {
		
	}
	
}

