namespace	BeefHush;
using Hush;
using System;

[HushComponent, CRepr]
public struct RigidBody
{
    public AABB aabb;
    public Vector3 vel;
    public Vector3 acc;

    public bool dynamic;

	public this(){
		this.aabb = default;
		this.vel = Constants.Vector3_ZERO;
		this.acc = Constants.Vector3_ZERO;
		this.dynamic = true;
	}

	public void Init(AABB bb,
		Vector3 vel = Constants.Vector3_ZERO,
	    Vector3 acc = Constants.Vector3_ZERO,
	    bool dynamic = true)mut {
	    this.aabb = bb;
	    this.vel = vel;
	    this.acc = acc;
	    this.dynamic = dynamic;
	}

    public  void SetVelocity(Vector3 velocity)mut
    {
        this.vel = velocity;
    }

    public  void SetAcceleration(Vector3 acceleration)mut
    {
        this.acc = acceleration;
    }
}