namespace BeefHush;

using Hush;
using System;
using System.Collections;

[RegisterSystem]
class SpellSystem : GameSystem
{
	private const uint8 MAX_SPELL_MESH_COUNT = (uint8)SpellType.MAX;
	// NOTE: This should match the Spell's SpellType enum
	private const StringView [MAX_SPELL_MESH_COUNT] availableSpells = .("res://FireBallPURPLE.glb", "res://decahedron.glb");
	private Query m_fireSpellsQuery;
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
		builder = .();
		builder.With<Camera>();

		Query mainCamQ = builder.Build();
		mainCamQ.EachEntity(scope (entityRef) => {
		   this.m_mainCamEntity = entityRef;
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
			}
			else if (spellColl.collider.identifierTag == (int32)EEntityTag.EnemySpell && otherColl.collider.identifierTag == (int32)EEntityTag.Player) {
				// Damage the enemy
				HealthSystem.DamageEntity(this.m_scene, otherColl.id, 1.0f, spellColl.id);
				this.m_entitiesToDelete.Add(spellColl.id);
			}
			else if (otherColl.collider.identifierTag == (int32)EEntityTag.Wall) {
				// Do whatever the spell needs to do on collision, then delete it
				this.m_entitiesToDelete.Add(spellColl.id);
			}
		});
	}

	public void InitializeMeshes() {
		const StringView renderSystemName = "RenderingSystem";
		this.m_renderingSystem = BeefHush.Entity(Scene.CreateEntityWithKey(this.m_scene, (char8*)renderSystemName.ToRawData().Ptr, (uint64)renderSystemName.Length));
		
		let handle = this.m_renderingSystem.GetComponent<RenderingSystemAPI>();
		const StringView path = "res://FireBallPURPLE.glb";
		uint64 rootEntId = handle.instantiateMeshEntities(&(path[0]), handle.instance);

		for(uint64 index = 0; index < MAX_SPELL_MESH_COUNT; index++){
			uint64 rootEntId = handle.instantiateMeshEntities(&(availableSpells[index][0]), handle.instance);

			this.m_bulletsMeshRef[index] = .(Scene.EntityFromIdUnchecked(this.m_scene, rootEntId));
			// Make it invisible, but the MeshReference Component is still there
			// this.m_bulletsMeshRef[index].RemoveComponent<WorldTransform>();
			this.m_bulletsMeshRef[index].GetComponent<LocalTransform>().SetScale(Constants.Vector3_ONE * Constants.EPSILON);
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

	public static uint64 MakeSpell(SpellType type, int32 collIdentifier, Vector3 position, Vector3 direction, float speed, float range) {
		const Vector3 bulletScale = Constants.Vector3_ONE * 30.0f;
		// Slow path at instancing
		const StringView renderSystemName = "RenderingSystem";
		void* scene = HushEngine.GetScene(EngineDependencies.Instance.Engine);
		let renderingSystem = BeefHush.Entity(Scene.CreateEntityWithKey(scene, (char8*)renderSystemName.ToRawData().Ptr, (uint64)renderSystemName.Length));

		let handle = renderingSystem.GetComponent<RenderingSystemAPI>();
		StringView path = availableSpells[(int32)type];
		uint64 rootEntId = handle.instantiateMeshEntities(&(path[0]), handle.instance);

		let bulletRootEntity = BeefHush.Entity(Scene.EntityFromIdUnchecked(scene, rootEntId));
		var bulletXform = bulletRootEntity.GetComponent<LocalTransform>();
		bulletXform.SetScale(bulletScale);
		let collider = bulletRootEntity.AddComponent<Collider>();
		collider.identifierTag = collIdentifier;
		RigidBody* rig = bulletRootEntity.AddComponent<RigidBody>();
		*rig = .(); // Set default vals
		rig.aabb.pos = position; // + The direction offset
		rig.SetVelocity(direction * speed);
		rig.SetAngularVelocity(direction * speed * 1.5f);
		Lifetime* bulletLifetime = bulletRootEntity.AddComponent<Lifetime>();
		// t = d / V
		bulletLifetime.remaining = range / speed;

		// Add particle system
		ParticleEmitter* emitter = bulletRootEntity.AddComponent<ParticleEmitter>();
		(*emitter) = .();
		emitter.maxParticles = 500;
		emitter.maxScale = 0.2f;
		emitter.emitRadius = 0.3f;
		emitter.minScale = 0.1f;
		emitter.particleAssetId = 0; // This will depend on the spell type
		emitter.particleLifeTime = 1f;
		emitter.velocity = direction * -3.0f; // We could make them go slightly up to disappear
		emitter.velocity.y = 0.0f;
		emitter.emitRate = 0.01f;
		return rootEntId;
	}

	private void SpawnBullet(BeefHush.Entity* entityRef, RigidBody* spellRig, Spell* spell, Vector3 direction) {
		const StringView path = "res://decahedron.glb";

		castingSubSystem(entityRef, spell, &direction);
		MakeSpell((SpellType)spell.type, (int32)EEntityTag.Spell, spellRig.aabb.pos, direction, spell.projectileSpeed, spell.range);
	}

	public void OnUpdate(float delta)
	{
		this.m_totalTime += delta;
		this.ManaSubsystem(delta);
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

	public void castingSubSystem(BeefHush.Entity* entityRef, Spell* spell, Vector3* dir){
		if(spell.type == (int32)SpellType.Fire){
			//.nextdouble apparently returns from 0 to 1, so a range is not needed
			float roll = (float)this.m_random.NextDouble();

			if(roll < spell.badCastChance){
				dir.x = - 1;
			}

		}

		if(spell.type == (int32)SpellType.Electric){
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
		// Workaround
		for (uint64 ent in this.m_entitiesToDelete) {
			var ent = Scene.EntityFromIdUnchecked(this.m_scene, ent);
			Scene.DestroyEntity(this.m_scene, &ent);
		}

		this.m_entitiesToDelete.Clear();
	}
}
