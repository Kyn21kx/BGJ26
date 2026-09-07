namespace BeefHush;

using Hush;
using System;
using System.Collections;

[RegisterSystem]
public class HealthSystem : GameSystem {
	// public static Event<delegate void (uint64 damagedEntity, float damageAmount, uint64 damageSource)> OnDamageEvent = default;
	Query m_damagedEntities;
	List<uint64> m_entitiesToDestroy;
	float m_ellapsed;
	void* m_scene;

	public static void DamageEntity(void* scene, uint64 target, float damageAmount, uint64 source) {
		// Add a Damaged component, also add an animation maybe?
		BeefHush.Entity targetEnt = .(Scene.EntityFromIdUnchecked(scene, target));
		Damageable* damageList = null;
		if (targetEnt.HasComponent<Damageable>()) {
			damageList = targetEnt.GetComponent<Damageable>();
		}
		else {
			damageList = targetEnt.AddComponent<Damageable>();
			(*damageList) = .();
		}

		DamageEffect damageEffect = .(damageAmount, 0f, 1); // Instant damage

		// Find our insert node
		for (int32 i = 0; i < Damageable.MAX_DAMAGE_EFFECT_COUNT; i++) {
			var currEffect = &(damageList.effects[i]);
			if (currEffect.remainingDamage <= 0f) {
				(*currEffect) = damageEffect;
				break;
			}
		}
	}

	public void Init() {
		this.m_scene = HushEngine.GetScene(EngineDependencies.Instance.Engine);
		QueryBuilder builder = .();
		builder.With<Health>();
		builder.With<Damageable>();
		this.m_entitiesToDestroy = new .(64);
		this.m_damagedEntities = builder.Build();

		this.m_ellapsed = 0f;
	}

	/// OnShutdown() is called when the system is shutting down.
	public void OnShutdown() {
		delete this.m_entitiesToDestroy;
	}

	/// OnRender() is called when the system should render.
	/// @param delta Time since last frame
	public void OnUpdate(float delta) {
		this.m_ellapsed += delta; // Over here to handle immediate damages
		this.m_damagedEntities.Each<Health, Damageable>(scope (entityRef, health, damageable) => {
			if (health.value <= 0f) {
				// Die
				this.m_entitiesToDestroy.Add(entityRef.Id);
				return;
			}

			for (int32 i = 0; i < Damageable.MAX_DAMAGE_EFFECT_COUNT; i++) {
				DamageEffect* currEffect = &(damageable.effects[i]);
				if (currEffect.remainingDamage <= 0f) {
					return;
				}

				float diff = this.m_ellapsed - currEffect.lastTick;
				if (diff < currEffect.tickRate) {
					return;
				}

				currEffect.lastTick = this.m_ellapsed;
				// Apply our damage
				float tickDamage = (currEffect.totalDamage / (float)currEffect.tickCount);
				health.value -= tickDamage;
				currEffect.remainingDamage -= tickDamage;
				// Send our camera shake or something
			}
		});
	}

	/// OnFixedUpdate() is called when the system should update its state.
	/// @param delta Time since last fixed frame
	public void OnFixedUpdate(float delta) {
		
	}

	/// OnRender() is called when the system should render.
	public void OnRender() {
		
	}

	/// OnPreRender() is called before rendering.
	public void OnPreRender() {
		
	}

	/// OnPostRender() is called after rendering.
	public void OnPostRender() {
		// Workaround
		for (uint64 ent in this.m_entitiesToDestroy) {
			var toDestroy = Scene.EntityFromIdUnchecked(this.m_scene, ent);
			Scene.DestroyEntity(this.m_scene, &toDestroy);
		}
	}
	
}
