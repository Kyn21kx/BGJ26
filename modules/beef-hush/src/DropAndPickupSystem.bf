namespace BeefHush;

using Hush;
using System;
using System.Collections;
using System.Diagnostics;

[RegisterSystem]
public class DropAndPickupSystem : GameSystem
{

	// Query all pickups at the scene and use the spatial graph to check if a player has picked them up
	Query m_pickups;
	Query m_lootDroppers;
	Query m_spellTemplates;
	private void* m_scene;
	private Random m_random;
	private static DropAndPickupSystem s_instance;

	private const StringView [(int32)EPickupType.MAX] availableLootModels = .("res://Smol Star.glb", "res://Smol Star.glb", "res://Smol Star.glb");
	private BeefHush.Entity [(int32)EPickupType.MAX] m_lootMeshes;

	private BeefHush.Entity m_renderingSystem;

	List<Spell> m_cachedSpellTemplates = new .() ~ delete _;


	public void Init() {
		s_instance = this;
		QueryBuilder builder = .();
		builder.With<Pickup>();
		builder.With<WorldTransform>();
		this.m_pickups = builder.Build();

		builder = .();
		builder.With<Spell>();
		builder.TemplatesOnly();
		this.m_spellTemplates = builder.Build();
		this.m_spellTemplates.Each<Spell>(scope (entity, spell) => {
			this.m_cachedSpellTemplates.Add(*spell);
		});

		this.m_scene = HushEngine.GetScene(EngineDependencies.Instance.Engine);
		this.m_random = new Random();

		uint64 pickupTerm = builder.With<Pickup>();
		// Whenever a new pickup spawns we assign a comp for it
		/*Scene.AddComponentObserverRaw(this.m_scene, pickupTerm, sizeof(Pickup), .EComponentObserverType_Add, (id, data) => {
			var pickup = (Pickup*)data;
			s_instance.FillPickup(id, pickup);
		});*/


		

		Query localPickupsQ = builder.Build();
		localPickupsQ.Each<Pickup>(scope (entityRef, pickup) => {
			this.FillPickup(entityRef.Id, pickup);
		});

		builder = .();
		EntityRegistry.s_CanDrop = builder.With<CanDrop>();
		builder.With<Health>();
		this.m_lootDroppers = builder.Build();
		this.m_lootDroppers.Each<CanDrop, Health>(scope (entityRef, canDrop, health) => {
			health.onKilled = => DropLoot;
		});
		this.InitializeMeshes();
	}

	public void InitializeMeshes() {
		const StringView renderSystemName = "RenderingSystem";
		this.m_renderingSystem = BeefHush.Entity(Scene.CreateEntityWithKey(this.m_scene, (char8*)renderSystemName.ToRawData().Ptr, (uint64)renderSystemName.Length));

		let handle = this.m_renderingSystem.GetComponent<RenderingSystemAPI>();
		for(uint64 index = 0; index < availableLootModels.Count; index++) {
			uint64 rootEntId = handle.instantiateMeshEntities(&(availableLootModels[index][0]), handle.instance);

			this.m_lootMeshes[index] = .(Scene.EntityFromIdUnchecked(this.m_scene, rootEntId));
			// Make it invisible, but the MeshReference Component is still there
			var localXform = this.m_lootMeshes[index].AddComponent<LocalTransform>();
			localXform.SetScale(Vector3.ZERO);
		}
	}


