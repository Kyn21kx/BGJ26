namespace BeefHush;

using Hush;
using System;

struct Ray {
	public Vector3 origin;
	public Vector3 direction;

	public bool Intersects(in AABB test, out float hitDistance) {
		Vector3 inverseDir = 1.0f / this.direction;
		Vector3 t0 = (test.min - this.origin) * inverseDir;
		Vector3 t1 = (test.max - this.origin) * inverseDir;

		vec3 tMin = Math.Min(t0, t1);
		vec3 tMax = Math.Max(t0, t1);

		float tNear = Math.Max(max(tMin.x, tMin.y), tMin.z);
		float tFar  = Math.Min(min(tMax.x, tMax.y), tMax.z);

		// Check if box is missed
		if (tNear > tFar || tFar < 0.0) return false;

		hitDistance = tNear; // Returns distance along the ray
		return true;
	}
}

