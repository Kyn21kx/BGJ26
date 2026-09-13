namespace BeefHush;

using Hush;
using System;
using System.Diagnostics;

[RegisterSystem]
public class NPCSystem : GameSystem {
	private const float ATTACK_PREPARE_TIME = 1f;
	private const float ATTACK_EXECUTE_TIME = 0.2f;
	private const float ATTACK_DASH_DISTANCE = 3f;
	private const float ATTACK_DAMAGE = 1f;

	private const float ENEMY_ATTACK_RANGE = 0.5f * 0.5f;

	enum ESensorResult {
		NoObstacleNoPlayer,
		FoundPlayer,
		ObstacleInTheWay
	}

	Query m_enemiesQuery;
	Query m_navAgentsQuery;
	void* m_scene;
	float m_ellapsed;

	public void Init()
	{
		QueryBuilder builder = .();
		EntityRegistry.s_Enemy = builder.With<Enemy>();
		builder.With<NavAgent>();
		builder.With<RigidBody>();
		builder.With<LocalTransform>();
		this.m_enemiesQuery = builder.Build();
		this.m_scene = HushEngine.GetScene(EngineDependencies.Instance.Engine);

		// Zero initialize
		this.m_enemiesQuery.Each<Enemy, NavAgent>(scope (entityRef, enemy, agent) => {
			enemy.lastAttackTime = 0f;
			agent.state = .Default;

			agent.targetDirection = .();
			agent.targetPos = .();
			agent.normalFaceOfHit = .();
		});

		builder = .();
		builder.With<NavAgent>();
		builder.With<RigidBody>();
		builder.With<LocalTransform>();
		this.m_navAgentsQuery = builder.Build();
		this.m_ellapsed = 0f;
	}

	public void NavSubSystem(float delta, BeefHush.Entity* entityRef, NavAgent* agent, RigidBody* rig, LocalTransform* xform) {
		Console.WriteLine(scope $"State: {agent.state}");

		if ((agent.state & .InPathFindingPhase) != 0) {
			LookForAvailableDirection(delta, entityRef, agent, xform, rig);
			return;
		}
		if (agent.state == .Default || (agent.state & .IsMovingPhase) != 0) {
			rig.SetVelocity(agent.targetDirection);
			Vector3 rotationTarget = LookRotationEuler((rig.aabb.pos + agent.targetDirection), rig.aabb.pos, Constants.Vector3_UP);
			// Vector3 currRot = xform.GetEulerAngles();

			xform.SetEulerAngles(&rotationTarget);

			SensorSystem(delta, entityRef, agent, rig, xform); // This is a long ass function
		}
	
	}

	public void OnShutdown()
	{

	}

	public Vector3 LookRotationEuler(Vector3 source, Vector3 target, Vector3 up) {
		var up;
		Vector3 fwd = target - source;

		if (fwd.length() < 0.0001f) {
			return Constants.Vector3_ZERO;
		}

		fwd = fwd.normalized();

		if (Math.Abs(fwd.dot(up)) > 0.999f) {
			up = Vector3(0f, 0f, 1f);
		}

		Vector3 right = fwd.cross(up).normalized();

		Vector3 actualUp = right.cross(fwd).normalized();
		float[9] rotationMat = .();

		rotationMat[0] = right.x;
		rotationMat[1] = right.y;
		rotationMat[2] = right.z;

		rotationMat[3] = actualUp.x;
		rotationMat[4] = actualUp.y;
		rotationMat[5] = actualUp.z;

		rotationMat[6] = -fwd.x;
		rotationMat[7] = -fwd.y;
		rotationMat[8] = -fwd.z;

		Vector3 euler = .();
		// const float MODEL_CORRECTION_FACTOR = -1f;
		if (Math.Abs(rotationMat[2]) < 1f - Constants.EPSILON) {
			//euler.x = -Math.Asin(rotationMat[2]);
			euler.y = Math.Atan2(rotationMat[6], rotationMat[8]);
			//euler.z = Math.Atan2(rotationMat[1], rotationMat[0]);
			return euler;
		}

		// euler.x = (rotationMat[2] > 0.0f) ? -Math.PI_f / 2.0f : Math.PI_f / 2.0f;
		euler.y = Math.Atan2(-rotationMat[6], rotationMat[4]);
		//euler.z = 0.0f;

		return euler;
	}

