namespace Hush;
using System;
public static class HushEngine {

	public static HushEngine.EError LoadScene(void* self, void* scene) {
		return BeefHush.EngineDependencies.Instance.FunctionPointerTable.HushFuncPtr_Hush__HushEngine__LoadScene(self, scene);
	}

	public static void* GetScene(void* self) {
		return BeefHush.EngineDependencies.Instance.FunctionPointerTable.HushFuncPtr_Hush__HushEngine__GetScene(self);
	}

	[CRepr]
	public enum EError : int32 {
		EError_None = 0,
		EError_InvalidScene = 1,
	}

}