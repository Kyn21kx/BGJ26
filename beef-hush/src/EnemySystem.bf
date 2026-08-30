namespace BeefHush;

using Hush;
using System;
using System.Diagnostics;

[RegisterSystem]
public class EnemySystem : GameSystem {
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
	void* m_scene;
	float m_ellapsed;

	public void Init()
	{
		QueryBuilder builder = .();
		builder.With<Enemy>();
		builder.With<RigidBody>();
		builder.With<LocalTransform>();
		this.m_enemiesQuery = builder.Build();
		this.m_scene = HushEngine.GetScene(EngineDependencies.Instance.Engine);

		// Zero initialize
		this.m_enemiesQuery.Each<Enemy>(scope (entityRef, enemy) => {
			enemy.lastAttackTime = 0f;
			enemy.state = .LookingForPlayer;

			enemy.targetDirection = .();
			enemy.targetPos = .();
			enemy.normalFaceOfHit = .();
		});
		this.m_ellapsed = 0f;
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

	private Vector3 GetAvoidanceDirection(Enemy* enemy, RigidBody* rig, RigidBody* wallRig, Vector3 hitPos, Vector3 directionTaking) {
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
		Vector3 toTarget = (enemy.targetPos - rig.aabb.pos).normalized();
		float rightDot = perpRight.dot(toTarget);
		return (rightDot > 0f) ? perpRight : (perpRight * -1f);
	}


	private void TriggerAttackIfInRange(float distanceToPlayerSqr, Enemy* enemy, RigidBody* rig, BeefHush.Entity* entity) {
		float cdDiff = (this.m_ellapsed - enemy.lastAttackTime);
		Console.WriteLine(scope $"Cooldown ellapsed : {cdDiff}");
		if (cdDiff < enemy.attackCooldown || distanceToPlayerSqr > ATTACK_DASH_DISTANCE) {
			return;
		}
		
		// Prepare attack
		enemy.state = .AttackPreparing;
		enemy.actionTimeRemaining = ATTACK_PREPARE_TIME;
		rig.SetVelocity(Constants.Vector3_ZERO);

		// Add animation component
		var animComp = entity.AddComponent<ShakingAnimation>();
		animComp.duration = ATTACK_PREPARE_TIME;
		animComp.speed = 1f;
	}

	private void HandleAttackStates(BeefHush.Entity* entity, Enemy* enemy, RigidBody* rig, float delta) {
		// Stay here if preparing, go and execute the attack if the enum says so
		enemy.actionTimeRemaining -= delta;
		if (enemy.state == .AttackPreparing) {
			rig.SetVelocity(Constants.Vector3_ZERO);
			if (enemy.actionTimeRemaining <= 0f) {
				enemy.actionTimeRemaining = ATTACK_EXECUTE_TIME;
				enemy.state = .AttackExecuting;
			}
			return;
		}

		// Executing otherwise
		// Dash towards the player and check which one is the closest one
		const float speed = ATTACK_DASH_DISTANCE / ATTACK_EXECUTE_TIME;
		rig.SetVelocity(enemy.targetDirection * speed);

		float minPlayerDistanceSqr = float.MaxValue;
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
			if (disSqr < minPlayerDistanceSqr) {
				minPlayerDistanceSqr = disSqr;
				lastFoundPlayer = neighborEnt;
			}
		});

		// Check the range
		if (minPlayerDistanceSqr <= ENEMY_ATTACK_RANGE) {
			// Damage the player
			HealthSystem.DamageEntity(this.m_scene, lastFoundPlayer.Id, ATTACK_DAMAGE, entity.Id);
			// Cut it short
			enemy.actionTimeRemaining = 0f;
		}

		if (enemy.actionTimeRemaining <= 0f) {
			enemy.state = .LookingForPlayer;
		}


