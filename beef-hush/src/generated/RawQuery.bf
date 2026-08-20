namespace Hush;
using System;

[CRepr]
public struct RawQuery {
	public char8[8] m_member0;
	public char8[8] m_member1;

	public RawQuery.QueryIterator GetIterator() {
		return BeefHush.EngineDependencies.Instance.FunctionPointerTable.HushFuncPtr_Hush__RawQuery__GetIterator(&this);
	}

	public void* GetScene() {
		return BeefHush.EngineDependencies.Instance.FunctionPointerTable.HushFuncPtr_Hush__RawQuery__GetScene(&this);
	}

	[CRepr]
	public struct QueryIterator {
		public char8[384] m_member0;
		public char8[8] m_member1;
		public char8[1] m_member2;

		public uint64 GetEntityAt(uint64 index) {
			return BeefHush.EngineDependencies.Instance.FunctionPointerTable.HushFuncPtr_Hush__RawQuery__QueryIterator__GetEntityAt(&this, index);
		}

		public void* GetComponentAt(int8 index, uint64 size) {
			return BeefHush.EngineDependencies.Instance.FunctionPointerTable.HushFuncPtr_Hush__RawQuery__QueryIterator__GetComponentAt(&this, index, size);
		}

		public uint64 Size() {
			return BeefHush.EngineDependencies.Instance.FunctionPointerTable.HushFuncPtr_Hush__RawQuery__QueryIterator__Size(&this);
		}

		public bool Finished() {
			return BeefHush.EngineDependencies.Instance.FunctionPointerTable.HushFuncPtr_Hush__RawQuery__QueryIterator__Finished(&this);
		}

		public void Skip() {
			BeefHush.EngineDependencies.Instance.FunctionPointerTable.HushFuncPtr_Hush__RawQuery__QueryIterator__Skip(&this);
		}

		public bool Next() {
			return BeefHush.EngineDependencies.Instance.FunctionPointerTable.HushFuncPtr_Hush__RawQuery__QueryIterator__Next(&this);
		}
	}

	[CRepr]
	public enum EComponentAccess : int32 {
		EComponentAccess_ReadOnly = 0,
		EComponentAccess_WriteOnly = 1,
		EComponentAccess_ReadWrite = 2,
		EComponentAccess_Default = 2,
	}

	[CRepr]
	public enum ECacheMode : int32 {
		ECacheMode_Default = 0,
		ECacheMode_Auto = 1,
		ECacheMode_All = 2,
		ECacheMode_None = 3,
	}
}
