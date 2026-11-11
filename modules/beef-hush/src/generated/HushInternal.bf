namespace Hush;
using System;

public static class Internal {
	public static uint64 QueryCompId<T>() {
		let buff = scope String(64);
		void* scene = Hush.HushEngine.GetScene(BeefHush.EngineDependencies.Instance.Engine);
		Hush.ComponentTraits.ComponentInfo compInfo = BeefHush.TypeUtils.GetComponentInfo<T>(buff);

		uint64 term = Hush.Scene.Lookup(scene, buff.CStr(), (uint64)buff.Length);
		if (term == 0) {
			term = Hush.Scene.RegisterComponentRaw(scene, &compInfo);
		}
		return term;
	}
}