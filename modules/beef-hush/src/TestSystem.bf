namespace BeefHush;

using System;
using Hush;

[RegisterSystem]
public class SmallSystem : GameSystem {
	private Query m_entityQuery;
	// Fixing player scale at runtime, lol
	const Hush.Vector3 PLAYER_SCALE = Constants.Vector3_ONE * 0.001f;

	public void Init() {
		Console.WriteLine("Hello from Init!");
	}

	/// OnShutdown() is called when the system is shutting down.
	public void OnShutdown() {
		Console.WriteLine("Small System was shutdown!");
	}

	/// OnRender() is called when the system should render.
	/// @param delta Time since last frame
	public void OnUpdate(float delta) {
		Console.WriteLine(scope $"Hello from Update with delta: {delta}!");
	}

	/// OnFixedUpdate() is called when the system should update its state.
	/// @param delta Time since last fixed frame
	public void OnFixedUpdate(float delta) {
		Console.WriteLine(scope $"Hello from FixedUpdate with delta: {delta}!");
	}

	/// OnRender() is called when the system should render.
	public void OnRender() {
		Console.WriteLine("Hello from Render!");
	}

	/// OnPreRender() is called before rendering.
	public void OnPreRender() {
		Console.WriteLine("Hello from PreRender!");
	}

	/// OnPostRender() is called after rendering.
	public void OnPostRender() {
		Console.WriteLine("Hello from PostRender!");
	}
	
}

