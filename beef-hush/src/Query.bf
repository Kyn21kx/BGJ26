namespace BeefHush;

using System;
using System.Collections;
using Hush;

public struct QueryBuilder {
	const uint64 MAX_TERMS = 32; // Comes from flecs' docs
	uint8 m_termCount;
	OpaqueQueryDescriptor m_opaqueDesc;

	public this(params uint64[] ids) {
		this.m_opaqueDesc = .();
		this.m_termCount = 0;
		uint64[2] testIds = .();
 		QueryBuilderImpl.InitDescriptor(this.m_opaqueDesc.data(), &testIds[0], 0);
	}

	public Query Build() {
		Query result = .();
		void* scene = HushEngine.GetScene(EngineDependencies.Instance.Engine);
		result.[Friend]m_innerQuery = QueryBuilderImpl.InitQuery(scene, this.m_opaqueDesc.data());
		return result;
	}

	public uint64 With<T>() mut {
		void* scene = HushEngine.GetScene(EngineDependencies.Instance.Engine);
		let buff = scope String(64);
		ComponentTraits.ComponentInfo compInfo = TypeUtils.GetComponentInfo<T>(buff);
		
		uint64 term = Scene.Lookup(scene, buff.CStr(), (uint64)buff.Length);

		if (term == 0) {
			ComponentTraits.ComponentInfo compInfo = TypeUtils.GetComponentInfo<T>(buff);
			term = Scene.RegisterComponentRaw(scene, &compInfo);
		}
		QueryBuilderImpl.WithTerm(this.m_opaqueDesc.data(), &this.m_termCount, term);
		return term;
	}

	public uint64 Without<T>() mut {
		void* scene = HushEngine.GetScene(EngineDependencies.Instance.Engine);
		let buff = scope String(64);
		ComponentTraits.ComponentInfo compInfo = TypeUtils.GetComponentInfo<T>(buff);
		
		uint64 term = Scene.Lookup(scene, buff.CStr(), (uint64)buff.Length);

		if (term == 0) {
			ComponentTraits.ComponentInfo compInfo = TypeUtils.GetComponentInfo<T>(buff);
			term = Scene.RegisterComponentRaw(scene, &compInfo);
		}
		QueryBuilderImpl.Without(this.m_opaqueDesc.data(), &this.m_termCount, term);
		return term;
	}


	public uint64 WithAsName<T>(StringView name) mut {
		let buff = scope String(64);
		buff.Append(name);
		void* scene = HushEngine.GetScene(EngineDependencies.Instance.Engine);
		uint64 term = 0;
		term = Scene.Lookup(scene, buff.CStr(), (uint64)buff.Length);

		if (term == 0) {
			ComponentTraits.ComponentInfo compInfo = TypeUtils.GetComponentInfo<T>(buff, true);
			term = Scene.RegisterComponentRaw(scene, &compInfo);
		}
		QueryBuilderImpl.WithTerm(this.m_opaqueDesc.data(), &this.m_termCount, term);
		return term;
	}
}

public struct Query {

	// TODO: Generate these
	public delegate void OnEachCallback<T1>(BeefHush.Entity entityRef, T1* arg1);
	public delegate void OnEachCallback<T1, T2>(BeefHush.Entity entityRef, T1* arg1, T2* arg2);
	public delegate void OnEachCallback<T1, T2, T3>(BeefHush.Entity entityRef, T1* arg1, T2* arg2, T3* arg3);
	public delegate void OnEachCallback<T1, T2, T3, T4>(BeefHush.Entity entityRef, T1* arg1, T2* arg2, T3* arg3, T4* arg4);

	private RawQuery m_innerQuery;

	// Counts the entities currently matching this query without invoking any
	// callback. Safe to call before mutating the world.
	public uint64 Count() {
		let iterator = this.m_innerQuery.GetIterator();
		uint64 count = 0;
		while (iterator.Next()) {
			count += iterator.Size();
		}
		return count;
	}

