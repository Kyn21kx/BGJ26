namespace BeefHush;

using Hush;
using System;

[RegisterSystem]
class SpellSystem : GameSystem
{
	private Query m_fireSpellsQuery;
	private float m_totalTime;

	public void Init()
	{
		this.m_totalTime = 0f;
		QueryBuilder builder = .();
		builder.With<Spell>();
		builder.With<Controller>();
		builder.With<ManaStat>();
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
			bool mouseWasPressed = InputManager.GetMouseButtonPressed((EMouseButton)controller.fire);
			if (mouseWasPressed && diff >= spell.fireRate && manaStat.currentMana >= spell.manaCost) {
				// Add a bullet mesh
				Console.WriteLine("Fired spell!");
				manaStat.currentMana -= spell.manaCost;
				spell.lastFireTime = this.m_totalTime;
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
