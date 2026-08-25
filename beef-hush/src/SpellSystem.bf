namespace BeefHush;

using Hush;
using System;

[RegisterSystem]
class SpellSystem : GameSystem
{
	private Query m_fireSpellsQuery;
	private float m_totalTime;
	private void* m_scene;
	private BeefHush.Entity m_renderingSystem;

	public void Init()
	{
		this.m_totalTime = 0f;
		QueryBuilder builder = .();
		builder.With<Spell>();
		builder.With<Controller>();
		builder.With<ManaStat>();
		this.m_fireSpellsQuery = builder.Build();
		this.m_scene = HushEngine.GetScene(EngineDependencies.Instance.Engine);
		const StringView renderSystemName = "RenderingSystem";
		this.m_renderingSystem = BeefHush.Entity(Scene.CreateEntityWithKey(this.m_scene, (char8*)renderSystemName.ToRawData().Ptr, (uint64)renderSystemName.Length));
		// Make sure we properly initialize this
		this.m_fireSpellsQuery.Each<Spell>(scope (entityRef, spell) => {
			spell.lastFireTime = 0f;
		});

	}

	public void OnShutdown()
	{

	}

	public void OnUpdate(float delta)
	{
		this.m_totalTime += delta;
		this.m_fireSpellsQuery.Each<Spell, Controller, ManaStat>(scope (entityRef, spell, controller, manaStat) => {
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
				const StringView path = "res://Box.glb";
				uint64 rootEntId = handle.instantiateMeshEntities(&(path[0]), handle.instance);

				let bulletRootEntity = BeefHush.Entity(Scene.EntityFromIdUnchecked(this.m_scene, rootEntId));
				RigidBody* rig = bulletRootEntity.AddComponent<RigidBody>();
				*rig = .(); // Set default vals
				rig.SetVelocity(.(1, 0, 0) * spell.projectileSpeed);
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