		enemy.lastAttackTime = this.m_ellapsed;
		
	}

	private void LookForAvailableDirection(float delta, BeefHush.Entity* entityRef, Enemy* enemy, LocalTransform* xform, RigidBody* rig) {
		if (enemy.state == .SearchingPath) {
			rig.SetVelocity(Constants.Vector3_ZERO);
			// Rotate + Raycast until we find a non obstructed direction
			Vector3 currRotation = xform.GetEulerAngles();

			currRotation.y += ((delta * enemy.scanPathSpeed) * Constants.DEG2RAD) * Math.Sign(enemy.normalFaceOfHit.x);

			xform.SetEulerAngles(&currRotation);
		}
		else {
			rig.SetVelocity(enemy.targetDirection);
		}

		// Raycast here
		Ray ray = .(rig.aabb.pos, xform.Forward().normalized());
		ray.origin.y = 0f;
		Ray rightRay = .(rig.aabb.pos, xform.Right().normalized() * Math.Sign(enemy.normalFaceOfHit.x));
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
			if (enemy.state == .SearchingPath) {
				if (!ray.Intersects(wallRig.aabb, out distance) || distance > 1f) {
					return true;
				}
			}
			else if (enemy.state == .TraversingFixedDir) {
				float angle = rig.aabb.pos.angle_between(enemy.targetPos) * Constants.RAD2DEG;
				bool rightClear = !rightRay.Intersects(wallRig.aabb, out distance) || distance > 1f;
				Console.WriteLine(scope $"Right clear: {rightClear}, dis: {distance}. Angle to wall: {angle}, normal: {enemy.normalFaceOfHit}");
				// bool leftClear = !leftRay.Intersects(wallRig.aabb, out distance) || distance > 1f;
				if (rightClear && angle > 5f) {
					return true;
				}
				
			}
			return false;
		});

		if (enemy.state == .SearchingPath && (isAvailablePath || noObstacles)) {
			enemy.targetDirection = ray.direction;
			enemy.state = .TraversingFixedDir;
		}
		else if (enemy.state == .TraversingFixedDir && (isAvailablePath || noObstacles)) {
			enemy.targetDirection = rightRay.direction;
			enemy.state = .LookingForPlayer;
		}
		
	}

	private void EnemySensorSystem(float delta, BeefHush.Entity* entityRef, Enemy* enemy, RigidBody* rig, LocalTransform* xform) {
		// Query the spatial grid with a higher depth to check if the player is here
		if (enemy.targetDirection == Constants.Vector3_ZERO) {
			enemy.targetDirection = Constants.Vector3_RIGHT;
		}

		const int32 queryDepth = 2;
		ESensorResult sensorRes = .NoObstacleNoPlayer;
		BeefHush.Entity lastNeighborFound = .();

		PhysicsSystem.s_SpatialGrid.UntilNeighborAt(rig.aabb.pos, queryDepth, entityRef.Id, scope [&](neighbor) => {
			lastNeighborFound = .(Scene.EntityFromIdUnchecked(this.m_scene, neighbor));

			let neighborColl = lastNeighborFound.GetComponent<Collider>(EntityRegistry.s_Collider);
			EEntityTag neighborTag = (EEntityTag)neighborColl.identifierTag;

			// TODO: Make a switch
			if (neighborTag == .Player) {
				RigidBody* playerRig = lastNeighborFound.GetComponent<RigidBody>(EntityRegistry.s_Rig);
				Vector3 playerPos = playerRig.aabb.pos;
				Vector3 diff = (playerPos - rig.aabb.pos);
				float playerDis = diff.length_squared();
				enemy.targetDirection = diff.normalized();
				enemy.targetPos = playerPos;
				enemy.state = EEnemyState.HeadingToPlayer;

				this.TriggerAttackIfInRange(playerDis, enemy, rig, entityRef);
				return false;
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

				enemy.targetPos = ray.origin + (ray.direction * distance);
				enemy.normalFaceOfHit = GetNormalFromAABB(wallRig.aabb, enemy.targetPos);

				enemy.state = .SearchingPath;

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

		this.m_enemiesQuery.Each<Enemy, RigidBody, LocalTransform>(scope (entityRef, enemy, rig, xform) => {
			// Evaluate the State Machine here
			Console.WriteLine(scope $"State: {enemy.state}");

			if ((enemy.state & .InPathFindingPhase) != 0) {
				LookForAvailableDirection(delta, &entityRef, enemy, xform, rig);
				return;
			}

			if ((enemy.state & .IsAttackPhase) != 0) {
				this.HandleAttackStates(&entityRef, enemy, rig, delta);
				return;
			}

			rig.SetVelocity(enemy.targetDirection);
			Vector3 rotationTarget = LookRotationEuler((rig.aabb.pos + enemy.targetDirection), rig.aabb.pos, Constants.Vector3_UP);
			// Vector3 currRot = xform.GetEulerAngles();

			xform.SetEulerAngles(&rotationTarget);

			EnemySensorSystem(delta, &entityRef, enemy, rig, xform); // This is a long ass function
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

