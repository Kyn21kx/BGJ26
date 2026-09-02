namespace Hush;
using System;
public static class Scene {

	public static RawQuery CreateRawQuery(void* self, uint64* componentsData, uint64 componentsSize, RawQuery.ECacheMode cacheMode) {
		RawQuery result = .();
		BeefHush.EngineDependencies.Instance.FunctionPointerTable.HushFuncPtr_Hush__Scene__CreateRawQueryOut(self, componentsData, componentsSize, cacheMode, &result);
		return result;
	}

	public static uint64 Lookup(void* self, char8* tagData, uint64 tagSize) {
		return BeefHush.EngineDependencies.Instance.FunctionPointerTable.HushFuncPtr_Hush__Scene__Lookup(self, tagData, tagSize);
	}

	public static void MarkComponentToggleableRaw(void* self, uint64 id) {
		BeefHush.EngineDependencies.Instance.FunctionPointerTable.HushFuncPtr_Hush__Scene__MarkComponentToggleableRaw(self, id);
	}

	public static uint64 RegisterComponentRaw(void* self, ComponentTraits.ComponentInfo* desc) {
		return BeefHush.EngineDependencies.Instance.FunctionPointerTable.HushFuncPtr_Hush__Scene__RegisterComponentRaw(self, desc);
	}

	public static Entity EntityFromIdUnchecked(void* self, uint64 id) {
		Entity result = .();
		BeefHush.EngineDependencies.Instance.FunctionPointerTable.HushFuncPtr_Hush__Scene__EntityFromIdUncheckedOut(self, id, &result);
		return result;
	}

	public static void DestroyEntity(void* self, Entity* entity) {
		BeefHush.EngineDependencies.Instance.FunctionPointerTable.HushFuncPtr_Hush__Scene__DestroyEntity(self, entity);
	}

	public static void AddComponentObserverRaw(void* self, uint64 componentId, uint64 componentSize, EComponentObserverType observerType, function void(uint64 ,void*) callback) {
		BeefHush.EngineDependencies.Instance.FunctionPointerTable.HushFuncPtr_Hush__Scene__AddComponentObserverRaw(self, componentId, componentSize, observerType, callback);
	}

	public static Entity CreateEntityWithKey(void* self, char8* keyData, uint64 keySize) {
		Entity result = .();
		BeefHush.EngineDependencies.Instance.FunctionPointerTable.HushFuncPtr_Hush__Scene__CreateEntityWithKeyOut(self, keyData, keySize, &result);
		return result;
	}

	public static Entity CreateEntityWithName(void* self, char8* nameData, uint64 nameSize) {
		Entity result = .();
		BeefHush.EngineDependencies.Instance.FunctionPointerTable.HushFuncPtr_Hush__Scene__CreateEntityWithNameOut(self, nameData, nameSize, &result);
		return result;
	}

	public static Entity CreateEntity(void* self) {
		Entity result = .();
		BeefHush.EngineDependencies.Instance.FunctionPointerTable.HushFuncPtr_Hush__Scene__CreateEntityOut(self, &result);
		return result;
	}

	public static void RemoveSystem(void* self, char8* nameData, uint64 nameSize) {
		BeefHush.EngineDependencies.Instance.FunctionPointerTable.HushFuncPtr_Hush__Scene__RemoveSystem(self, nameData, nameSize);
	}

}