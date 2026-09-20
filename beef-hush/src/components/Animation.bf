namespace BeefHush;

using System;
using Hush;

[HushComponent, CRepr]
struct Oscillator {
	public float speed;
	public float blend;
	public float heightMax;
	public float heightMin;
	public int direction;
}

[HushComponent, CRepr]
struct TiltAnimation {
	// public float blend;
	public float duration;
	public float speed;
	public int direction;
}
