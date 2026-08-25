namespace BeefHush;

using Hush;
using System;

[RegisterSystem]
class LifetimeSystem : GameSystem
{
	void* m_scene;
	Query m_lifetimeObjects;

	public void Init()
	{
		this.m_scene = HushEngine.GetScene(EngineDependencies.Instance.Engine);
		QueryBuilder builder = .();
		builder.With<Lifetime>();
		this.m_lifetimeObjects = builder.Build();
	}

	public void OnShutdown()
	{

	}

	public void OnUpdate(float delta)
	{
		this.m_lifetimeObjects.Each<Lifetime>(scope (entityRef, lifetime) => {
			lifetime.remaining -= delta;
			if (lifetime.remaining <= 0f) {
				var entityRef; // UX: Stupid copy
				Scene.DestroyEntity(this.m_scene, entityRef.InnerEntity());
			}
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