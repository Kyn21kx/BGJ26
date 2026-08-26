namespace BeefHush;

using Hush;
using System;

[RegisterSystem]
class CameraSystem : GameSystem
{
	Query m_mainCamQuery;
	Query m_targetsQuery;


	public void Init()
	{

		QueryBuilder builder = .();

		builder.With<MainCamTag>();
		builder.With<LocalTransform>();

		this.m_mainCamQuery = builder.Build();

		builder = .();

		builder.With<PlayerTag>();
		builder.With<RigidBody>();
		this.m_targetsQuery = builder.Build();
	}

	public void OnShutdown()
	{

	}

	public void OnUpdate(float delta)
	{
		// The camera should look at a focal point that is the average of all players
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
