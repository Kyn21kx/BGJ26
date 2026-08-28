namespace BeefHush;

using Hush;
using System;

struct Ray {
	public Vector3 origin;
	public Vector3 direction;

	public this(Vector3 origin, Vector3 direction) {
		this.origin = origin;
		this.direction = direction;
	}

	public bool Intersects(in AABB test, out float hitDistance) {
		hitDistance = 0f;
		Vector3 inverseDir = 1.0f / this.direction;
		Vector3 t0 = (test.min - this.origin) * inverseDir;
		Vector3 t1 = (test.max - this.origin) * inverseDir;

		Vector3 tMin = Vector3.Min(t0, t1);
		Vector3 tMax = Vector3.Max(t0, t1);

		float tNear = Math.Max(Math.Max(tMin.x, tMin.y), tMin.z);
		float tFar  = Math.Min(Math.Min(tMax.x, tMax.y), tMax.z);

		// Check if box is missed
		if (tNear > tFar || tFar < 0.0) return false;

		hitDistance = tNear; // Returns distance along the ray
		return true;
	}
}

