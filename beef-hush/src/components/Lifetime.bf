namespace BeefHush;

using Hush;
using System;

[HushComponent, CRepr]
struct Lifetime
{
	public float remaining;
	public float initialLifetime;
}

[HushComponent, CRepr]
struct DecreaseScaleData // To be used in the lifetime system to reduce scale over time
{
	public Vector3 originalScale;
}
