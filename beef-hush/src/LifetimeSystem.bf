namespace BeefHush;

using Hush;
using System;

[RegisterSystem]
class LifetimeSystem : GameSystem
{
	void* m_scene;
	Query m_lifetimeObjects;
	Query m_particleQuery;

	public void Init()
	{
		this.m_scene = HushEngine.GetScene(EngineDependencies.Instance.Engine);
		QueryBuilder builder = .();
		builder.With<Lifetime>();
		this.m_lifetimeObjects = builder.Build();

		builder = .();
		builder.With<Lifetime>();
		builder.With<ParticleTag>();
		this.m_particleQuery = builder.Build();
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

		this.m_particleQuery.Each<Lifetime, LocalTransform>(scope (entityRef, lifetime, xform) => {
			if (lifetime.initialLifetime > 0f) {
				float t = lifetime.remaining / lifetime.initialLifetime;
				xform.SetScale(Constants.Vector3_ONE * t);
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
