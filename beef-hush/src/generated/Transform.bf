namespace Hush;
using System;

[CRepr]
public struct Transform {
	public char8[64] m_member0;
	public char8[12] m_member1;
	public char8[16] m_member2;
	public char8[1] m_member3;

	public Matrix4 InvXForm(Transform* other) {
		return BeefHush.EngineDependencies.Instance.FunctionPointerTable.HushFuncPtr_Hush__Transform__InvXForm(&this, other);
	}

	public Matrix4 XForm(Transform* other) {
		return BeefHush.EngineDependencies.Instance.FunctionPointerTable.HushFuncPtr_Hush__Transform__XForm(&this, other);
	}

	public void GetTransformationMatrixUnsafe(float* outMatrix, uint64 count) {
		BeefHush.EngineDependencies.Instance.FunctionPointerTable.HushFuncPtr_Hush__Transform__GetTransformationMatrixUnsafe(&this, outMatrix, count);
	}

	public Matrix4 GetTransformationMatrix() {
		return BeefHush.EngineDependencies.Instance.FunctionPointerTable.HushFuncPtr_Hush__Transform__GetTransformationMatrix(&this);
	}

	public Vector3 Right() {
		return BeefHush.EngineDependencies.Instance.FunctionPointerTable.HushFuncPtr_Hush__Transform__Right(&this);
	}

	public Vector3 Up() {
		return BeefHush.EngineDependencies.Instance.FunctionPointerTable.HushFuncPtr_Hush__Transform__Up(&this);
	}

	public Vector3 Forward() {
		return BeefHush.EngineDependencies.Instance.FunctionPointerTable.HushFuncPtr_Hush__Transform__Forward(&this);
	}

	public Vector3 GetEulerAngles() {
		return BeefHush.EngineDependencies.Instance.FunctionPointerTable.HushFuncPtr_Hush__Transform__GetEulerAngles(&this);
	}

	public void SetEulerAngles(Vector3* euler) {
		BeefHush.EngineDependencies.Instance.FunctionPointerTable.HushFuncPtr_Hush__Transform__SetEulerAngles(&this, euler);
	}

	public Vector3 GetScale() {
		return BeefHush.EngineDependencies.Instance.FunctionPointerTable.HushFuncPtr_Hush__Transform__GetScale(&this);
	}

	public void SetScale(Vector3 scale) {
		BeefHush.EngineDependencies.Instance.FunctionPointerTable.HushFuncPtr_Hush__Transform__SetScale(&this, scale);
	}

	public Vector3 GetPositionValue() {
		return BeefHush.EngineDependencies.Instance.FunctionPointerTable.HushFuncPtr_Hush__Transform__GetPositionValue(&this);
	}

	public Vector3* GetPosition() {
		return BeefHush.EngineDependencies.Instance.FunctionPointerTable.HushFuncPtr_Hush__Transform__GetPosition(&this);
	}

	public void SetPosition(Vector3 position) {
		BeefHush.EngineDependencies.Instance.FunctionPointerTable.HushFuncPtr_Hush__Transform__SetPosition(&this, position);
	}
}
