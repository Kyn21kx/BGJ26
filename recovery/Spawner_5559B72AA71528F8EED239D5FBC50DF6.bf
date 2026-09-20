dxccccccccccccccccnamespace BeefHush;

using Hush;
using System;

[HushComponent, CRepr]
struct Spawner
{
	public bool isActive;
	public float spawnRate;
	public float lastSpawnTime;
	public int32 maxSpawnCount;
	public int32 currentSpawnCount;
	public float spawnRadius;
	public StringView prefabName;
}
