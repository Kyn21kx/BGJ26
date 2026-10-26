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
	private void* m_scene;


	public void Init() {
		QueryBuilder builder = .();
		builder.With<Pickup>();
		builder.With<WorldTransform>();
		this.m_pickups = builder.Build();

		this.m_scene = HushEngine.GetScene(EngineDependencies.Instance.Engine);
	}

	public void OnShutdown() {
		
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


	public void OnUpdate(float delta) {
		this.m_pickups.Each<Pickup, WorldTransform>(scope (entityRef, pickup, worldXform) => {
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
			
		});
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
