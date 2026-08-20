namespace Hush;
using System;

[CRepr]
public struct Entity {
	public char8[8] m_member0;
	public char8[8] m_member1;

	public bool IsAlive() {
		return BeefHush.EngineDependencies.Instance.FunctionPointerTable.HushFuncPtr_Hush__Entity__IsAlive(&this);
	}

	public uint64 GetId() {
		return BeefHush.EngineDependencies.Instance.FunctionPointerTable.HushFuncPtr_Hush__Entity__GetId(&this);
	}

	public void AddRelationship(Entity* relationship, Entity* target) {
		BeefHush.EngineDependencies.Instance.FunctionPointerTable.HushFuncPtr_Hush__Entity__AddRelationship(&this, relationship, target);
	}

	public int32 GetChildCount() {
		return BeefHush.EngineDependencies.Instance.FunctionPointerTable.HushFuncPtr_Hush__Entity__GetChildCount(&this);
	}

	public void AddChild(Entity* child) {
		BeefHush.EngineDependencies.Instance.FunctionPointerTable.HushFuncPtr_Hush__Entity__AddChild(&this, child);
	}

	public void SetComponentActiveRaw(uint64 componentId, bool active) {
		BeefHush.EngineDependencies.Instance.FunctionPointerTable.HushFuncPtr_Hush__Entity__SetComponentActiveRaw(&this, componentId, active);
	}

	public bool RemoveComponentRaw(uint64 componentId) {
		return BeefHush.EngineDependencies.Instance.FunctionPointerTable.HushFuncPtr_Hush__Entity__RemoveComponentRaw(&this, componentId);
	}

	public void* EmplaceComponentRaw(uint64 componentId, uint64 componentSize, bool* isNew) {
		return BeefHush.EngineDependencies.Instance.FunctionPointerTable.HushFuncPtr_Hush__Entity__EmplaceComponentRaw(&this, componentId, componentSize, isNew);
	}

	public bool HasComponentRaw(uint64 componentId) {
		return BeefHush.EngineDependencies.Instance.FunctionPointerTable.HushFuncPtr_Hush__Entity__HasComponentRaw(&this, componentId);
	}

	public void* GetComponentRaw(uint64 componentId) {
		return BeefHush.EngineDependencies.Instance.FunctionPointerTable.HushFuncPtr_Hush__Entity__GetComponentRaw(&this, componentId);
	}

	public void* AddComponentRaw(uint64 componentId) {
		return BeefHush.EngineDependencies.Instance.FunctionPointerTable.HushFuncPtr_Hush__Entity__AddComponentRaw(&this, componentId);
	}

	public uint64 RegisterComponentRaw(ComponentTraits.ComponentInfo* desc) {
		return BeefHush.EngineDependencies.Instance.FunctionPointerTable.HushFuncPtr_Hush__Entity__RegisterComponentRaw(&this, desc);
	}
}
