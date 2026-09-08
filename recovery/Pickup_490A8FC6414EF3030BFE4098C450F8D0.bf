namespace BeefHush;

using System;


enum EMesh{
	Box = 0,
	Kalaka = 1,
}

// A pickup entity needs this Pickup comp, a mesh (MeshReference + LocalTransform + WorldTransform),
// and an AABB (RigidBody + Collider) so the physics system can detect the player colliding with it.

[HushComponent, CRepr]
public struct PickUp
{
		public StringView meshPath;
		public float scale;
		public float pickupRange;

		public this(StringView meshPath = "res:\\Box.glb",  float scale = 1f, float range = 4f){
			this.meshPath = meshPath;
			this.pickupRange = range;
			this.scale = scale;
		}

		//Comparing strings is a lil sus, but it is what it is
		public Spell toSpell(){
			if(this.meshPath == "res:\\Box.glb"){
				return Spell.makeBox();
			}

			return .();
		}
	}
