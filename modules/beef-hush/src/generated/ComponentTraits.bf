namespace Hush;
using System;

[CRepr]
public struct ComponentTraits {
	public const int32 EComponentOpsFlags_NoMoveAssignDtor = 262144;
	public const int32 EComponentOpsFlags_NoMoveDtor = 131072;
	public const int32 EComponentOpsFlags_NoMoveCtor = 65536;
	public const int32 EComponentOpsFlags_NoCopyCtor = 32768;
	public const int32 EComponentOpsFlags_NoMove = 16384;
	public const int32 EComponentOpsFlags_NoCopy = 8192;
	public const int32 EComponentOpsFlags_NoDtor = 4096;
	public const int32 EComponentOpsFlags_NoCtor = 1024;
	public const int32 EComponentOpsFlags_HasMoveAssignDtor = 128;
	public const int32 EComponentOpsFlags_HasMoveDtor = 64;
	public const int32 EComponentOpsFlags_HasMoveCtor = 32;
	public const int32 EComponentOpsFlags_HasCopyCtor = 16;
	public const int32 EComponentOpsFlags_HasMove = 8;
	public const int32 EComponentOpsFlags_HasCopy = 4;
	public const int32 EComponentOpsFlags_HasDtor = 2;
	public const int32 EComponentOpsFlags_HasCtor = 1;
	public const int32 EComponentOpsFlags_None = 0;

	[CRepr]
	public struct ComponentInfo {
		public uint64 size;
		public uint64 alignment;
		public char8* name;
		public ComponentTraits.ComponentOps ops;
		public uint32 opsFlags;
		public void* userCtx;
		public function void(void*) userCtxFree;
	}

	[CRepr]
	public struct ComponentOps {
		public function void(void* ,int32 ,void*) ctor;
		public function void(void* ,int32 ,void*) dtor;
		public function void(void* ,void* ,int32 ,void*) copy;
		public function void(void* ,void* ,int32 ,void*) move;
		public function void(void* ,void* ,int32 ,void*) copyCtor;
		public function void(void* ,void* ,int32 ,void*) moveCtor;
		public function void(void* ,void* ,int32 ,void*) moveDtor;
		public function void(void* ,void* ,int32 ,void*) moveAssignDtor;
	}
}
