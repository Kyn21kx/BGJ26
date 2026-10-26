namespace BeefHush;

using Hush;
using System;
using System.Collections;
using System.Diagnostics;

[RegisterSystem]
class SpellSystem : GameSystem
{
	private const uint8 MAX_SPELL_MESH_COUNT = (uint8)SpellType.MAX;
	// NOTE: This should match the Spell's SpellType enum
	private const StringView [MAX_SPELL_MESH_COUNT] availableSpells = .("res://FireBallPURPLE.glb", "res://decahedron.glb", "res://PlayerModelGhosted.glb");
	// HACK: Super bad way of saying we can't get our models in the same scale
	private const float [MAX_SPELL_MESH_COUNT] spellScaleFactor = .(0.5f, 0.5f, 0.1f);
	private const float SELF_STUN_TIME = 0.5f;

	
	private Query m_fireSpellsQuery;
	private Query m_spellSelectorQuery;
	private Query m_manaQuery;
	private float m_totalTime;
	private void* m_scene;
	private BeefHush.Entity m_renderingSystem;
	private BeefHush.Entity [MAX_SPELL_MESH_COUNT] m_bulletsMeshRef;
	private Random m_random;
	private BeefHush.Entity m_mainCamEntity;

	private HashSet<uint64> m_entitiesToDelete;

	public void Init()
	{
		this.m_entitiesToDelete = new .(64);
		this.m_totalTime = 0f;
		QueryBuilder builder = .();
		builder.With<Spell>();
		builder.With<Controller>();
		builder.With<ManaStat>();
		builder.With<RigidBody>();
		this.m_fireSpellsQuery = builder.Build();
		this.m_scene = HushEngine.GetScene(EngineDependencies.Instance.Engine);
		// Make sure we properly initialize this
		this.m_fireSpellsQuery.Each<Spell>(scope (entityRef, spell) => {
			spell.lastFireTime = 0f;
		});
		builder = .();
		builder.With<ManaStat>();
		this.m_manaQuery = builder.Build();
		this.InitializeMeshes();

		this.m_random = new .();
		builder = .();
		builder.With<Camera>();

		Query mainCamQ = builder.Build();
		mainCamQ.EachEntity(scope (entityRef) => {
		   this.m_mainCamEntity = entityRef;
		});

		builder = .();
		builder.With<SpellInventory>();
		builder.With<Controller>();
		builder.With<Spell>();
		this.m_spellSelectorQuery = builder.Build();

		// TEMP: Small hack for now
		builder = .();
		builder.With<Spell>();
		builder.Without<Controller>();
		builder.Without<SpellInventory>();
		Query tempQuery = builder.Build();
		this.m_spellSelectorQuery.Each<SpellInventory, Controller, Spell>(scope (selectorEnt, spellInventory, controller, selectorActiveSpell) => {
			spellInventory.allSpells = new List<Spell>((int32)SpellType.MAX);
			tempQuery.Each<Spell>(scope [&](entityRef, spell) => {
				spellInventory.allSpells.Add(*spell);
			});
		});
		PhysicsSystem.OnCollisionEvent.Add(new (a, b) => {
			// TODO: Make this better by making sure the Physics system does not emit multiple events for the same entities
			if (this.m_entitiesToDelete.Contains(a.id) || this.m_entitiesToDelete.Contains(b.id)) {
				return;
			}
			ColliderArgs* spellColl = &b;
			ColliderArgs* otherColl = &a;
			if (a.collider.identifierTag & (int32)EEntityTag.IsSpellType != 0) {
				spellColl = &a;
				otherColl = &b;
			}
			else if (b.collider.identifierTag & (int32)EEntityTag.IsSpellType == 0) {
				// Not a spell collision
				return;
			}

			// TODO: Make it a switch
			// Now we can handle collisions with spells
			Console.WriteLine(scope $"Spell coll event, between identifiers {spellColl.collider.identifierTag} and {otherColl.collider.identifierTag}");
			if (spellColl.collider.identifierTag == (int32)EEntityTag.Spell && otherColl.collider.identifierTag == (int32)EEntityTag.Enemy) {
				// Damage the enemy
				HealthSystem.DamageEntity(this.m_scene, otherColl.id, 1.0f, spellColl.id);
				this.m_entitiesToDelete.Add(spellColl.id);
				OnSpellDestroyed(spellColl.id);
			}
			else if (spellColl.collider.identifierTag == (int32)EEntityTag.EnemySpell && otherColl.collider.identifierTag == (int32)EEntityTag.Player) {
				// Damage the enemy
				HealthSystem.DamageEntity(this.m_scene, otherColl.id, 1.0f, spellColl.id);
				this.m_entitiesToDelete.Add(spellColl.id);
				OnSpellDestroyed(spellColl.id);
			}
			else if (otherColl.collider.identifierTag == (int32)EEntityTag.Wall) {
				// Do whatever the spell needs to do on collision, then delete it
				this.m_entitiesToDelete.Add(spellColl.id);
				OnSpellDestroyed(spellColl.id);
			}
		});
	}

