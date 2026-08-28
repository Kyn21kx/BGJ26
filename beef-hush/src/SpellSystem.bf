namespace BeefHush;

using Hush;
using System;

[RegisterSystem]
class SpellSystem : GameSystem
{
	private const uint8 MAX_SPELL_MESH_COUNT = 2;
	private const StringView [MAX_SPELL_MESH_COUNT] availableSpells = .("fire_spell.glb", "electric_spell.glb");
	private Query m_fireSpellsQuery;
	private Query m_manaQuery;
	private float m_totalTime;
	private void* m_scene;
	private BeefHush.Entity m_renderingSystem;
	private BeefHush.Entity [MAX_SPELL_MESH_COUNT] m_bulletsMeshRef;
	private Random m_random;
	public void Init()
	{
		this.m_totalTime = 0f;
		QueryBuilder builder = .();
		builder.With<Spell>();
		builder.With<Controller>();
		builder.With<ManaStat>();
		builder.With<WorldTransform>();
		this.m_fireSpellsQuery = builder.Build();
		this.m_scene = HushEngine.GetScene(EngineDependencies.Instance.Engine);
		// Make sure we properly initialize this
		this.m_fireSpellsQuery.Each<Spell>(scope (entityRef, spell) => {
			spell.lastFireTime = 0f;
		});
		//Kinda redundant, remove if not needed
		this.m_fireSpellsQuery.EachEntity(scope (entityRef) => {
			if (entityRef.GetComponent<IsStunned>() == null) {
				entityRef.AddComponent<IsStunned>();
			}
			if (entityRef.GetComponent<Lifetime>() == null) {
				entityRef.AddComponent<Lifetime>();
			}
		});

		builder = .();
		builder.With<ManaStat>();
		this.m_manaQuery = builder.Build();
		this.InitializeMeshes();

		this.m_random = new .();
	}

	public void InitializeMeshes() {
		const StringView renderSystemName = "RenderingSystem";
		this.m_renderingSystem = BeefHush.Entity(Scene.CreateEntityWithKey(this.m_scene, (char8*)renderSystemName.ToRawData().Ptr, (uint64)renderSystemName.Length));
		
		let handle = this.m_renderingSystem.GetComponent<RenderingSystemAPI>();

		for(uint64 index = 0; index < MAX_SPELL_MESH_COUNT; index++){
			uint64 rootEntId = handle.instantiateMeshEntities(&(availableSpells[index][0]), handle.instance);

			this.m_bulletsMeshRef[index] = .(Scene.EntityFromIdUnchecked(this.m_scene, rootEntId));
			// Make it invisible, but the MeshReference Component is still there
			this.m_bulletsMeshRef[index].RemoveComponent<WorldTransform>();
			this.m_bulletsMeshRef[index].RemoveComponent<LocalTransform>();
		}
	}

	public void OnShutdown()
	{
		for(uint64 index = 0; index < MAX_SPELL_MESH_COUNT; index++){
			Scene.DestroyEntity(this.m_scene, this.m_bulletsMeshRef[index].InnerEntity());
		}

		delete this.m_random;
	}

	private void ManaSubsystem(float delta) {
		this.m_manaQuery.Each<ManaStat>(scope (entityRef, manaStat) => {
			manaStat.currentMana += manaStat.regenerationRate * delta;
			manaStat.currentMana = Math.Clamp(manaStat.currentMana, 0, 100);
		});
	}

	public void OnUpdate(float delta)
	{
		this.m_totalTime += delta;
		this.ManaSubsystem(delta);
		const Vector3 bulletScale = Constants.Vector3_ONE * 30.0f;
		this.m_fireSpellsQuery.Each<Spell, Controller, ManaStat, WorldTransform>(scope (entityRef, spell, controller, manaStat, xform) => {
			float diff = this.m_totalTime - spell.lastFireTime;
			// TODO: Make the component decide if this is a mouse button press or something else
			bool mouseWasPressed = InputManager.GetMouseButtonPressed((EMouseButton)controller.fire);

			// Default behavior: the player CAN still attack (cast) while stunned.
			bool canCast = mouseWasPressed && diff >= spell.fireRate && manaStat.currentMana >= spell.manaCost;

			/*
			   Alternative behavior (uncomment to enable): a stunned player CANNOT
			   cast at all. Fetch the caster's IsStunned and reject the cast, e.g.:
			       IsStunned* stun = entityRef.GetComponent<IsStunned>();
			       canCast = canCast && (stun == null || !stun.currentlyStunned);
			*/

			if (canCast) {
				// Add a bullet mesh
				Console.WriteLine("Fired spell!");
				manaStat.currentMana -= spell.manaCost;
				spell.lastFireTime = this.m_totalTime;

				// Slow path at instancing
				let handle = this.m_renderingSystem.GetComponent<RenderingSystemAPI>();

				uint64 rootEntId = handle.instantiateMeshEntities(&(availableSpells[spell.spellAssetId][0]), handle.instance);

				let bulletRootEntity = BeefHush.Entity(Scene.EntityFromIdUnchecked(this.m_scene, rootEntId));

				RigidBody* rig = bulletRootEntity.AddComponent<RigidBody>();
				var bulletXform = bulletRootEntity.GetComponent<LocalTransform>();
				bulletXform.SetScale(bulletScale);
				*rig = .(); // Set default vals
				rig.aabb.pos = xform.GetPositionValue(); // + The direction offset
				Vector3 shootDir = .(1, 0, 0);

				castingSubSystem(&entityRef, spell, &shootDir);

				rig.SetVelocity(shootDir * spell.projectileSpeed);
				rig.SetAngularVelocity(shootDir * spell.projectileSpeed * 1.5f);
				Lifetime* bulletLifetime = bulletRootEntity.AddComponent<Lifetime>();
				// t = d / V
				bulletLifetime.remaining = spell.range / spell.projectileSpeed;
				// Only entities marked to expire on their Lifetime running out should
				// be destroyed by the LifetimeSystem. Add the marker to the projectile.
				bulletRootEntity.AddComponent<DestroyOnExpiry>();
			}
		});

	}

	public void castingSubSystem(BeefHush.Entity* entityRef, Spell* spell, Vector3* dir){

		if(spell.type == SpellType.Fire){
			//.nextdouble apparently returns from 0 to 1, so a range is not needed
			float roll = (float)this.m_random.NextDouble();

			if(roll < spell.badCastChance){
				dir.x = - 1;
			}

		}

		if(spell.type == SpellType.Electric){
			float roll = (float)this.m_random.NextDouble();

			if(roll < spell.badCastChance){
				// Self-stun on a bad cast. IsStunned/Lifetime are guaranteed on the
				// caster (added at startup), but guard anyway in case of misuse.
				IsStunned* stun = entityRef.GetComponent<IsStunned>();
				Lifetime* lifetime = entityRef.GetComponent<Lifetime>();
				if (stun != null && lifetime != null && !stun.currentlyStunned) {
					lifetime.initialLifetime = 1.0f;
					lifetime.remaining = 1.0f;
					stun.currentlyStunned = true;
				}
			}
		}

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
