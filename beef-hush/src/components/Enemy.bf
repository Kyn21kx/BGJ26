namespace BeefHush;

using Hush;
using System;

enum EEnemyState : int32 {
	LookingForPlayer = 0,
	HeadingToPlayer = 1,
	FleeingFromPlayer,
	AttackPreparing = 4,
	AttackExecuting = 8,
	IsAttackPhase = AttackPreparing | AttackExecuting
}

[HushComponent, CRepr]
struct Enemy // Serves as a tag and sensor data
{
	public Vector3 avoidanceDirection = .(); // This one will take priority if not zero
	public Vector3 targetDirection = .();
	public Vector3 targetPos = .();
	public EEnemyState state = EEnemyState.LookingForPlayer;
	public float coneAngle = 0f;
	public float actionTimeRemaining = .();

	public this() {
		this.avoidanceDirection = .();
		this.targetDirection = .();
		this.targetPos = .();
		this.state = .();
		this.actionTimeRemaining = .();
		this.coneAngle = 0f;
		
	}
}
