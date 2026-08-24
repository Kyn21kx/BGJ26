namespace Hush;
using System;


[CRepr]
extension Vector3 {

	public this(float x, float y, float z){
		 this.x = x;
		 this.y = y;
		 this.z = z;
	 }

	[Commutable]
	public static Vector3 operator+(Vector3 lhs, Vector3 rhs){
		return .(lhs.x + rhs.x, lhs.y + rhs.y, lhs.z + rhs.z);
	}

	public static Vector3 operator-(Vector3 lhs, Vector3 rhs){
		return .(lhs.x - rhs.x, lhs.y - rhs.y, lhs.z - rhs.z);
	}

	[Commutable]
	public static Vector3 operator*(Vector3 vec, float scale){
		return .(vec.x * scale, vec.y * scale, vec.z * scale);
	}

	[Commutable]
	public static Vector3 operator*(Vector3 lhs, Vector3 rhs){
		return .(lhs.x * rhs.x, lhs.y * rhs.y, lhs.z * rhs.z);
	}

	public static Vector3 operator/(Vector3 vec, float scale){
	return .(vec.x / scale, vec.y / scale, vec.z / scale);
	}

	public static Vector3 operator/(Vector3 dividend, Vector3 divisor){
		if (System.Math.Abs(divisor.x) < Constants.EPSILON ||
			System.Math.Abs(divisor.y) < Constants.EPSILON ||
			System.Math.Abs(divisor.z) < Constants.EPSILON
			){
				return Constants.Vector3_ZERO;
			}

		return .(dividend.x / divisor.x,
			 	 dividend.y / divisor.y,
				 dividend.z / divisor.z);
	}

	public  void operator+=(Vector3 rhs)mut{
		x += rhs.x;
		y += rhs.y;
		z += rhs.z;
	}

	public void operator-=(Vector3 rhs)mut{
		x -= rhs.x;
		y -= rhs.y;
		z -= rhs.z;
	}

	public void operator++()mut{
		x += 1.0f;
		y += 1.0f;
		z += 1.0f;
	}

	public void operator--()mut{
		x -= 1.0f;
		y -= 1.0f;
		z -= 1.0f;
	}

	//TODO(cris): Is there a cheaper way to compute this?
	[Commutable]
	public static bool operator==(Vector3 lhs, Vector3 rhs){
		return  ((float)System.Math.Abs(lhs.x - rhs.x) <= Constants.EPSILON) &&
				((float)System.Math.Abs(lhs.y - rhs.y) <= Constants.EPSILON) &&
				((float)System.Math.Abs(lhs.z - rhs.z) <= Constants.EPSILON);
	}

	public static bool operator!=(Vector3 lhs, Vector3 rhs){
		return !(lhs == rhs);
	}

	public float dot(Vector3 vec){
		return   (x * vec.x) +
				 (y * vec.y) +
				 (z * vec.z) ;
	}

	//NOTE(cris): As far as I know, check on both side is required
	public bool is_perpendicular_to(Vector3 vec, float epsilon = Constants.EPSILON){
		float dot = this.dot(vec);
		return (0.0f - epsilon <= dot) && (dot <=  0.0f + epsilon);
	}

	public bool is_parallel_to(Vector3 vec, float epsilon = Constants.EPSILON){
		Vector3 result = this.cross(vec);
		if( result.x < epsilon &&
			result.y < epsilon &&
			result.z < epsilon ){
				result = Constants.Vector3_ZERO;
		}
		return (result == Constants.Vector3_ZERO);
	}

	public Vector3 cross(Vector3 vec){
		return .( ((y * vec.z) - (z * vec.y)   ),
				  ((z * vec.x) - (x * vec.z)   ),
				  ((x * vec.y) - (y * vec.x))) ;
	}

	public float length(){
		return (float)System.Math.Sqrt((x * x) + (y * y) + ( z * z));
	}

	public float length_squared(){
		return ((x * x) + (y * y) + ( z * z));
	}

	public Vector3 normalize(float epsilon = Constants.EPSILON, Vector3 zero_guard = Constants.Vector3_ZERO){
		float length = this.length();
		if(length < epsilon){
			return zero_guard;
		}
		
		return .( x / length, y / length, z / length);
	}

	//NOTE(cris):length_squared == 1 might return false due to floating point behavior
	public bool is_normalized(float epsilon = Constants.EPSILON){
		return Math.Abs(this.length() - 1.0f) <= epsilon;
	}

	public float angle_between(Vector3 vec, float epsilon = Constants.EPSILON, float zero_guard = 0)
	{
		float product = this.length() * vec.length();
			if (product < epsilon){
					return zero_guard;
			}

		float cos = dot(vec) / product;
			if (cos > 1.0f){
					cos = 1.0f;
			}
			else if (cos < -1.0f){
					cos = -1.0f;
			}
		return (float)System.Math.Acos(cos);
	}

	//NOTE(cris): Assumes normal is normalized
	public Vector3 reflection_dir(Vector3 normal){
		//    R = I  -  2           (I.N)        N
		return (this - (2.0f * (this.dot(normal)) * normal));
	}

	public static float radians_to_degrees(float angle){
		return (angle * (180.0f / Constants.PI));
	}

	public static float degrees_to_radians(float angle){
		return (angle * (Constants.PI / 180.0f));
	}

}
