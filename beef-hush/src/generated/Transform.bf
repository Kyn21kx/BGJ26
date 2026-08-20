namespace Hush;
using System;

[CRepr]
public struct Transform {
	public char8[64] m_member0;
	public char8[12] m_member1;
	public char8[16] m_member2;
	public char8[1] m_member3;

	public void SetPosition(Vector3 position) {
		BeefHush.EngineDependencies.Instance.FunctionPointerTable.HushFuncPtr_Hush__Transform__SetPosition(&this, position);
	}
}
