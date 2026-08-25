namespace BeefHush;

[RegisterSystem]
class ParticleSystem : GameSystem
{
	Query m_emitterQuery;

	public void Init()
	{

		QueryBuilder builder = .();
		builder.With<ParticleEmitter>();
		this.m_emitterQuery = builder.Build();
	}

	public void OnShutdown()
	{

	}

	public void OnUpdate(float delta)
	{
		this.m_emitterQuery.Each<ParticleEmitter>(scope (entityRef, emitter) => {
			// TODO: Instance the particles or something
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
