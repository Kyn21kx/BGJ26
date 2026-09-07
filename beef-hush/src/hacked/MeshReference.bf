namespace BeefHush;

using System;

[CRepr]
struct MeshReference : Hush.MeshReference
{
	// Target of 192 bytes
	uint8[36] hackedBytes;
}