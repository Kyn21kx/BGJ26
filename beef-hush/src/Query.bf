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

	public void With<T>() mut {
		void* scene = HushEngine.GetScene(EngineDependencies.Instance.Engine);
		let buff = scope String(64);
		ComponentTraits.ComponentInfo compInfo = TypeUtils.GetComponentInfo<T>(buff);
		
		uint64 term = Scene.Lookup(scene, buff.CStr(), (uint64)buff.Length);

		if (term == 0) {
			ComponentTraits.ComponentInfo compInfo = TypeUtils.GetComponentInfo<T>(buff);
			term = Scene.RegisterComponentRaw(scene, &compInfo);
		}
		QueryBuilderImpl.WithTerm(this.m_opaqueDesc.data(), &this.m_termCount, term);
	}

	public void WithAsName<T>(StringView name) mut {
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
	}
}

public struct Query {

	private RawQuery m_innerQuery;

	public void Each(delegate void(BeefHush.Entity entityRef) callable) {
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

}

