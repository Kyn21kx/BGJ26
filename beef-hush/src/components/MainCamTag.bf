namespace BeefHush;

using Hush;
using System;

[HushComponent, CRepr]
struct MainCamTag
{
	public float followSpeed;
	public float minHeight;
	public float shakeTimeRemaining;
	public float shakeStrength;
}