	private Vector3 GetNormalFromAABB(in AABB aabb, Vector3 hitPos) {
		Vector3 normal = .();
		Vector3 center = aabb.pos;
		Vector3 halfSize = aabb.size * 0.5f;

		// Determine which face was hit by comparing hitPoint to the AABB bounds
		Vector3 diff = hitPos - center;
		float max = Math.Max(Math.Abs(diff.x), Math.Max(Math.Abs(diff.y), Math.Abs(diff.z)));
		if (Math.Abs(diff.x) == max) {
			normal = .(Math.Sign(diff.x), 0, 0);
		}
		else if (Math.Abs(diff.y) == max) {
			normal = .(0, Math.Sign(diff.y), 0);
		}
		else if (Math.Abs(diff.z) == max) {
			normal = .(0, 0, Math.Sign(diff.z));					
		}
		return normal;
	}

	private Vector3 GetAvoidanceDirection(NavAgent* agent, RigidBody* rig, RigidBody* wallRig, Vector3 hitPos, Vector3 directionTaking) {
		Vector3 normal = .();
		Vector3 center = wallRig.aabb.pos;
		Vector3 halfSize = wallRig.aabb.size * 0.5f;

		// Determine which face was hit by comparing hitPoint to the AABB bounds
		Vector3 diff = hitPos - center;
		float max = Math.Max(Math.Abs(diff.x), Math.Max(Math.Abs(diff.y), Math.Abs(diff.z)));
		if (Math.Abs(diff.x) == max) {
			normal = .(Math.Sign(diff.x), 0, 0);
		}
		else if (Math.Abs(diff.y) == max) {
			normal = .(0, Math.Sign(diff.y), 0);
		}
		else if (Math.Abs(diff.z) == max) {
			normal = .(0, 0, Math.Sign(diff.z));					
		}

		Vector3 perpRight = directionTaking.cross(Constants.Vector3_UP).normalized();
		Vector3 toTarget = (agent.targetPos - rig.aabb.pos).normalized();
		float rightDot = perpRight.dot(toTarget);
		return (rightDot > 0f) ? perpRight : (perpRight * -1f);
	}


	private bool TriggerAttackIfInRange(float distanceToPlayerSqr, NavAgent* agent, Enemy* enemy, RigidBody* rig, BeefHush.Entity* entity) {
		if (enemy == null) {
			return false;
		}
		float cdDiff = (this.m_ellapsed - enemy.lastAttackTime);
		Console.WriteLine(scope $"Cooldown ellapsed : {cdDiff}");
		if (cdDiff < enemy.attackCooldown || distanceToPlayerSqr > ATTACK_DASH_DISTANCE) {
			return false;
		}
		
		// Prepare attack
		agent.state = .AttackPreparing;
		enemy.actionTimeRemaining = ATTACK_PREPARE_TIME;
		rig.SetVelocity(Constants.Vector3_ZERO);

		// Add animation component
		var animComp = entity.AddComponent<ShakingAnimation>();
		animComp.duration = ATTACK_PREPARE_TIME;
		animComp.speed = 1f;
		return true;
	}

	private void ExecuteMeleeAttack(BeefHush.Entity* entity, Enemy* enemy, RigidBody* rig, NavAgent* agent, in BeefHush.Entity lastFoundPlayer, float disToPlayerSqr) {
		// Dash towards the player and check which one is the closest one
		const float speed = ATTACK_DASH_DISTANCE / ATTACK_EXECUTE_TIME;
		rig.SetVelocity(agent.targetDirection * speed);


		// Check the range
		if (disToPlayerSqr <= ENEMY_ATTACK_RANGE) {
			// Damage the player
			HealthSystem.DamageEntity(this.m_scene, lastFoundPlayer.Id, ATTACK_DAMAGE, entity.Id);
			// Cut it short
			enemy.actionTimeRemaining = 0f;
		}

		if (enemy.actionTimeRemaining <= 0f) {
			agent.state = .Default;
		}
		
	}

