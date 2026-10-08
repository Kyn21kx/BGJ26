namespace Hush;
using System;
public static class ReflectionDB {

		public static uint8 RegisterForeignClass(void* self, char8* nameData, uint64 nameSize, uint64 size, uint64 alignment, uint64 module) {
			return BeefHush.EngineDependencies.Instance.FunctionPointerTable.HushFuncPtr_Hush__Reflection__ReflectionDB__RegisterForeignClass(self, nameData, nameSize, size, alignment, module);
		}

}