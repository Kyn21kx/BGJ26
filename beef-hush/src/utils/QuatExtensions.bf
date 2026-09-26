namespace Hush;

using System;

extension Quat {
	
	public const Quat IDENTITY = .(0f, 0f, 0f, 1f);

	public this(float x, float y, float z, float w) {
		this.x = x;
		this.y = y;
		this.z = z;
		this.w = w;
	}
	
}
