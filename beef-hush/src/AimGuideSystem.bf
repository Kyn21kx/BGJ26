namespace BeefHush;

using Hush;
using System;

[RegisterSystem]
class AimGuideSystem : GameSystem
{
	Query m_aimGuideQuery;

	public void Init()
	{
		QueryBuilder builder = .();
		builder.With<WorldTransform>();
		builder.With<AimGuide>();
		this.m_aimGuideQuery = builder.Build();
	}

	public void OnShutdown()
	{

	}

	public void OnUpdate(float delta)
	{

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