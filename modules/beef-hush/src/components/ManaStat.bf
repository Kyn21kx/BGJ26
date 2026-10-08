namespace BeefHush;

using Hush;
using System;

[HushComponent, CRepr]
struct ManaStat
{
	public float currentMana;
	public float regenerationRate;
}