namespace BeefHush;

using Hush;
using System;

[HushComponent, CRepr]
struct MovementStat {
	public float speed;
	public float slowFactor;
	public float slowTimeRemaining;
	public float stunTimeRemaining;
}


