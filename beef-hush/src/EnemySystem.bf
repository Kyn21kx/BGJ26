namespace BeefHush;

using Hush;
using System;

public class EnemySystem : GameSystem {

	Query m_enemiesQuery;

	public void Init()
	{
		QueryBuilder builder = .();
		builder.With<Enemy>();
	}

	public void OnShutdown()
	{

	}

	public void OnUpdate(float delta)
	{
		// The idea is that an enemy will follow a set of goals and state
		// the main goal is to catch the player, but it will change priority
		// with getting away from them if he gets too close, idk, might depend on the comp

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

