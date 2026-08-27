namespace BeefHush;

using Hush;
using System;

[RegisterSystem]
class ParticleSystem : GameSystem
{
	private const uint8 MAX_PARTICLES_COUNT = 2;
	//NOTE: Available particles should contain virtual path
	private const StringView [MAX_PARTICLES_COUNT] AvailableParticles = .("Particle1","Particle2");
	private Query m_emitterQuery;
	private float m_totalTime;
	private	void* m_scene;
	private BeefHush.Entity m_renderingSystem;
	private BeefHush.Entity [MAX_PARTICLES_COUNT] m_particlesMeshRef;
	private Random m_random;

	public void Init(){

		Console.WriteLine("Particle system was initialized");

		QueryBuilder builder = .();
		builder.With<ParticleEmitter>();
		this.m_emitterQuery = builder.Build();
		this.m_totalTime = 0.0f;
		this.m_scene = HushEngine.GetScene(EngineDependencies.Instance.Engine);

		this.m_emitterQuery.Each<ParticleEmitter>(scope (entityRef, emitter) => {
			emitter.lastEmissionTime = 0;
		});
		this.m_random = new .();
	}


	public void InitializeParticleMesh(){
		//copy paste from Spell system
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
		this.m_totalTime =+ delta;

		this.m_emitterQuery.Each<ParticleEmitter, LocalTransform>(scope (entityRef, emitter, emitterxForm) => {

			let handle = this.m_renderingSystem.GetComponent<RenderingSystemAPI>();
			uint64 rootEntId = handle.instantiateMeshEntities(&(AvailableParticles[emitter.particleAssetId][0]), handle.instance);


			if(!(this.m_totalTime - emitter.lastEmissionTime >= emitter.emitRate)){
				return;
			}

			emitter.currentParticleCount ++;

			if(emitter.currentParticleCount > emitter.maxParticles){
				return;
			}

			BeefHush.Entity particle = .(Scene.EntityFromIdUnchecked(this.m_scene, rootEntId));
			var lifeTime = particle.AddComponent<Lifetime>();
			lifeTime.remaining = emitter.particleLifeTime;


			var localxForm = particle.GetComponent<LocalTransform>();
			//TODO: add randomize setScale()
			localxForm.SetScale(Constants.Vector3_ONE);
			localxForm.SetPosition(*emitterxForm.GetPosition());

			emitter.lastEmissionTime = this.m_totalTime;
		});
	}

	public void RandomizeScale(){

	}

	public void RandomizePosition(){

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
