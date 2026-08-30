namespace BeefHush;

using Hush;
using System;
using BeefHush.Collections;

[CRepr]
struct DamageEffect // Small tag on an entity that must have an xform and mesh reference
{
	public float tickRate = 0f;
	public float lastTick = 0f;
	public int32 tickCount = 0;
	public float totalDamage = 0f;
	public float remainingDamage = 0f;

	public this(float damage, float tickRate, int32 tickCount) {
		this.tickRate = tickRate;
		this.tickCount = tickCount;
		this.lastTick = 0f;
		this.remainingDamage = damage;
		this.totalDamage = damage;
	}
}

[HushComponent, CRepr]
struct Damageable
{
	public const int MAX_DAMAGE_EFFECT_COUNT = 32;
	public DamageEffect[MAX_DAMAGE_EFFECT_COUNT] effects;
}
