namespace BeefHush;

using Hush;
using System;

[RegisterSystem]
class LifetimeSystem : GameSystem
{
	void* m_scene;
	Query m_spellObjects;
	Query m_particleObjects;
	Query m_stunnedObjects;

	public void Init()
	{
		this.m_scene = HushEngine.GetScene(EngineDependencies.Instance.Engine);
		QueryBuilder builder = .();
		builder.With<Lifetime>();
		builder.With<Spell>();
		// Only entities explicitly marked to expire on their Lifetime running out
		// get destroyed (e.g. fired projectiles). Entities that carry a Lifetime for
		// other reasons (like a stunned player's stun timer) are NOT destroyed.
		//builder.With<DestroyOnExpiry>();
		this.m_spellObjects= builder.Build();

		builder = .();
		builder.With<Lifetime>();
		builder.With<ParticleTag>();
		this.m_particleObjects = builder.Build();

		builder = .();
		builder.With<Lifetime>();
		builder.With<IsStunned>();
		this.m_stunnedObjects = builder.Build();

	}

	public void OnShutdown()
	{

	}

	public void OnUpdate(float delta)
	{
		this.m_spellObjects.Each<Lifetime, Spell>(scope (entityRef, lifetime, spell) => {
			lifetime.remaining -= delta;
			if (lifetime.remaining <= 0f) {
				var entityRef; // UX: Stupid copy
				Scene.DestroyEntity(this.m_scene, entityRef.InnerEntity());
			}
		});

		this.m_particleObjects.Each<Lifetime, LocalTransform>(scope (entityRef, lifetime, xform) => {
			lifetime.remaining -= delta;
			if (lifetime.initialLifetime > 0f) {
				float t = lifetime.remaining / lifetime.initialLifetime;
				xform.SetScale(Constants.Vector3_ONE * t);
			}
		});

		this.m_stunnedObjects.Each<Lifetime, IsStunned>(scope (entityRef, lifetime, stun) => {
			lifetime.remaining -= delta;
			if(lifetime.remaining <= 0f){
				stun.currentlyStunned = false;
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
