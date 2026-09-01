namespace BeefHush;

using Hush;
using System;
using System.Collections;

[RegisterSystem]
class ParticleSystem : GameSystem
{
	private const uint8 MAX_PARTICLES_COUNT = 2;
	private const StringView [MAX_PARTICLES_COUNT] AvailableParticles = .("res://Box.glb","res://decahedron.glb");
	private Query m_emitterQuery;
	private Query m_particleTagQuery;
	private float m_totalTime;
	private	void* m_scene;
	private BeefHush.Entity m_renderingSystem;
	private BeefHush.Entity [MAX_PARTICLES_COUNT] m_particlesMeshRef;
	private Random m_random;

	struct EmissionRequest
	{
		public Vector3 basePos;
		public float minScale;
		public float maxScale;
		public uint64 assetId;
		public float particleLifeTime;
	}

	public void Init(){

		Console.WriteLine("Particle system was initialized");

		QueryBuilder builder = .();
		builder.With<ParticleEmitter>();
		builder.With<LocalTransform>();
		this.m_emitterQuery = builder.Build();

		builder = .();
		builder.With<ParticleTag>();
		this.m_particleTagQuery = builder.Build();
		this.m_totalTime = 0.0f;
		this.m_scene = HushEngine.GetScene(EngineDependencies.Instance.Engine);

		this.m_emitterQuery.Each<ParticleEmitter>(scope (entityRef, emitter) => {
			emitter.lastEmissionTime = 0;
		});
		this.m_random = new .();
		this.InitializeParticleMesh();
	}

	public void InitializeParticleMesh(){
		const StringView renderSystemName = "RenderingSystem";
		this.m_renderingSystem = BeefHush.Entity(Scene.CreateEntityWithKey(this.m_scene,(char8*)renderSystemName.ToRawData().Ptr, (uint64)renderSystemName.Length));

		let handle = this.m_renderingSystem.GetComponent<RenderingSystemAPI>();

		for(uint8 index = 0; index < MAX_PARTICLES_COUNT; index++){
			uint64 rootEntId = handle.instantiateMeshEntities(&(AvailableParticles[index][0]), handle.instance);
			this.m_particlesMeshRef[index] = .(Scene.EntityFromIdUnchecked(this.m_scene, rootEntId));

			this.m_particlesMeshRef[index].RemoveComponent<WorldTransform>();
			this.m_particlesMeshRef[index].RemoveComponent<LocalTransform>();
		}
	}

	public void OnShutdown(){
		delete this.m_random;
	}

	public void OnUpdate(float delta){
		this.m_totalTime += delta;

		// The emitter cap must reflect particles that already died: LifetimeSystem
		// destroys expired particles without notifying emitters, so counting the
		// alive ParticleTags every frame is the only source of truth.
		uint64 aliveParticles = this.m_particleTagQuery.Count();

		// Collect emission requests while iterating; spawning inside the Each would
		// create entities and move flecs tables, leaving the next row's component
		// pointers dangling.
		List<EmissionRequest> requests = scope List<EmissionRequest>();

		this.m_emitterQuery.Each<ParticleEmitter, LocalTransform>(scope (entityRef, emitter, emitterxForm) => {

			if (this.m_totalTime - emitter.lastEmissionTime < emitter.emitRate){
				return;
			}

			if (aliveParticles + (uint64)requests.Count >= (uint64)emitter.maxParticles){
				return;
			}

			emitter.lastEmissionTime = this.m_totalTime;
			emitter.currentParticleCount = (int32)(aliveParticles + (uint64)requests.Count);

			EmissionRequest request = .();
			request.basePos = emitterxForm.GetPositionValue();
			request.minScale = emitter.minScale;
			request.maxScale = emitter.maxScale;
			request.assetId = emitter.particleAssetId;
			request.particleLifeTime = emitter.particleLifeTime;
			requests.Add(request);
		});

		for (let request in requests){
			this.SpawnParticle(request);
		}
	}

	public void SpawnParticle(EmissionRequest request){
		if (request.assetId >= MAX_PARTICLES_COUNT){
			return;
		}

		let handle = this.m_renderingSystem.GetComponent<RenderingSystemAPI>();
		uint64 rootEntId = handle.instantiateMeshEntities(&(AvailableParticles[request.assetId][0]), handle.instance);

		BeefHush.Entity particle = .(Scene.EntityFromIdUnchecked(this.m_scene, rootEntId));
		var lifeTime = particle.AddComponent<Lifetime>();
		lifeTime.remaining = request.particleLifeTime;
		lifeTime.initialLifetime = request.particleLifeTime;

		particle.AddComponent<ParticleTag>();

		var localxForm = particle.GetComponent<LocalTransform>();
		float scale = RandomizeScale(request.minScale, request.maxScale);
		localxForm.SetScale(Constants.Vector3_ONE * scale);

		Vector3 pos = RandomizePosition(request.basePos);
		localxForm.SetPosition(pos);
	}

	public float RandomizeScale(float min, float max){
		float t = (float)m_random.NextDouble();
		return min + (max - min) * t;
	}

	public Vector3 RandomizePosition(Vector3 basePos){
		float offsetX = ((float)m_random.NextDouble() - 0.5f) * 2.0f;
		float offsetY = ((float)m_random.NextDouble() - 0.5f) * 2.0f;
		float offsetZ = ((float)m_random.NextDouble() - 0.5f) * 2.0f;
		return basePos + Vector3(offsetX, offsetY, offsetZ);
	}

	public void OnFixedUpdate(float delta){


	}

	public void OnRender(){

	}

	public void OnPreRender(){


	}

	public void OnPostRender(){


	}
}
