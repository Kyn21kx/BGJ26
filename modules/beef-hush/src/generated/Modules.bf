namespace Hush;
using System;
public static class Modules {

	public static bool CopyReflectedTypeMetadataValue(void* engine, uint64 typeId, char8* keyData, uint64 keySize, char8* destination, uint32 destinationSize) {
		return BeefHush.EngineDependencies.Instance.FunctionPointerTable.HushFuncPtr_Hush__Modules__CopyReflectedTypeMetadataValue(engine, typeId, keyData, keySize, destination, destinationSize);
	}

	public static uint32 GetReflectedTypeMetadataValueLength(void* engine, uint64 typeId, char8* keyData, uint64 keySize) {
		return BeefHush.EngineDependencies.Instance.FunctionPointerTable.HushFuncPtr_Hush__Modules__GetReflectedTypeMetadataValueLength(engine, typeId, keyData, keySize);
	}

	public static bool HasReflectedTypeMetadata(void* engine, uint64 typeId, char8* keyData, uint64 keySize) {
		return BeefHush.EngineDependencies.Instance.FunctionPointerTable.HushFuncPtr_Hush__Modules__HasReflectedTypeMetadata(engine, typeId, keyData, keySize);
	}

	public static bool CopyReflectedTypeName(void* engine, uint64 typeId, char8* destination, uint32 destinationSize) {
		return BeefHush.EngineDependencies.Instance.FunctionPointerTable.HushFuncPtr_Hush__Modules__CopyReflectedTypeName(engine, typeId, destination, destinationSize);
	}

	public static uint32 GetReflectedTypeNameLength(void* engine, uint64 typeId) {
		return BeefHush.EngineDependencies.Instance.FunctionPointerTable.HushFuncPtr_Hush__Modules__GetReflectedTypeNameLength(engine, typeId);
	}

	public static bool GetReflectedTypeOwner(void* engine, uint64 typeId, uint64* owner) {
		return BeefHush.EngineDependencies.Instance.FunctionPointerTable.HushFuncPtr_Hush__Modules__GetReflectedTypeOwner(engine, typeId, owner);
	}

	public static bool HasReflectedType(void* engine, uint64 typeId) {
		return BeefHush.EngineDependencies.Instance.FunctionPointerTable.HushFuncPtr_Hush__Modules__HasReflectedType(engine, typeId);
	}

	public static bool AddSystemToScene(void* engine, void* scene, uint64 module, uint64 typeId) {
		return BeefHush.EngineDependencies.Instance.FunctionPointerTable.HushFuncPtr_Hush__Modules__AddSystemToScene(engine, scene, module, typeId);
	}

	public static bool RegisterForeignSystem(void* engine, uint64 module, void* descriptor) {
		return BeefHush.EngineDependencies.Instance.FunctionPointerTable.HushFuncPtr_Hush__Modules__RegisterForeignSystem(engine, module, descriptor);
	}

	public static bool SetForeignSystemRuntimeOps(void* engine, uint64 module, void* ops) {
		return BeefHush.EngineDependencies.Instance.FunctionPointerTable.HushFuncPtr_Hush__Modules__SetForeignSystemRuntimeOps(engine, module, ops);
	}

}