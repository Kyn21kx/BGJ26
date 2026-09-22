namespace BeefHush;

using System;


enum SpellType{
	Fire = 0,
	Electric =1
}

[HushComponent, CRepr]
struct Spell
{
	//Naming is hard
	public SpellType type;
	public float fireRate;
	public float manaCost;
	public float lastFireTime;
	public float projectileSpeed;
	public float range;
	public uint64 spellAssetId;
	//NOTE: This value must be normalized, it won't be checked during run time :)
	public float badCastChance;
}
