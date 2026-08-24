namespace BeefHush;

using Hush;
using System;

[HushComponent, CRepr]
struct Controller // All these come from Hush.EKeyCode, which uses i32 as underlying type
{
	public int32 up;
	public int32 down;
	public int32 left;
	public int32 right;
}