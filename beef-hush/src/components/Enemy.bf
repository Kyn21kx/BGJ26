namespace BeefHush;

using Hush;
using System;

enum EEnemyState : int32 {
	LookingForPlayer = 0,
	HeadingToPlayer = 1,
	FleeingFromPlayer,
	AttackPreparing = 4,
	AttackExecuting = 8,
	SearchingPath = 16,
	TraversingFixedDir = 32,
	IsAttackPhase = AttackPreparing | AttackExecuting,
	InPathFindingPhase = SearchingPath | TraversingFixedDir,
}

[HushComponent, CRepr]
struct Enemy // Serves as a tag and sensor data
{
	public Vector3 normalFaceOfHit = .(); // This one will take priority if not zero
	public Vector3 targetDirection = .();
	public Vector3 targetPos = .();
	public EEnemyState state = EEnemyState.LookingForPlayer;
	public float coneAngle = 0f;
	// TODO: Separate into an attack component
	public float actionTimeRemaining = .();
	public float attackCooldown = 0f;
	public float lastAttackTime = 0f;
	public float scanPathSpeed = 0f;
	public this() {
		this.normalFaceOfHit = .();
		this.targetDirection = .();
		this.targetPos = .();
		this.state = .LookingForPlayer;
		this.actionTimeRemaining = .();
		this.attackCooldown = 0f;
		this.lastAttackTime = 0f;
		this.coneAngle = 0f;
		this.scanPathSpeed = 0f;
		
	}
}
