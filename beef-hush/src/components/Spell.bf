namespace BeefHush;

using System;

[HushComponent, CRepr]
struct Spell
{
	public float fireRate;
	public float manaCost;
	public float lastFireTime;
}
