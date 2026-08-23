namespace BeefHush;

using System;

[HushComponent, CRepr]
struct Spell
{
	float fireRate;
	float manaCost;
	float lastFireTime;
}