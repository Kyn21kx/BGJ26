namespace BeefHush;

using System;

[CRepr]
struct WorldTransform : Hush.Transform
{
	// HACK: The generation code exports transforms as 93 instead of 96 bytes
	char8[3] hackedBytes;
}
[CRepr]
struct LocalTransform : Hush.Transform {
	char8[3] hackedBytes;
}