	private void ExecuteRangedAttack(BeefHush.Entity* entity, Enemy* enemy, RigidBody* rig, NavAgent* agent, in BeefHush.Entity lastFoundPlayer, float disToPlayerSqr) {
		// This one does not need to check the range, that check already passed
		// Make the enemy's projectile
		SpellSystem.MakeSpell("res://decahedron.glb", (int32)EEntityTag.EnemySpell, rig.aabb.pos, agent.targetDirection, 10.0f, enemy.attackRange);
		agent.state = .Default;
	}

	private BeefHush.Entity QueryFirstPlayer(in BeefHush.Entity entity, RigidBody* rig, out float outDisSqr) {
		outDisSqr = float.MaxValue;
		BeefHush.Entity lastFoundPlayer = .();
		PhysicsSystem.s_SpatialGrid.EachNeighborAt(rig.aabb.pos, 2, entity.Id, scope [&](neighbor) => {
			let neighborEnt = BeefHush.Entity(Scene.EntityFromIdUnchecked(this.m_scene, neighbor));
			if (!neighborEnt.HasComponent(EntityRegistry.s_PlayerTag)) {
				return;
			}
			// Distance
			RigidBody* neighborRig = neighborEnt.GetComponent<RigidBody>(EntityRegistry.s_Rig);
			Debug.Assert(neighborRig != null, "A player MUST have a rigidbody component!");

			float disSqr = (rig.aabb.pos - neighborRig.aabb.pos).length_squared();
			if (disSqr < outDisSqr) {
				outDisSqr = disSqr;
				lastFoundPlayer = neighborEnt;
			}
		});
		return lastFoundPlayer;
	}

	private void HandleAttackStates(BeefHush.Entity* entity, NavAgent* agent, Enemy* enemy, RigidBody* rig, float delta) {
		// Stay here if preparing, go and execute the attack if the enum says so
		enemy.actionTimeRemaining -= delta;
		if (agent.state == .AttackPreparing) {
			rig.SetVelocity(Constants.Vector3_ZERO);
			if (enemy.actionTimeRemaining <= 0f) {
				enemy.actionTimeRemaining = ATTACK_EXECUTE_TIME;
				agent.state = .AttackExecuting;
			}
			return;
		}

		float minPlayerDistanceSqr;
		BeefHush.Entity lastFoundPlayer = this.QueryFirstPlayer(*entity, rig, out minPlayerDistanceSqr);

		// Executing otherwise
		if (enemy.attackType == .Melee) {
			this.ExecuteMeleeAttack(entity, enemy, rig, agent, lastFoundPlayer, minPlayerDistanceSqr);
		}
		else if (enemy.attackType == .Ranged) {
			this.ExecuteRangedAttack(entity, enemy, rig, agent, lastFoundPlayer, minPlayerDistanceSqr);
		}
		enemy.lastAttackTime = this.m_ellapsed;
	}

