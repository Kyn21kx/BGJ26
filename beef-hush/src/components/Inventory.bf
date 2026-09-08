namespace BeefHush;

using Hush;
using System;
using System.Collections;

[HushComponent, CRepr]
struct Inventory
{
	public int32 maxSlotCapacity;
	public int32 currentSlot;
	public Spell [3] spellList; 
}

