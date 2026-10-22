namespace BeefHush;

using System;


enum SpellType : int32 {
	Fire = 0,
	Electric = 1,
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
struct SpellInfo
{
	public uint64 casterEntity;
	public int32 type; // Maps to SpellType
	public bool isBadCast;
	// TODO: Add dmg here and in the component above
	// public uint64 damage;
}
