namespace BeefHush;

using Hush;
using System;

[HushComponent, CRepr]
struct Spawner
{
	//This field is needed to properly use enum::overTime
	public bool isActive;
	public float spawnRate;
	public float lastSpawnTime;
	public int32 maxSpawnCount;
	public int32 currentSpawnCount;
	public float spawnRadius;
}