namespace Hush;

using System;

[CRepr]
public struct AABB
{	
	public Vector3 size;
	public Vector3 pos;//center of the box

	public this(Vector3 size){
		this.size = size;
		this.pos = Constants.Vector3_ZERO;
	}

	public Vector3 min => pos - size / 2;
	public Vector3 max => pos + size / 2;

	public bool intersects(AABB test){
		return  (Math.Abs(pos.x - test.pos.x) <= (size.x + test.size.x) / 2) &&
				(Math.Abs(pos.y - test.pos.y) <= (size.y + test.size.y) / 2) &&
				(Math.Abs(pos.z - test.pos.z) <= (size.z + test.size.z) / 2);

	}

	public bool contains(Vector3 test){

		return  (test.x >= min.x) && (test.x <= max.x) &&
				(test.y >= min.y) && (test.y <= max.y) &&
				(test.z >= min.z) && (test.z <= max.z) ;
	}
}