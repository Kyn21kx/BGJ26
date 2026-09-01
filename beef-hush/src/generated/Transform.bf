namespace Hush;
using System;

[CRepr]
public struct Transform {
	public char8[64] m_member0;
	public char8[12] m_member1;
	public char8[16] m_member2;
	public char8[1] m_member3;

	public Vector3 Right() {
		Vector3 result = .();
		BeefHush.EngineDependencies.Instance.FunctionPointerTable.HushFuncPtr_Hush__Transform__RightOut(&this, &result);
		return result;
	}

	public Vector3 Up() {
		Vector3 result = .();
		BeefHush.EngineDependencies.Instance.FunctionPointerTable.HushFuncPtr_Hush__Transform__UpOut(&this, &result);
		return result;
	}

	public Vector3 Forward() {
		Vector3 result = .();
		BeefHush.EngineDependencies.Instance.FunctionPointerTable.HushFuncPtr_Hush__Transform__ForwardOut(&this, &result);
		return result;
	}

	public Vector3 GetEulerAngles() {
		Vector3 result = .();
		BeefHush.EngineDependencies.Instance.FunctionPointerTable.HushFuncPtr_Hush__Transform__GetEulerAnglesOut(&this, &result);
		return result;
	}

	public void SetEulerAngles(Vector3* euler) {
		BeefHush.EngineDependencies.Instance.FunctionPointerTable.HushFuncPtr_Hush__Transform__SetEulerAngles(&this, euler);
	}

	public void SetScale(Vector3 scale) {
		BeefHush.EngineDependencies.Instance.FunctionPointerTable.HushFuncPtr_Hush__Transform__SetScale(&this, scale);
	}

	public Vector3 GetScale() {
		Vector3 result = .();
		BeefHush.EngineDependencies.Instance.FunctionPointerTable.HushFuncPtr_Hush__Transform__GetScaleOut(&this, &result);
		return result;
	}

	public Vector3 GetPositionValue() {
		Vector3 result = .();
		BeefHush.EngineDependencies.Instance.FunctionPointerTable.HushFuncPtr_Hush__Transform__GetPositionValueOut(&this, &result);
		return result;
	}

	public Vector3* GetPosition() {
		return BeefHush.EngineDependencies.Instance.FunctionPointerTable.HushFuncPtr_Hush__Transform__GetPosition(&this);
	}

	public void SetPosition(Vector3 position) {
		BeefHush.EngineDependencies.Instance.FunctionPointerTable.HushFuncPtr_Hush__Transform__SetPosition(&this, position);
	}
}
