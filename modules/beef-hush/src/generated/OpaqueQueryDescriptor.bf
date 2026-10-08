namespace Hush;
using System;

[CRepr]
public struct OpaqueQueryDescriptor {
	public char8[2440] m_member0;

	public uint8* data() {
		return BeefHush.EngineDependencies.Instance.FunctionPointerTable.HushFuncPtr_Hush__OpaqueQueryDescriptor__data(&this);
	}
}
