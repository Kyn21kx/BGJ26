namespace Hush;
using System;

[CRepr]
public struct MeshReference {
	public char8[24] m_member0;
	public char8[24] m_member1;
	public char8[24] m_member2;
	public char8[8] m_member3;
	public char8[8] m_member4;
	public char8[64] m_member5;
	public char8[4] m_member6;

	public void CalculateBounds(Vector3* outCenter, Vector3* outSize) {
		BeefHush.EngineDependencies.Instance.FunctionPointerTable.HushFuncPtr_Hush__MeshReference__CalculateBounds(&this, outCenter, outSize);
	}
}
