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
