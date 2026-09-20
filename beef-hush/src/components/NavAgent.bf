namespace BeefHush;

using System;
using Hush;

enum ENPCState : int32 {
	Default = 0,
	HeadingToPlayer = 1,
	FleeingFromPlayer = 2,
	AttackPreparing = 4,
	AttackExecuting = 8,
	SearchingPath = 16,
	TraversingFixedDir = 32,
	IsAttackPhase = AttackPreparing | AttackExecuting,
	InPathFindingPhase = SearchingPath | TraversingFixedDir,
	IsMovingPhase = HeadingToPlayer | FleeingFromPlayer
}

// Component for navigation, this was a part of the enemy comp
// but we may have more NPCs that can be iterated on systems
// or maybe we have enemies that just don't attack
[HushComponent, CRepr]
struct NavAgent
{
	public Vector3 normalFaceOfHit = .(); // This one will take priority if not zero
	public Vector3 targetDirection = .();
	public Vector3 targetPos = .();
	public ENPCState state = ENPCState.Default;
	public float scanPathSpeed = 0f;
	public float coneAngle = 0f;
	public int32 targetCollId = -1;
}
