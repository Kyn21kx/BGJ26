namespace Hush;
using System;
public static class RenderingSystemAPI {

	public static uint64 InstantiateMeshEntities(void* self, char8* virtualPathData, uint64 virtualPathSize) {
		return BeefHush.EngineDependencies.Instance.FunctionPointerTable.HushFuncPtr_Hush__RenderingSystemAPI__InstantiateMeshEntities(self, virtualPathData, virtualPathSize);
	}

}