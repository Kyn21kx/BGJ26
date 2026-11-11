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

	public static void PickupOscillator(Oscillator* osc) {
		osc.direction = 1;
		osc.speed = 1.0f;
		osc.heightMax = 1.0f;
		osc.heightMin = 0.2f;
	}

}

[HushComponent, CRepr]
struct TiltAnimation {
	// public float blend;
	public float duration;
	public float speed;
	public int direction;
}