	private void LookForAvailableDirection(float delta, BeefHush.Entity* entityRef, NavAgent* agent, LocalTransform* xform, RigidBody* rig) {
		// Early out: if the player is visible with no wall in the way, abandon pathfinding
		const int32 earlyOutDepth = 2;
		bool targetVisible = false;
		Vector3 visibleTargetPos = .();
		BeefHush.Entity scratchEnt = .();
		PhysicsSystem.s_SpatialGrid.UntilNeighborAt(rig.aabb.pos, earlyOutDepth, entityRef.Id, scope [&](neighbor) => {
			scratchEnt = .(Scene.EntityFromIdUnchecked(this.m_scene, neighbor));
			let coll = scratchEnt.GetComponent<Collider>(EntityRegistry.s_Collider);
			if (coll.identifierTag != agent.targetCollId) return false;
			visibleTargetPos = scratchEnt.GetComponent<RigidBody>(EntityRegistry.s_Rig).aabb.pos;
			targetVisible = true;
			return true;
		});
		if (targetVisible) {
			Vector3 toTarget = (visibleTargetPos - rig.aabb.pos).normalized();
			Ray playerRay = .(rig.aabb.pos, toTarget);
			playerRay.origin.y = 0f;
			bool blocked = false;
			PhysicsSystem.s_SpatialGrid.UntilNeighborAt(rig.aabb.pos, earlyOutDepth, entityRef.Id, scope [&](neighbor) => {
				scratchEnt = .(Scene.EntityFromIdUnchecked(this.m_scene, neighbor));
				let coll = scratchEnt.GetComponent<Collider>(EntityRegistry.s_Collider);
				if ((EEntityTag)coll.identifierTag != .Wall) return false;
				float dist;
				if (playerRay.Intersects(scratchEnt.GetComponent<RigidBody>(EntityRegistry.s_Rig).aabb, out dist)) { blocked = true; return true; }
				return false;
			});
			if (!blocked) {
				agent.targetDirection = toTarget;
				agent.targetPos = visibleTargetPos;
				agent.state = .HeadingToPlayer;
				rig.SetVelocity(toTarget);
				return;
			}
		}

		if (agent.state == .SearchingPath) {
			rig.SetVelocity(Constants.Vector3_ZERO);
			// Rotate forward vector in XZ plane to avoid euler angle ambiguity
			float rotSign = agent.normalFaceOfHit.x != 0f ? Math.Sign(agent.normalFaceOfHit.x) : Math.Sign(agent.normalFaceOfHit.z);
			if (rotSign == 0f) rotSign = 1f;
			float rotDelta = (delta * agent.scanPathSpeed) * Constants.DEG2RAD * rotSign;
			Vector3 currFwd = xform.Forward().normalized();
			float cosA = Math.Cos(rotDelta), sinA = Math.Sin(rotDelta);
			Vector3 newFwd = .(currFwd.x * cosA - currFwd.z * sinA, 0f, currFwd.x * sinA + currFwd.z * cosA);
			Vector3 newRot = LookRotationEuler(rig.aabb.pos + newFwd, rig.aabb.pos, Constants.Vector3_UP);
			xform.SetEulerAngles(&newRot);
		}
		else {
			rig.SetVelocity(agent.targetDirection);
		}

		// Raycast here
		Ray ray = .(rig.aabb.pos, xform.Forward().normalized());
		ray.origin.y = 0f;
		Ray rightRay = .(rig.aabb.pos, xform.Right().normalized() * Math.Sign(agent.normalFaceOfHit.x));
		rightRay.origin.y = 0f;

		// Go through the spatial grid, if even one wall is in our path
		// cancel
		const int32 queryDepth = 2;
		BeefHush.Entity lastNeighborFound = .();
		bool noObstacles = true;
		bool isAvailablePath = PhysicsSystem.s_SpatialGrid.UntilNeighborAt(rig.aabb.pos, queryDepth, entityRef.Id, scope [&](neighbor) => {
			lastNeighborFound = .(Scene.EntityFromIdUnchecked(this.m_scene, neighbor));
			let neighborColl = lastNeighborFound.GetComponent<Collider>(EntityRegistry.s_Collider);
			EEntityTag neighborTag = (EEntityTag)neighborColl.identifierTag;

			if (neighborTag != .Wall) {
				return false;
			}
			noObstacles = false;
			// Raycast
			RigidBody* wallRig = lastNeighborFound.GetComponent<RigidBody>(EntityRegistry.s_Rig);
			float distance;
			if (agent.state == .SearchingPath) {
				if (!ray.Intersects(wallRig.aabb, out distance) || distance > 1f) {
					return true;
				}
			}
			else if (agent.state == .TraversingFixedDir) {
				// Check if a new wall is blocking our forward travel direction
				Ray fwdRay = .(rig.aabb.pos, agent.targetDirection);
				fwdRay.origin.y = 0f;
				float fwdDist;
				if (fwdRay.Intersects(wallRig.aabb, out fwdDist) && fwdDist <= 1f) {
					agent.normalFaceOfHit = GetNormalFromAABB(wallRig.aabb, fwdRay.origin + fwdRay.direction * fwdDist);
					agent.state = .SearchingPath;
					return true;
				}
				float angle = rig.aabb.pos.angle_between(agent.targetPos) * Constants.RAD2DEG;
				bool rightClear = !rightRay.Intersects(wallRig.aabb, out distance) || distance > 1f;
				Console.WriteLine(scope $"Right clear: {rightClear}, dis: {distance}. Angle to wall: {angle}, normal: {agent.normalFaceOfHit}");
				// bool leftClear = !leftRay.Intersects(wallRig.aabb, out distance) || distance > 1f;
				if (rightClear && angle > 5f) {
					return true;
				}
			}
			return false;
		});

		if (agent.state == .SearchingPath && (isAvailablePath || noObstacles)) {
			agent.targetDirection = ray.direction;
			agent.state = .TraversingFixedDir;
		}
		else if (agent.state == .TraversingFixedDir && (isAvailablePath || noObstacles)) {
			agent.targetDirection = rightRay.direction;
			agent.state = .Default;
		}
		
	}

