namespace BeefHush;

using System;

public struct Entity { //: BindingCompletenessCheck<Hush.Entity, Entity> {
	private Hush.Entity m_innerEntity;
	// private bool _IsBindingValid = AllMethodsCovered();

	public uint64 Id => this.m_innerEntity.GetId();

	public int32 ChildCount => this.m_innerEntity.GetChildCount();

	private const int MAX_COMP_NAME = 64;

	public this() {
		this.m_innerEntity = .();
	}

	public this(Hush.Entity innerEntity) {
		this.m_innerEntity = innerEntity;
	}

	private uint64 RegisterCompIfNeeded<T>() {
		let buff = scope String(MAX_COMP_NAME);

		void* scene = Hush.HushEngine.GetScene(EngineDependencies.Instance.Engine);
		Hush.ComponentTraits.ComponentInfo compInfo = TypeUtils.GetComponentInfo<T>(buff);

		uint64 term = 0;
		term = Hush.Scene.Lookup(scene, buff.CStr(), (uint64)buff.Length);

		if (term == 0) {
			term = Hush.Scene.RegisterComponentRaw(scene, &compInfo);
		}
		
		return term;
	}

	private uint64 RegisterCompIfNeeded<T>(StringView name) {
		let buff = scope String(MAX_COMP_NAME);
		buff.Append(name);

		void* scene = Hush.HushEngine.GetScene(EngineDependencies.Instance.Engine);
		
		uint64 term = 0;
		term = Hush.Scene.Lookup(scene, buff.CStr(), (uint64)buff.Length);

		if (term == 0) {
			Hush.ComponentTraits.ComponentInfo compInfo = TypeUtils.GetComponentInfo<T>(buff, true);
			term = Hush.Scene.RegisterComponentRaw(scene, &compInfo);
		}
		
		return term;
	}

	public void AddComponent<T>() {
		uint64 compId = this.RegisterCompIfNeeded<T>();
		this.m_innerEntity.AddComponentRaw(compId);
	}

	public T* GetComponent<T>() {
		uint64 compId = this.RegisterCompIfNeeded<T>();
		void* compMut = this.m_innerEntity.GetComponentRaw(compId);
		return (T*)compMut;
	}

	public T* GetComponentAsName<T>(StringView name) {
		uint64 compId = this.RegisterCompIfNeeded<T>(name);
		void* compMut = this.m_innerEntity.GetComponentRaw(compId);
		return (T*)compMut;
	}

	public void AddChild(ref Entity entity) {
		this.m_innerEntity.AddChild(&entity.m_innerEntity);
	}

}

