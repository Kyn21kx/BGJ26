namespace BeefHush;

using Hush;
using System;
using System.Collections;

// Note (Nef): This system probably needs a refactor to make it simpler 
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
		public Vector3 velocity;
		public float minScale;
		public float maxScale;
		public uint64 assetId;
		public float particleLifeTime;
	}

	public void Init(){

		Console.WriteLine("Particle system was initialized");

		QueryBuilder builder = .();
		builder.With<ParticleEmitter>();
		builder.With<WorldTransform>();
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

		this.m_emitterQuery.Each<ParticleEmitter, WorldTransform>(scope (entityRef, emitter, emitterxForm) => {

			if (this.m_totalTime - emitter.lastEmissionTime < emitter.emitRate){
				return;
			}

			if (aliveParticles >= (uint64)emitter.maxParticles){
				return;
			}

			// Validate the asset id where the request is built: only well-formed
			// requests enter the list, so SpawnParticle can index AvailableParticles
			// without a bounds guard.
			if (emitter.particleAssetId >= MAX_PARTICLES_COUNT){
				return;
			}

			emitter.lastEmissionTime = this.m_totalTime;

			this.SpawnParticle(*emitter, emitterxForm.GetPositionValue());
			emitter.currentParticleCount++;
		});

	}

	public void SpawnParticle(in ParticleEmitter emitter, Vector3 basePos){
		// Callers are expected to build requests from validated emitter data
		// (see OnUpdate); the assetId guard lives there.
		let handle = this.m_renderingSystem.GetComponent<RenderingSystemAPI>();
		uint64 rootEntId = handle.instantiateMeshEntities(&(AvailableParticles[emitter.particleAssetId][0]), handle.instance);

		BeefHush.Entity particle = .(Scene.EntityFromIdUnchecked(this.m_scene, rootEntId));
		var lifeTime = particle.AddComponent<Lifetime>();
		lifeTime.remaining = emitter.particleLifeTime;
		lifeTime.initialLifetime = emitter.particleLifeTime;

		particle.AddComponent<ParticleTag>();

		var localxForm = particle.GetComponent<LocalTransform>();
		float scale = RandomizeScale(emitter.minScale, emitter.maxScale);
		localxForm.SetScale(Constants.Vector3_ONE * scale);

		Vector3 pos = RandomizePosition(basePos);
		localxForm.SetPosition(pos);
		if (emitter.velocity == Constants.Vector3_ZERO) return;
		// Add a physics comp
		RigidBody* rig = particle.AddComponent<RigidBody>();
		(*rig) = .();
		rig.aabb.pos = pos;
		rig.SetVelocity(emitter.velocity);
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
