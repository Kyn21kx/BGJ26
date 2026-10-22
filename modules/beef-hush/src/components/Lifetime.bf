namespace BeefHush;

using Hush;
using System;

[HushComponent, CRepr]
struct Lifetime
{
	// ENGINE: This should be a functionality of the engine
	public function void(uint64) onQueueDestroyHook;
	public float remaining;
	public float initialLifetime;
}

[HushComponent, CRepr]
struct DecreaseScaleData // To be used in the lifetime system to reduce scale over time
{
	public Vector3 originalScale;
}
