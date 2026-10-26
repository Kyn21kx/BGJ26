namespace BeefHush;

using System;

public enum EPickupType {
	None = 0,
	Spell,
	PowerUp,
	Poison // ?
}

[HushComponent, CRepr]
public struct Pickup
{
	public int32 type;
	public float range;
}

