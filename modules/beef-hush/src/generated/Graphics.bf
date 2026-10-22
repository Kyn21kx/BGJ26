namespace Hush;
using System;

[CRepr]
public struct Graphics {

	[CRepr]
	public struct Material3D {
		public char8[24] m_member0;
		public char8[4] m_member1;
		public char8[72] m_member2;
		public char8[304] m_member3;
		public char8[40] m_member4;
		public char8[24] m_member5;
		public char8[64] m_member6;
		public char8[1] m_member7;
		public char8[24] m_member8;
		public char8[24] m_member9;
		public char8[4] m_member10;
		public char8[4] m_member11;
		public char8[1] m_member12;
		public char8[32] m_member13;
		public char8[24] m_member14;
		public char8[1] m_member15;

		public Graphics.Material3D.EError GetPropertyRaw(char8* nameData, uint64 nameSize, uint8* outValue, uint64 size) {
			return BeefHush.EngineDependencies.Instance.FunctionPointerTable.HushFuncPtr_Hush__Graphics__Material3D__GetPropertyRaw(&this, nameData, nameSize, outValue, size);
		}

		public Graphics.Material3D.EError SetPropertyRaw(char8* nameData, uint64 nameSize, uint8* valueData, uint64 valueSize) {
			return BeefHush.EngineDependencies.Instance.FunctionPointerTable.HushFuncPtr_Hush__Graphics__Material3D__SetPropertyRaw(&this, nameData, nameSize, valueData, valueSize);
		}

		[CRepr]
		public enum EError : int32 {
			EError_None = 0,
			EError_NullDevice = 1,
			EError_NullShaderModule = 2,
			EError_InvalidShaderModule = 3,
			EError_BindGroupLayoutCreationFailed = 4,
			EError_UniformBufferCreationFailed = 5,
			EError_BindGroupCreationFailed = 6,
			EError_PipelineCreationFailed = 7,
			EError_PropertyNotFound = 8,
			EError_OutOfBoundsRead = 9,
			EError_OutOfBoundsWrite = 10,
		}
	}
}
