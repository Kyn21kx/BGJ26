namespace BeefHush;

using Hush;
using System;

enum EAttackType : uint32 {
	Melee,
	Ranged
}

[HushComponent, CRepr]
struct Enemy // Serves as a tag and sensor data
{
	// TODO: Separate into an attack component
	public float actionTimeRemaining = .();
	public float attackCooldown = 0f;
	public float lastAttackTime = 0f;
	public float attackRange = 0f;
	public EAttackType attackType = .Melee;
	public this() {
		this.actionTimeRemaining = .();
		this.attackCooldown = 0f;
		this.lastAttackTime = 0f;
		this.attackType = .Melee;
	}
}
