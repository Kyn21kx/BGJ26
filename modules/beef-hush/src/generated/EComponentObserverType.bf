namespace Hush;
using System;

[CRepr]
public enum EComponentObserverType : int32 {
	EComponentObserverType_Add = 0,
	EComponentObserverType_Remove = 1,
	EComponentObserverType_Set = 2,
}
