namespace Hush;
using System;
public static class ReflectionDB {

		public static bool AddFieldToForeignClass(void* self, Reflection.TypeId classType, char8* fieldNameData, uint64 fieldNameSize, Reflection.TypeId type, uint64 offset) {
			return BeefHush.EngineDependencies.Instance.FunctionPointerTable.HushFuncPtr_Hush__Reflection__ReflectionDB__AddFieldToForeignClass(self, classType, fieldNameData, fieldNameSize, type, offset);
		}

		public static uint8 RegisterForeignClass(void* self, char8* nameData, uint64 nameSize, uint64 size, uint64 alignment, uint64 module) {
			return BeefHush.EngineDependencies.Instance.FunctionPointerTable.HushFuncPtr_Hush__Reflection__ReflectionDB__RegisterForeignClass(self, nameData, nameSize, size, alignment, module);
		}

}