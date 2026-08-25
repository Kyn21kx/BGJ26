namespace Hush;
using System;

[CRepr]
public struct RenderingSystemAPI {
	public function uint64(char8* ,void*) instantiateMeshEntities;
	public void* instance;
}
