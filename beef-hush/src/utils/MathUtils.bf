namespace BeefHush;

using System;

public static class MathUtils {

	public static float EaseInOut(float start, float end, float t)
	{
		var t;
	    t = Math.Clamp(t, 0, 1);

	    // Apply an ease-in-out curve (smoothstep style)
	    t = t * t * (3f - 2f * t);

	    // Interpolate using the eased t
	    return Math.Lerp(start, end, t);
	}
}

