namespace BeefHush;

using Hush;
using System;
using System.Collections;

[RegisterSystem]
class InventorySystem : GameSystem
{
	private int32 slotsPerEntity = 3;
	private Query m_entityQuery;
	private float m_totalTime;
	
	public void Init(){
		QueryBuilder builder = .();
		//assumes only players have an inventory component, which is true for now :)
		builder.With<PlayerTag>();
		builder.With<Inventory>();
		builder.With<RigidBody>();
		m_entityQuery = builder.Build();

		m_entityQuery.Each<PlayerTag,Inventory>(scope (entityRef, tag, inventory) =>{
			inventory.maxSlotCapacity = slotsPerEntity;
			inventory.currentSlot = 0;
			inventory.spellList = .();
		});

	}

	public void OnShutdown(){
		
	}

	public void OnUpdate(float delta){

	}

	public static void fowardIndexInventory(BeefHush.Entity entityRef){
		Inventory* inventory = entityRef.GetComponent<Inventory>();
		inventory.currentSlot ++;
		//goes back to the first spell
		if(inventory.currentSlot > inventory.maxSlotCapacity){
			inventory.currentSlot = 0;
		}
	}

	public static void backwardIndexInventory(BeefHush.Entity entityRef){
		Inventory* inventory = entityRef.GetComponent<Inventory>();
		inventory.currentSlot --;
		//goes back to the last spell
		if(inventory.currentSlot < 0){
			inventory.currentSlot = inventory.maxSlotCapacity;
		}
	}

	public static void AddToSlot(Inventory* inv, Spell spell) {
    inv.spellList[inv.currentSlot] = spell;
    inv.currentSlot = (inv.currentSlot + 1) % inv.maxSlotCapacity; // 0 - 3
	}

	public void OnFixedUpdate(float delta){

	}
	
	public void OnPreRender(){

	}

	public void OnRender(){

	}


	public void OnPostRender(){

	}
}