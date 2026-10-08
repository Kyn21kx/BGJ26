namespace BeefHush;

using System;

/// Apply this to any class that implements GameSystem to register it with the engine.
[AttributeUsage(.Class)]
public struct RegisterSystemAttribute : Attribute {}

[CRepr]
public struct RegTypeInfo {
	public const int MAX_SYS_NAME = 64;
	public char8[MAX_SYS_NAME] name;
	public int32 registryIndex;
	public uint64 byteSize;
	public uint64 align;

	public this(StringView name, int32 registryIndex, uint64 byteSize, uint64 align) {
		this.name = "";
		this.registryIndex = registryIndex;
		name.CopyTo(this.name);
		this.byteSize = byteSize;
		this.align = align;
	}

}

[Reflect(.None, ReflectImplementer=.DefaultConstructor), AlwaysInclude(AssumeInstantiated=true)]
public interface GameSystem {
	public void Init();

	/// OnShutdown() is called when the system is shutting down.
	public void OnShutdown();

	/// OnRender() is called when the system should render.
	/// @param delta Time since last frame
	public void OnUpdate(float delta);

	/// OnFixedUpdate() is called when the system should update its state.
	/// @param delta Time since last fixed frame
	public void OnFixedUpdate(float delta);

	/// OnRender() is called when the system should render.
	public void OnRender();

	/// OnPreRender() is called before rendering.
	public void OnPreRender();

	/// OnPostRender() is called after rendering.
	public void OnPostRender();
}

