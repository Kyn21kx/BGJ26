namespace BeefHush;

using System;

[HushComponent, CRepr]
public struct CanDrop
{
	public float dropChance;

	public this(float dropChance = 1f) {
		this.dropChance = dropChance;
	}
}
