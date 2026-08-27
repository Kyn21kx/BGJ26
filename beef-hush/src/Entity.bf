namespace BeefHush;

using System;

public struct Entity { //: BindingCompletenessCheck<Hush.Entity, Entity> {
	private Hush.Entity m_innerEntity;
	// private bool _IsBindingValid = AllMethodsCovered();

	// Cached to not have to go through 4 frames of the stack
	public uint64 Id { get; private set mut;}

	public int32 ChildCount => this.m_innerEntity.GetChildCount();

	private const int MAX_COMP_NAME = 64;

	public this() {
		this.m_innerEntity = .();
		this.Id = 0;
	}

	public this(Hush.Entity innerEntity) {
		this.m_innerEntity = innerEntity;
		this.Id = this.m_innerEntity.GetId();
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

	public Hush.Entity* InnerEntity() mut {
		return &this.m_innerEntity;
	}

	public T* AddComponent<T>() {
		uint64 compId = this.RegisterCompIfNeeded<T>();
		return (T*)this.m_innerEntity.AddComponentRaw(compId);
	}

	public T* GetComponent<T>() {
		uint64 compId = this.RegisterCompIfNeeded<T>();
		void* compMut = this.m_innerEntity.GetComponentRaw(compId);
		return (T*)compMut;
	}

	public T* GetComponent<T>(uint64 knownId) {
		void* compMut = this.m_innerEntity.GetComponentRaw(knownId);
		return (T*)compMut;
	}

	public bool RemoveComponent<T>() {
		uint64 compId = this.RegisterCompIfNeeded<T>();
		return this.m_innerEntity.RemoveComponentRaw(compId);
	}

	public T* GetComponentConst<T>() {
		uint64 compId = this.RegisterCompIfNeeded<T>();
		void* compConst = this.m_innerEntity.GetComponentConstRaw(compId);
		return (T*)compConst;
	}

	public T* GetComponentConstAsName<T>(StringView name) {
		uint64 compId = this.RegisterCompIfNeeded<T>(name);
		void* compConst = this.m_innerEntity.GetComponentConstRaw(compId);
		return (T*)compConst;
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

