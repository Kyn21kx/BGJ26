namespace BeefHush;

using Hush;
using System;

[HushComponent, CRepr]
struct AimGuide // Small tag on an entity that must have an xform and mesh reference
{
	public float depth = 0f;
}
