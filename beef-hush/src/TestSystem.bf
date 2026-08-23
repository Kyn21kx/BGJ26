namespace BeefHush;

using System;

[RegisterSystem]
public class SmallSystem : GameSystem {
	private Query m_entityQuery;
	private Hush.Vector3 m_position = .();

	public void Init() {
		Console.WriteLine("Small System was initialized!");
		QueryBuilder builder = .();
		builder.With<WorldTransform>();
		builder.With<PlayerTag>();
		this.m_entityQuery = builder.Build();
	}

	/// OnShutdown() is called when the system is shutting down.
	public void OnShutdown() {
		Console.WriteLine("Small System was shutdown!");
	}

	/// OnRender() is called when the system should render.
	/// @param delta Time since last frame
	public void OnUpdate(float delta) {
		this.m_entityQuery.Each(scope (entityRef) => {
			// Downcast
			Hush.Transform* xform = entityRef.GetComponent<WorldTransform>();
			if (Hush.InputManager.IsKeyDown(Hush.EKeyCode.EKeyCode_UP)) {
				this.m_position.z -= delta * 2f;
			}
			if (Hush.InputManager.IsKeyDown(Hush.EKeyCode.EKeyCode_DOWN)) {
				this.m_position.z += delta * 2f;
			}
			if (Hush.InputManager.IsKeyDown(Hush.EKeyCode.EKeyCode_LEFT)) {
				this.m_position.x -= delta * 2f;
			}
			if (Hush.InputManager.IsKeyDown(Hush.EKeyCode.EKeyCode_RIGHT)) {
				this.m_position.x += delta * 2f;
			}
			xform.SetPosition(this.m_position);
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

