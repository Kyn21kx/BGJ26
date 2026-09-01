namespace BeefHush;

using Hush;
using System;
using System.Collections;

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
		builder.With<LocalTransform>();
		builder.With<ParticleTag>();
		this.m_particleQuery = builder.Build();
	}

	public void OnShutdown()
	{

	}

	public void OnUpdate(float delta)
	{
		// Collect expired entities first: destroying inside the Each swap-removes
		// rows from the table mid-iteration and shifts the remaining rows.
		List<Hush.Entity> expiredEntities = scope List<Hush.Entity>();

		this.m_lifetimeObjects.Each<Lifetime>(scope (entityRef, lifetime) => {
			lifetime.remaining -= delta;
			if (lifetime.remaining <= 0f) {
				var entityRef; // UX: Stupid copy
				expiredEntities.Add(*entityRef.InnerEntity());
			}
		});

		for (var entity in expiredEntities) {
			Scene.DestroyEntity(this.m_scene, &entity);
		}

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
