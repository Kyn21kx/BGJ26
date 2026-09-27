namespace BeefHush;

using Hush;
using System;

[HushComponent, CRepr]
struct MainCamTag
{
	public const float TRAUMA_EXP = 2.0f;
	public float followSpeed;
	public float minHeight;
	public float traumaDecayPerSecond;
	// Internal
	public float trauma;
	public float noiseSpeed;
	public float maxAngle;
	public float maxTranslation;

	// Just safer
	public void SetTrauma(float val) mut {
		this.trauma = Math.Clamp(val, 0f, 1f);
	}
}
