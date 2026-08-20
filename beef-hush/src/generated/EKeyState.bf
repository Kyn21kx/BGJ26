namespace Hush;
using System;

[CRepr]
public enum EKeyState : int32 {
	EKeyState_None = -1,
	EKeyState_Pressed = 0,
	EKeyState_Held = 1,
	EKeyState_Released = 2,
}