	private static void DropLoot(BeefHush.Entity* entity) {
		let dropInfo = entity.GetComponent<CanDrop>(EntityRegistry.s_CanDrop);
		if (dropInfo == null) {
			return;
		}
		// Generate a random pickup
		bool dropped = s_instance.m_random.NextDouble() <= dropInfo.dropChance;
		if (!dropped) {
			return;
		}

		// We drop loot, create a pickup entity
		int32 lootModelIdx = s_instance.m_random.Next(0, availableLootModels.Count);

		let handle = s_instance.m_renderingSystem.GetComponent<RenderingSystemAPI>();
		uint64 rootEntId = handle.instantiateMeshEntities(&(availableLootModels[lootModelIdx][0]), handle.instance);

		BeefHush.Entity ent = .(Scene.EntityFromIdUnchecked(s_instance.m_scene, rootEntId));
		let pickup = ent.AddComponent<Pickup>();
		// TODO: Randomize
		pickup.range = 0.5f;
		pickup.type = (int32)EPickupType.Spell;
		s_instance.FillPickup(ent.Id, pickup);

		let spawnerXform = entity.GetComponent<WorldTransform>();
		Vector3 targetPos = spawnerXform.GetPositionValue();
		var localXform = ent.GetComponent<LocalTransform>();
		localXform.SetPosition(targetPos);

		Oscillator* oscillator = ent.AddComponent<Oscillator>();
		Oscillator.PickupOscillator(oscillator);
		ent.SetName("LootPickup");
	}

	// Registers an observer that fills a pickup with a randomized spell component when it's added to the scene
	private void FillPickup(uint64 id, Pickup* pickup) {
		if ((EPickupType)pickup.type != .Spell) return;

		Console.WriteLine(scope $"Cached spells count: {this.m_cachedSpellTemplates.Count}");
		int32 idx = (int32)this.m_random.Next(0, this.m_cachedSpellTemplates.Count);
		BeefHush.Entity ent = .(Scene.EntityFromIdUnchecked(this.m_scene, id));
		var spellComp = ent.AddComponent<Spell>();
		*spellComp = this.m_cachedSpellTemplates[idx];
	}

	public void OnShutdown() {
		delete this.m_random;
	}

	private void OnPickedUp(BeefHush.Entity pickupEnt, Pickup* pickup, BeefHush.Entity playerEnt) {
		// Small trick, adds about 2 frames of destroy delay
		var lifetime = pickupEnt.AddComponent<Lifetime>();
		lifetime.remaining = 0;
		lifetime.initialLifetime = 0;
		let pickupType = (EPickupType)pickup.type;
		switch (pickupType) {
		case .Spell:
			// Get the payload of the spell through the desired component
			let spellComp = pickupEnt.GetComponent<Spell>();
			Debug.Assert(spellComp != null, "Spell component is not set on a spell pickup");
			// Add to the player's inventory
			let spellInv = playerEnt.GetComponent<SpellInventory>();
			// If the inventory is full, we override the current spell
			if (spellInv.allSpells.Count >= (int32)SpellType.MAX) {
				spellInv.allSpells[spellInv.activeSpellIdx] = *spellComp;
			}
			else {
				spellInv.allSpells.Add(*spellComp);
			}
			break;
		default:
			break;
		}
	}

	public void PickupSubsystem(BeefHush.Entity entityRef, Pickup* pickup, WorldTransform* worldXform) {
		// Get the amount of cells we need to travel
		int32 cellDepth = Math.Max((int32)(pickup.range / SpatialGrid.CELL_SIZE) - 1, 0);
		Vector3 currWorldPos = worldXform.GetPositionValue();
		PhysicsSystem.s_SpatialGrid.UntilNeighborAt(currWorldPos, cellDepth, 0, scope (neighborId) => {
			BeefHush.Entity neighbor = .(Scene.EntityFromIdUnchecked(this.m_scene, neighborId));
			if (!neighbor.HasComponent<PlayerTag>()) {
				return false;
			}
			let neighborWorldXform = neighbor.GetComponent<WorldTransform>();
			Vector3 neighborPos = neighborWorldXform.GetPositionValue();
			float disSqr = (currWorldPos - neighborPos).length_squared();
			// Absorb the pickup
			if (disSqr <= pickup.range) {
				OnPickedUp(entityRef, pickup, neighbor);
				return true;
			}
			return false;
		});
	}

	public void OnUpdate(float delta) {
		this.m_pickups.Each<Pickup, WorldTransform>(scope => this.PickupSubsystem);
	}

	public void OnFixedUpdate(float delta) {
		
	}

	public void OnRender() {
		
	}

	public void OnPreRender() {
		
	}

	public void OnPostRender() {
		
	}

}
