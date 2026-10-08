namespace Hush;
using System;

[CRepr]
public struct Reflection {
	public const int32 ERegisterClassError_DuplicateType = 1;
	public const int32 ERegisterClassError_None = 0;

	[CRepr]
	public struct TypeInfo {
		public char8[8] m_member0;
		public char8[8] m_member1;
		public char8[24] m_member2;
		public char8[24] m_member3;
		public char8[24] m_member4;
		public char8[24] m_member5;
		public char8[32] m_member6;
		public char8[8] m_member7;
		public char8[8] m_member8;

		public void SetAlignment(uint64 alignment) {
			BeefHush.EngineDependencies.Instance.FunctionPointerTable.HushFuncPtr_Hush__Reflection__TypeInfo__SetAlignment(&this, alignment);
		}

		public void SetSize(uint64 size) {
			BeefHush.EngineDependencies.Instance.FunctionPointerTable.HushFuncPtr_Hush__Reflection__TypeInfo__SetSize(&this, size);
		}

		public void SetName(char8* nameData, uint64 nameSize) {
			BeefHush.EngineDependencies.Instance.FunctionPointerTable.HushFuncPtr_Hush__Reflection__TypeInfo__SetName(&this, nameData, nameSize);
		}
	}

	[CRepr]
	public struct FieldInfo {
		public char8[8] m_member0;
		public char8[32] m_member1;
		public char8[64] m_member2;
		public char8[64] m_member3;
		public char8[8] m_member4;
	}

	[CRepr]
	public struct ForeignVariant {
		public char8[40] m_member0;
	}
}
