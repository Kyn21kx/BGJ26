namespace BeefHush;

using System;
using System.Collections;


enum SpellType : int32 {
	None = -1,
	Fire = 0,
	Electric,
	Dasher,
	MAX
}

[HushComponent, CRepr]
struct Spell // TODO: Rename this to ActiveSpell or something
{
	//Naming is hard
	public int32 type;
	public float fireRate;
	public float manaCost;
	public float lastFireTime;
	public float projectileSpeed;
	public float range;
	//NOTE: This value must be normalized, it won't be checked during run time :)
	public float badCastChance;
}

[HushComponent, CRepr]
struct SpellInventory
{
	// TODO: Properly handle destructors here
	public List<Spell> allSpells; // If entry is empty, the spell is not unlocked
	public int32 activeSpellIdx;
}

[HushComponent, CRepr]
struct SpellInfo
{
	public uint64 casterEntity;
	public int32 type; // Maps to SpellType
	public bool isBadCast;
	// TODO: Add dmg here and in the component above
	// public uint64 damage;
}
