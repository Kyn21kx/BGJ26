namespace BeefHush;

using System;

public enum EPickupType : int32 {
	Spell = 0,
	PowerUp,
	Poison,
	MAX
}

[HushComponent, CRepr]
public struct Pickup
{
	public int32 type;
	public float range;
}