	private void SensorSystem(float delta, BeefHush.Entity* entityRef, NavAgent* agent, RigidBody* rig, LocalTransform* xform) {
		// Query the spatial grid with a higher depth to check if the player is here
		if (agent.targetDirection == Constants.Vector3_ZERO) {
			agent.targetDirection = Constants.Vector3_RIGHT;
		}

		const int32 queryDepth = 2;
		ESensorResult sensorRes = .NoObstacleNoPlayer;
		BeefHush.Entity lastNeighborFound = .();

		PhysicsSystem.s_SpatialGrid.UntilNeighborAt(rig.aabb.pos, queryDepth, entityRef.Id, scope [&](neighbor) => {
			lastNeighborFound = .(Scene.EntityFromIdUnchecked(this.m_scene, neighbor));

			let neighborColl = lastNeighborFound.GetComponent<Collider>(EntityRegistry.s_Collider);
			EEntityTag neighborTag = (EEntityTag)neighborColl.identifierTag;

			// TODO: Make a switch
			if ((int32)neighborTag == agent.targetCollId) {
				RigidBody* playerRig = lastNeighborFound.GetComponent<RigidBody>(EntityRegistry.s_Rig);
				Vector3 playerPos = playerRig.aabb.pos;
				Vector3 diff = (playerPos - rig.aabb.pos);
				float playerDis = diff.length_squared();
				agent.targetDirection = diff.normalized();
				agent.targetPos = playerPos;
				agent.state = ENPCState.HeadingToPlayer;

				// HACK: Dodgy way of doing things
				Enemy* enemy = entityRef.GetComponent<Enemy>(EntityRegistry.s_Enemy);
				return this.TriggerAttackIfInRange(playerDis, agent, enemy, rig, entityRef);
			}
			else if (neighborTag == .Wall) {
				// RigidBody* wallRig = lastNeighborFound.GetComponent<RigidBody>(EntityRegistry.s_Rig);
				// Do a raycast check from our position to the direction we want to move towards
				RigidBody* wallRig = lastNeighborFound.GetComponent<RigidBody>(EntityRegistry.s_Rig);
				Vector3 directionTaking = rig.vel;
				Ray ray = .(rig.aabb.pos, directionTaking);
				ray.origin.y = 0;
				float distance;
				if (!ray.Intersects(wallRig.aabb, out distance) || distance > 1f) {
					return false;
				}

				agent.targetPos = ray.origin + (ray.direction * distance);
				agent.normalFaceOfHit = GetNormalFromAABB(wallRig.aabb, agent.targetPos);

				agent.state = .SearchingPath;

				return true;
			}
			return false;
		});
	}

	public void OnUpdate(float delta)
	{
		// The idea is that an enemy will follow a set of goals and state
		// the main goal is to catch the player, but it will change priority
		// with getting away from them if he gets too close, idk, might depend on the comp

		this.m_ellapsed += delta;


		this.m_navAgentsQuery.Each<NavAgent, RigidBody, LocalTransform>(scope (entityRef, agent, rig, xform) => {
			this.NavSubSystem(delta, &entityRef, agent, rig, xform);
		});

		this.m_enemiesQuery.Each<Enemy, NavAgent, RigidBody, LocalTransform>(scope (entityRef, enemy, agent, rig, xform) => {
			// Evaluate the State Machine here
			if ((agent.state & .IsAttackPhase) != 0) {
				this.HandleAttackStates(&entityRef, agent, enemy, rig, delta);
				return;
			}
		});
		
	}

	public void OnFixedUpdate(float delta)
	{

	}

	public void OnRender()
	{

	}

	public void OnPreRender()
	{

	}

	public void OnPostRender()
	{

	}
	
}

