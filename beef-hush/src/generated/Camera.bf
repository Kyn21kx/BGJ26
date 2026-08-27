namespace Hush;
using System;

[CRepr]
public struct Camera {
	public char8[4] m_member0;
	public char8[4] m_member1;
	public char8[8] m_member2;
	public char8[8] m_member3;
	public char8[4] m_member4;
	public char8[4] m_member5;
	public char8[64] m_member6;
	public char8[64] m_member7;

	public float GetFarPlane() {
		return BeefHush.EngineDependencies.Instance.FunctionPointerTable.HushFuncPtr_Hush__Camera__GetFarPlane(&this);
	}

	public Vector3 ProjectPlanePosition(Vector3 origin, Vector3 direction, float height) {
		return BeefHush.EngineDependencies.Instance.FunctionPointerTable.HushFuncPtr_Hush__Camera__ProjectPlanePosition(&this, origin, direction, height);
	}

	public Vector3 ScreenToWorldPosUnsafe(float* viewMatrix, Vector2 mousePos, Vector3* outDirection) {
		return BeefHush.EngineDependencies.Instance.FunctionPointerTable.HushFuncPtr_Hush__Camera__ScreenToWorldPosUnsafe(&this, viewMatrix, mousePos, outDirection);
	}

	public Vector3 ScreenToWorldPos(Matrix4 viewMatrix, Vector2 mousePos, Vector3* outDirection) {
		return BeefHush.EngineDependencies.Instance.FunctionPointerTable.HushFuncPtr_Hush__Camera__ScreenToWorldPos(&this, viewMatrix, mousePos, outDirection);
	}
}