	public void EachEntity(delegate void(BeefHush.Entity entityRef) callable) {
		let iterator = this.m_innerQuery.GetIterator();
		void* engine = EngineDependencies.Instance.Engine;
		void* scene = EngineDependencies.Instance.FunctionPointerTable.HushFuncPtr_Hush__HushEngine__GetScene(engine);
		while (iterator.Next()) {
			uint64 size = iterator.Size();
			for (uint64 i = 0; i < size; i++) {
				uint64 entityId = iterator.GetEntityAt(i);
				Hush.Entity currEntity = Scene.EntityFromIdUnchecked(scene, entityId);
				callable(BeefHush.Entity(currEntity));
			}
		}
	}

	public void Each<T1>(OnEachCallback<T1> callable) {
		let iterator = this.m_innerQuery.GetIterator();
		void* engine = EngineDependencies.Instance.Engine;
		void* scene = EngineDependencies.Instance.FunctionPointerTable.HushFuncPtr_Hush__HushEngine__GetScene(engine);
		while (iterator.Next()) {
			uint64 size = iterator.Size();
			for (uint64 i = 0; i < size; i++) {
				uint64 entityId = iterator.GetEntityAt(i);
				Hush.Entity currEntity = Scene.EntityFromIdUnchecked(scene, entityId);
				callable(BeefHush.Entity(currEntity), &((T1*)iterator.GetComponentAt(0, (uint64)sizeof(T1)))[i]);
			}
		}
	}

	public void Each<T1, T2>(OnEachCallback<T1, T2> callable) {
		let iterator = this.m_innerQuery.GetIterator();
		void* engine = EngineDependencies.Instance.Engine;
		void* scene = EngineDependencies.Instance.FunctionPointerTable.HushFuncPtr_Hush__HushEngine__GetScene(engine);
		while (iterator.Next()) {
			uint64 size = iterator.Size();
			for (uint64 i = 0; i < size; i++) {
				uint64 entityId = iterator.GetEntityAt(i);
				Hush.Entity currEntity = Scene.EntityFromIdUnchecked(scene, entityId);
				callable(
					BeefHush.Entity(currEntity),
					&((T1*)iterator.GetComponentAt(0, (uint64)sizeof(T1)))[i],
					&((T2*)iterator.GetComponentAt(1, (uint64)sizeof(T2)))[i]
				);
			}
		}
	}


	public void Each<T1, T2, T3>(OnEachCallback<T1, T2, T3> callable) {
		let iterator = this.m_innerQuery.GetIterator();
		void* engine = EngineDependencies.Instance.Engine;
		void* scene = EngineDependencies.Instance.FunctionPointerTable.HushFuncPtr_Hush__HushEngine__GetScene(engine);
		while (iterator.Next()) {
			uint64 size = iterator.Size();
			for (uint64 i = 0; i < size; i++) {
				uint64 entityId = iterator.GetEntityAt(i);
				Hush.Entity currEntity = Scene.EntityFromIdUnchecked(scene, entityId);
				callable(
					BeefHush.Entity(currEntity),
					&((T1*)iterator.GetComponentAt(0, (uint64)sizeof(T1)))[i],
					&((T2*)iterator.GetComponentAt(1, (uint64)sizeof(T2)))[i],
					&((T3*)iterator.GetComponentAt(2, (uint64)sizeof(T3)))[i]
				);
			}
		}
	}
	


	public void Each<T1, T2, T3, T4>(OnEachCallback<T1, T2, T3, T4> callable) {
		let iterator = this.m_innerQuery.GetIterator();
		void* engine = EngineDependencies.Instance.Engine;
		void* scene = EngineDependencies.Instance.FunctionPointerTable.HushFuncPtr_Hush__HushEngine__GetScene(engine);
		while (iterator.Next()) {
			uint64 size = iterator.Size();
			for (uint64 i = 0; i < size; i++) {
				uint64 entityId = iterator.GetEntityAt(i);
				Hush.Entity currEntity = Scene.EntityFromIdUnchecked(scene, entityId);
				callable(
					BeefHush.Entity(currEntity),
					&((T1*)iterator.GetComponentAt(0, (uint64)sizeof(T1)))[i],
					&((T2*)iterator.GetComponentAt(1, (uint64)sizeof(T2)))[i],
					&((T3*)iterator.GetComponentAt(2, (uint64)sizeof(T3)))[i],
					&((T4*)iterator.GetComponentAt(3, (uint64)sizeof(T4)))[i]
				);
			}
		}
	}
	

}

