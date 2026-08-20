namespace BeefHush;

using System;

public static class TypeUtils {
	private const int MAX_COMP_NAME = 64;

	public static Hush.ComponentTraits.ComponentInfo GetComponentInfo<T>(String nameBuffer, bool overrideName = false) {
		if (!overrideName) {
			nameBuffer.Clear();
			typeof(T).GetName(nameBuffer);
		}
		var componentDesc = Hush.ComponentTraits.ComponentInfo();
		componentDesc.size = (uint64)sizeof(T);
		componentDesc.alignment = (uint64)alignof(T);
		componentDesc.name = nameBuffer.CStr();

		return componentDesc;
	}
}
