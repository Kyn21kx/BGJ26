namespace Hush;
using System;

[CRepr]
public enum EGamepadAxis : int32 {
	EGamepadAxis_Invalid = -1,
	EGamepadAxis_LeftX = 0,
	EGamepadAxis_LeftY = 1,
	EGamepadAxis_RightX = 2,
	EGamepadAxis_RightY = 3,
	EGamepadAxis_LeftTrigger = 4,
	EGamepadAxis_RightTrigger = 5,
	EGamepadAxis_Max = 6,
}
