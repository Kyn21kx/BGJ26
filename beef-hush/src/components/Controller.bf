namespace BeefHush;

using Hush;
using System;

[HushComponent, CRepr]
struct Controller // All these come from Hush.EKeyCode, which uses i32 as underlying type
{
	int32 up;
	int32 down;
	int32 left;
	int32 right;
}