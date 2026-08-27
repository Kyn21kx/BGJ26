namespace BeefHush;

using Hush;
using System;

[RegisterSystem]
class SpellSystem : GameSystem
{
	private Query m_fireSpellsQuery;
	private Query m_manaQuery;
	private float m_totalTime;
	private void* m_scene;
	private BeefHush.Entity m_renderingSystem;
	private BeefHush.Entity m_bulletMeshRef;
	private BeefHush.Entity m_mainCamEntity;

	public void Init()
	{
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

		builder = .();
		builder.With<Camera>();

		Query mainCamQ = builder.Build();
		mainCamQ.EachEntity(scope (entityRef) => {
		   this.m_mainCamEntity = entityRef;
		});
	}

	public void InitializeMeshes() {
		const StringView renderSystemName = "RenderingSystem";
		this.m_renderingSystem = BeefHush.Entity(Scene.CreateEntityWithKey(this.m_scene, (char8*)renderSystemName.ToRawData().Ptr, (uint64)renderSystemName.Length));
		
		let handle = this.m_renderingSystem.GetComponent<RenderingSystemAPI>();
		const StringView path = "res://decahedron.glb";
		uint64 rootEntId = handle.instantiateMeshEntities(&(path[0]), handle.instance);

		this.m_bulletMeshRef = .(Scene.EntityFromIdUnchecked(this.m_scene, rootEntId));
		// Make it invisible, but the MeshReference Component is still there
		this.m_bulletMeshRef.RemoveComponent<WorldTransform>();
		this.m_bulletMeshRef.RemoveComponent<LocalTransform>();
	}

	public void OnShutdown()
	{
		Scene.DestroyEntity(this.m_scene, this.m_bulletMeshRef.InnerEntity());
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
		Console.WriteLine(scope $"MousePos: {mouseScreenPos}");
		// Find cam
		Camera* cam = this.m_mainCamEntity.GetComponent<Camera>();
		LocalTransform* xform = this.m_mainCamEntity.GetComponent<LocalTransform>();
		float[16] mat = .();
		xform.GetTransformationMatrixUnsafe(&(mat[0]), 16);
		Vector3 direction = .();
		Vector3 origin = cam.ScreenToWorldPosUnsafe(&(mat[0]), mouseScreenPos, &direction);
		Console.WriteLine(scope $"Origin: {origin}, Dir: {direction}");
		Vector3 worldPos = cam.ProjectPlanePosition(origin, direction, 0.0f);

		Console.WriteLine(scope $"World pos: {worldPos}");

		// Then we do dest - source
		return (worldPos - currPos).normalized();
	}

	public void OnUpdate(float delta)
	{
		this.m_totalTime += delta;
		this.ManaSubsystem(delta);
		const Vector3 bulletScale = Constants.Vector3_ONE * 30.0f;
		this.m_fireSpellsQuery.Each<Spell, Controller, ManaStat, RigidBody>(scope (entityRef, spell, controller, manaStat, spellRig) => {
			float diff = this.m_totalTime - spell.lastFireTime;
			// TODO: Make the component decide if this is a mouse button press or something else
			bool mouseWasPressed = InputManager.GetMouseButtonPressed((EMouseButton)controller.fire);
			if (mouseWasPressed && diff >= spell.fireRate && manaStat.currentMana >= spell.manaCost) {
				// Add a bullet mesh
				Console.WriteLine("Fired spell!");
				manaStat.currentMana -= spell.manaCost;
				spell.lastFireTime = this.m_totalTime;

				// Slow path at instancing
				let handle = this.m_renderingSystem.GetComponent<RenderingSystemAPI>();
				const StringView path = "res://decahedron.glb";
				uint64 rootEntId = handle.instantiateMeshEntities(&(path[0]), handle.instance);

				let bulletRootEntity = BeefHush.Entity(Scene.EntityFromIdUnchecked(this.m_scene, rootEntId));
				RigidBody* rig = bulletRootEntity.AddComponent<RigidBody>();
				var bulletXform = bulletRootEntity.GetComponent<LocalTransform>();
				bulletXform.SetScale(bulletScale);
				*rig = .(); // Set default vals
				rig.aabb.pos = spellRig.aabb.pos; // + The direction offset
				Vector3 shootDir = this.GetShootDirection(spellRig.aabb.pos);
				rig.SetVelocity(shootDir * spell.projectileSpeed);
				rig.SetAngularVelocity(shootDir * spell.projectileSpeed * 1.5f);
				Lifetime* bulletLifetime = bulletRootEntity.AddComponent<Lifetime>();
				// t = d / V
				bulletLifetime.remaining = spell.range / spell.projectileSpeed;
			}
		});

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
