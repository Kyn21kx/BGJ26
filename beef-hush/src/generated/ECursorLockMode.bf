namespace Hush;
using System;

[CRepr]
public enum ECursorLockMode : int32 {
	ECursorLockMode_Free = 0,
	ECursorLockMode_Locked = 1,
}
