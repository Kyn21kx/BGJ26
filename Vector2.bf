namespace Hush;
using System;


[CRepr]
extension Vector2 {

	public this(float x, float y){
		 this.x = x;
		 this.y = y;
	 }

	[Commutable]
	public static Vector2 operator+(Vector2 lhs, Vector2 rhs){
		return .(lhs.x + rhs.x, lhs.y + rhs.y);
	}

	public static Vector2 operator-(Vector2 lhs, Vector2 rhs){
		return .(lhs.x - rhs.x, lhs.y - rhs.y);
		
	}

	[Commutable]
	public static Vector2 operator*(Vector2 vec, float scale){
		return .(vec.x * scale, vec.y * scale);
	}

	[Commutable]
	public static Vector2 operator*(Vector2 lhs, Vector2 rhs){
		return .(lhs.x * rhs.x, lhs.y * rhs.y);
	}

	//NOTE(cris): Should I take care of division by zero?
	public static Vector2 operator/(Vector2 vec, float scale){

	return .(vec.x / scale, vec.y / scale);
	}

	public static Vector2 operator/(Vector2 dividend, Vector2 divisor){
		if (System.Math.Abs(divisor.x) < Constants.EPSILON ||
			System.Math.Abs(divisor.y) < Constants.EPSILON
			){
				return Constants.Vector2_ZERO;
			}

		return .(dividend.x / divisor.x,
			 	 dividend.y / divisor.y);
	}

	public  void operator+=(Vector2 rhs)mut{
		x += rhs.x;
		y += rhs.y;
	}

	public void operator-=(Vector2 rhs)mut{
		x -= rhs.x;
		y -= rhs.y;
	}

	public void operator++()mut{
		x += 1.0f;
		y += 1.0f;
	}

	public void operator--()mut{
		x -= 1.0f;
		y -= 1.0f;
	}

	//TODO(cris): Is there a cheaper way to compute this?
	[Commutable]
	public static bool operator==(Vector2 lhs, Vector2 rhs){
		return  (float (System.Math.Abs(lhs.x - rhs.x)) <= Constants.EPSILON) &&
				(float (System.Math.Abs(lhs.y - rhs.y)) <= Constants.EPSILON);
	}

	public static bool operator!=(Vector2 lhs, Vector2 rhs){
		return !(lhs == rhs);
	}

	public float dot(Vector2 vec){
		return   (x * vec.x) +
				 (y * vec.y) ;
	}

	//NOTE(cris): As far as I know, check on both side is required
	public bool is_perpendicular_to(Vector2 vec, float epsilon = Constants.EPSILON){
		float dot = this.dot(vec);
		return (0.0f - epsilon <= dot) && (dot <=  0.0f + epsilon);
	}

	public bool is_parallel_to(Vector2 vec, float epsilon = Constants.EPSILON){
		return Math.Abs(cross(vec)) <= epsilon;
	}

	public float cross(Vector2 vec){
		return .((this.x * vec.y) - (this.y * vec.x)  );
	}

	public float length(){
		return (float) System.Math.Sqrt((x * x) + (y * y));
	}

	public float length_squared(){
		return ((x * x) + (y * y));
	}

	public Vector2 normalize(float epsilon = Constants.EPSILON, Vector2 zero_guard = Constants.Vector2_ZERO){
		float length = this.length();
		if(length < epsilon){
			return zero_guard;
		}
		
		return .( x / length, y / length);
	}

	//NOTE(cris):length_squared == 1 might return false due to floating point behavior
	public bool is_normalized(float epsilon = Constants.EPSILON){
		return Math.Abs(this.length() - 1.0f) <= epsilon;
	}

	public float angle_between(Vector2 vec, float epsilon = Constants.EPSILON, float zero_guard = 0)
	{
		float product = this.length() * vec.length();
		if (product < epsilon){
			return zero_guard;
		}
		//NOTE(cris): clamp guards against FP rounding pushing cos outside [-1, 1] -> NaN
		float cos = dot(vec) / product;
		if (cos > 1.0f){
			cos = 1.0f;
		}
		else if (cos < -1.0f){
			cos = -1.0f;
		}

		return (float)System.Math.Acos(float(cos));
	}

	//NOTE(cris): Assumes normal is already normalized
	public Vector2 reflection_dir(Vector2 normal){
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
