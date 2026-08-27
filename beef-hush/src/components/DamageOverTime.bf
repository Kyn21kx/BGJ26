namespace BeefHush;

using Hush;
using System;

[HushComponent, CRepr]
struct DamageOverTimeEffect // Small tag on an entity that must have an xform and mesh reference
{
	public float tickRate = 0f;
	public float lastTick = 0f;
	public float remainingDamage = 0f;
}
