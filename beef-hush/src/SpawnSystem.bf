namespace BeefHush;

using Hush;
using System;

[RegisterSystem]
public class SpawnSystem : GameSystem {

	private Query spawnerQuery;
	private void* m_scene;
	private BeefHush.Entity m_renderingSystem;
	private float totalTime;
	private Random m_random;

	public void Init(){

		Console.WriteLine("Spawn system initialized.");

		this.totalTime = 0.0f;
		this.m_scene = HushEngine.GetScene(EngineDependencies.Instance.Engine);
		this.m_random = new Random();

		const StringView renderSystemName = "RenderingSystem";
		this.m_renderingSystem = .(Scene.CreateEntityWithKey(
			this.m_scene,
			&(renderSystemName[0]),
			(uint64)renderSystemName.Length
		));

		QueryBuilder builder = .();
		builder.With<Spawner>();
		builder.With<LocalTransform>();
		this.spawnerQuery = builder.Build();

		this.spawnerQuery.Each<Spawner>(scope (entity, spawner) => {
			spawner.lastSpawnTime = 0.0f;
			spawner.currentSpawnCount = 0;
		});
	}

	public void OnShutdown(){
		Console.WriteLine("Spawn system shutdown.");
		delete m_random;
	}

	public void ActivateSpawner(BeefHush.Entity entity){

		Spawner* spawner = entity.GetComponent<Spawner>();
		if (spawner == null){ return; }

		spawner.isActive = true;
		spawner.lastSpawnTime = this.totalTime;
		spawner.currentSpawnCount = 0;
	}

	public void ActivateAll(){

		this.spawnerQuery.Each<Spawner>(scope (entity, spawner) => {
			spawner.isActive = true;
			spawner.lastSpawnTime = this.totalTime;
			spawner.currentSpawnCount = 0;
		});
	}

	public void OnUpdate(float delta){

		this.totalTime += delta;

		this.spawnerQuery.Each<Spawner, LocalTransform>(
			scope (entity, spawner, transform) =>
			{
				if (!spawner.isActive){
					return;
				}

				if (spawner.spawnRate <= 0.0f){
					return;
				}

				//Got a feeling this might produce a bug
				if (spawner.maxSpawnCount > 0 && spawner.currentSpawnCount >= spawner.maxSpawnCount){
					return;
					}

				float elapsed = this.totalTime - spawner.lastSpawnTime;
				if (elapsed < spawner.spawnRate){
					return;
				}

				spawner.lastSpawnTime = this.totalTime;
				this.SpawnEntity(spawner, transform);
			}
		);
	}

	private void SpawnEntity(Spawner* spawner, LocalTransform* transform){

		let handle = this.m_renderingSystem.GetComponent<RenderingSystemAPI>();
		uint64 rootEntId = handle.instantiateMeshEntities(
			spawner.meshPath.Ptr,
			handle.instance
		);

		BeefHush.Entity newEntity = .(Scene.EntityFromIdUnchecked(this.m_scene, rootEntId));

		Vector3 offset = this.GetRandomizedOffset(spawner.spawnRadius);
		Vector3 basePos = *transform.GetPosition();
		var localXform = newEntity.GetComponent<LocalTransform>();
		localXform.SetPosition(basePos + offset);

		spawner.currentSpawnCount++;
	}

	public void SpawnOnDeath(BeefHush.Entity entity)
	{
		this.SpawnFromEntity(entity);
	}

	public void SpawnOnHit(BeefHush.Entity entity)
	{
		this.SpawnFromEntity(entity);
	}

	private void SpawnFromEntity(BeefHush.Entity entity){

		Spawner* spawner = entity.GetComponent<Spawner>();
		if (spawner == null) return;

		LocalTransform* transform = entity.GetComponent<LocalTransform>();
		if (transform == null) return;

		if (spawner.maxSpawnCount > 0 &&
			spawner.currentSpawnCount >= spawner.maxSpawnCount)
			return;

		this.SpawnEntity(spawner, transform);
	}

	private Vector3 GetRandomizedOffset(float radius){
		//Change this to uint?
		if (radius <= 0.0f){
			return .(0, 0, 0);
		}
		//
		float angle = (float)m_random.NextDouble() * Math.PI_f * 2.0f;
		float dist = (float)m_random.NextDouble() * radius;
		return .(Math.Cos(angle) * dist, 0.0f, Math.Sin(angle) * dist);
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
