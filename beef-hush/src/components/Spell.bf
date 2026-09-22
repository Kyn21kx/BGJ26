namespace BeefHush;

using System;


enum SpellType : int32 {
	Fire = 0,
	Electric = 1,
	MAX
}

[HushComponent, CRepr]
struct Spell
{
	//Naming is hard
	public int32 type;
	public float fireRate;
	public float manaCost;
	public float lastFireTime;
	public float projectileSpeed;
	public float range;
	public uint64 spellAssetId;
	//NOTE: This value must be normalized, it won't be checked during run time :)
	public float badCastChance;
}
