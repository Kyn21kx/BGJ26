namespace BeefHush;

using System;


// A pickup entity needs this Pickup comp, a mesh (MeshReference + LocalTransform + WorldTransform),
// and an AABB (RigidBody + Collider) so the physics system can detect the player colliding with it.

[HushComponent, CRepr]
public struct PickUp
{
		public StringView meshPath;
		public float scale;

		public this(StringView meshPath = "res:\\cube.glb", float scale = 1f)
		{
			this.meshPath = meshPath;
			this.scale = scale;
		}
	}