	public void InitializeMeshes() {
		const StringView renderSystemName = "RenderingSystem";
		this.m_renderingSystem = BeefHush.Entity(Scene.CreateEntityWithKey(this.m_scene, (char8*)renderSystemName.ToRawData().Ptr, (uint64)renderSystemName.Length));
		
		let handle = this.m_renderingSystem.GetComponent<RenderingSystemAPI>();
		const StringView path = "res://FireBallPURPLE.glb";
		uint64 rootEntId = handle.instantiateMeshEntities(&(path[0]), handle.instance);

		for(uint64 index = 0; index < MAX_SPELL_MESH_COUNT; index++) {
			uint64 rootEntId = handle.instantiateMeshEntities(&(availableSpells[index][0]), handle.instance);

			this.m_bulletsMeshRef[index] = .(Scene.EntityFromIdUnchecked(this.m_scene, rootEntId));
			// Make it invisible, but the MeshReference Component is still there
			// this.m_bulletsMeshRef[index].AddComponent<WorldTransform>();
			// var localXform = this.m_bulletsMeshRef[index].AddComponent<LocalTransform>();
			// localXform.SetScale(Constants.Vector3_ONE * Constants.EPSILON);
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

	private Vector3 GetShootDirection(Vector3 currPos) {
		// Get the mouse position in world space
		Vector2 mouseScreenPos = InputManager.GetMousePosition();
		// Find cam
		Camera* cam = this.m_mainCamEntity.GetComponent<Camera>();
		LocalTransform* xform = this.m_mainCamEntity.GetComponent<LocalTransform>();
		float[16] mat = .();
		xform.GetTransformationMatrixUnsafe(&(mat[0]), 16);
		Vector3 direction = .();
		Vector3 origin = cam.ScreenToWorldPosUnsafe(&(mat[0]), mouseScreenPos, &direction);
		Vector3 worldPos = cam.ProjectPlanePosition(origin, direction, 0.0f);

		// Then we do dest - source
		return (worldPos - currPos).normalized();
	}

	public static uint64 MakeSpell(uint64 caster, SpellType type, int32 collIdentifier, Vector3 position, Vector3 direction, float speed, float range) {
		// Slow path at instancing
		const StringView renderSystemName = "RenderingSystem";
		void* scene = HushEngine.GetScene(EngineDependencies.Instance.Engine);
		let renderingSystem = BeefHush.Entity(Scene.CreateEntityWithKey(scene, (char8*)renderSystemName.ToRawData().Ptr, (uint64)renderSystemName.Length));

		// TODO: Use the entity registry to fetch this, bc this performs a string hash
		let handle = renderingSystem.GetComponent<RenderingSystemAPI>();

		uint64 bulletRootEntityId = MakeSpellProjectile(scene, caster, type, handle, collIdentifier, position, direction, speed, range);
		BeefHush.Entity bulletRootEntity = .(Scene.EntityFromIdUnchecked(scene, bulletRootEntityId));
		// Add particle system
		ParticleEmitter* emitter = bulletRootEntity.AddComponent<ParticleEmitter>();
		FillParticleEmitterForSpell(emitter, type, direction);
		return bulletRootEntityId;
	}

	private static uint64 MakeSpellProjectile(void* scene, uint64 caster, SpellType type, RenderingSystemAPI* renderingHandle, int32 collIdentifier, Vector3 position, Vector3 direction, float speed, float range) {
		StringView path = availableSpells[(int32)type];
		uint64 rootEntId = renderingHandle.instantiateMeshEntities(&(path[0]), renderingHandle.instance);

		let bulletRootEntity = BeefHush.Entity(Scene.EntityFromIdUnchecked(scene, rootEntId));
		var bulletXform = bulletRootEntity.GetComponent<LocalTransform>();
		var bulletWorldXform = bulletRootEntity.GetComponent<WorldTransform>();

		bulletXform.SetScale(Constants.Vector3_ONE * spellScaleFactor[(int32)type]);

		// Ensure the projectile faces the correct direction
		Vector3 vecRotTarget = position + direction;
		vecRotTarget.y = 0f;
		Vector3 newEuler = Vector3.LookRotationEulerYawOnly(vecRotTarget, position, Constants.Vector3_UP);
		bulletXform.SetEulerAngles(&newEuler);


		let spellInfo = bulletRootEntity.AddComponent<SpellInfo>();
		spellInfo.casterEntity = caster;
		spellInfo.type = (int32)type;
		let collider = bulletRootEntity.AddComponent<Collider>();
		collider.identifierTag = collIdentifier;
		RigidBody* rig = bulletRootEntity.AddComponent<RigidBody>();
		*rig = .(); // Set default vals
		rig.aabb.pos = position; // + The direction offset
		rig.SetVelocity(direction * speed);
		Lifetime* bulletLifetime = bulletRootEntity.AddComponent<Lifetime>();
		// t = d / V
		bulletLifetime.remaining = range / speed;
		bulletLifetime.onQueueDestroyHook = => OnSpellDestroyed;
		switch(type) {
		case .Fire:
		case .Electric:
			break;
		case .Dasher:
			bulletRootEntity.AddComponent<PlayerTag>(); // So that the Camera system follows it too
			var meshRef = bulletRootEntity.GetComponent<BeefHush.MeshReference>();
			let matCount = meshRef.GetMaterialCount();
			Debug.Assert(matCount > 0, "Mesh reference for projectile root holds no materials!");
			Graphics.Material3D* mat = meshRef.GetMaterialAt(0);
			const StringView emissionProp = "emissionFactors";
			Vector4 emission = .();
			emission.x = 1f;
			emission.y = 1f;
			emission.z = 1f;
			emission.w = 50f;
			mat.SetPropertyRaw(emissionProp.Ptr, (uint64)emissionProp.Length, (uint8*)&emission, sizeof(Vector4));
			break;
		default:
			Debug.Assert(false, "Spell type is outside the bounds of implemented spells!");
			return 0;
		}
		return rootEntId;
	}

	private static void FillParticleEmitterForSpell(ParticleEmitter* emitter, SpellType type, Vector3 direction) {
		(*emitter) = .();
		emitter.maxParticles = 500;
		emitter.maxScale = 0.2f;
		emitter.emitRadius = 0.3f;
		emitter.minScale = 0.1f;
		emitter.particleLifeTime = 1f;
		emitter.velocity = direction * -1f; // We could make them go slightly up to disappear
		emitter.velocity.y = 0.0f;
		emitter.emitRate = 0.01f;

		switch(type) {
		case .Fire:
		case .Electric:
			emitter.particleAssetId = 0;
			break;
		case .Dasher:
			emitter.minScale = 1f;
			emitter.maxScale = 1.5f;
			emitter.particleAssetId = 3;
			emitter.particleLifeTime = 0.3f;
			break;
		default:
			Debug.Assert(false, "Spell type is outside the bounds of implemented spells!");
			return;
		}
	}

	// Either at the end of the spell's lifetime, or when we collide with something
	private static void OnSpellDestroyed(uint64 spellId) {
		// Check the spell type
		void* scene = HushEngine.GetScene(EngineDependencies.Instance.Engine);
		BeefHush.Entity spellEnt = .(Scene.EntityFromIdUnchecked(scene, spellId));
		let spellInfo = spellEnt.GetComponent<SpellInfo>();
		Debug.Assert(spellInfo != null, scope $"Spell info component was not set for spell {spellId}");
		let spellType = (SpellType)spellInfo.type;
		switch(spellType) {
		case .Dasher:
			BeefHush.Entity casterEnt = .(Scene.EntityFromIdUnchecked(scene, spellInfo.casterEntity));
			// TP to the position of the spell
			var spellRig = spellEnt.GetComponent<RigidBody>();
			var casterRig = casterEnt.GetComponent<RigidBody>();

			casterRig.SetVelocity(Vector3.ZERO);
			casterRig.SetPosition(spellRig.GetPosition());
			break;
		default:
			break;
		}
	}

	private void SpawnBullet(BeefHush.Entity* entityRef, RigidBody* spellRig, Spell* spell, Vector3 direction) {
		const StringView path = "res://decahedron.glb";

		CastingSubSystem(entityRef, spell, &direction);
		MakeSpell(entityRef.Id, (SpellType)spell.type, (int32)EEntityTag.Spell, spellRig.aabb.pos, direction, spell.projectileSpeed, spell.range);
	}

	// TODO: Refactor this so that we use a better SpellCaster tag and we don't have to copy info from the other comp
	private void SpellSelectionSystem(BeefHush.Entity entityRef, SpellInventory* spellInventory, Controller* controller, Spell* activeSpell) {
		let nextSpellKey = (EKeyCode)controller.nextSpell;
		let prevSpellKey = (EKeyCode)controller.prevSpell;
		int32 chosenSpell;
		if (InputManager.IsKeyDownThisFrame(nextSpellKey)) {
			// Try to peek to see if the next spell is available
			chosenSpell = (spellInventory.activeSpellIdx + 1) % (int32)SpellType.MAX;
		}
		else if (InputManager.IsKeyDownThisFrame(prevSpellKey)) {
			chosenSpell = spellInventory.activeSpellIdx - 1;
			chosenSpell = chosenSpell >= 0 ? chosenSpell : (int32)SpellType.MAX - 1;
		}
		else {
			return;
		}

		// Copy all info from chosen spell to the active spell
		(*activeSpell) = spellInventory.allSpells[chosenSpell];
		spellInventory.activeSpellIdx = chosenSpell;
	}

	public void OnUpdate(float delta)
	{
		this.m_totalTime += delta;
		this.ManaSubsystem(delta);
		this.m_spellSelectorQuery.Each<SpellInventory, Controller, Spell>(scope => this.SpellSelectionSystem);
		this.m_fireSpellsQuery.Each<Spell, Controller, ManaStat, RigidBody>(scope (entityRef, spell, controller, manaStat, spellRig) => {
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
				manaStat.currentMana -= spell.manaCost;
				spell.lastFireTime = this.m_totalTime;

				Vector3 direction = this.GetShootDirection(spellRig.aabb.pos);
				SpawnBullet(&entityRef, spellRig, spell, direction);
			}
		});

	}

	public void CastingSubSystem(BeefHush.Entity* entityRef, Spell* spell, Vector3* dir){
		float roll = (float)this.m_random.NextDouble();
		if (roll >= spell.badCastChance) {
			return;
		}

		const float BAD_CAST_SHAKE_STRENGTH = 0.1f;
		CameraSystem.SendShake(BAD_CAST_SHAKE_STRENGTH);

		let spellType = (SpellType)spell.type;

		switch(spellType) {
		case .Fire:
		case .Dasher:
			(*dir) *= -1;
			break;
		case .Electric:
			var movStat = entityRef.GetComponent<MovementStat>();
			Debug.Assert(movStat != null, "Firing electric spell from an entity without a movement state");
			movStat.stunTimeRemaining += SELF_STUN_TIME;
			break;
		default:
			Debug.Assert(false, "Illegal state");
			break;
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
		// TODO: Change this workaround for QueueDestroy
		for (uint64 ent in this.m_entitiesToDelete) {
			var ent = Scene.EntityFromIdUnchecked(this.m_scene, ent);
			Scene.DestroyEntity(this.m_scene, &ent);
		}

		this.m_entitiesToDelete.Clear();
	}
}
