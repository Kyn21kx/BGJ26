namespace BeefHush;

using Hush;
using System;

[RegisterSystem]
public class EnemySystem : GameSystem {

	enum ESensorResult {
		NoObstacleNoPlayer,
		FoundPlayer,
		ObstacleInTheWay
	}

	Query m_enemiesQuery;
	void* m_scene;

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
			(*enemy) = .();
		});
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


	private void ApplyFSM(Enemy* enemy, LocalTransform* xform, BeefHush.Entity* ent, RigidBody* rig) {
		if (enemy.avoidanceDirection != Constants.Vector3_ZERO) {
			rig.SetVelocity(enemy.avoidanceDirection);
			Vector3 rotationTarget = LookRotationEuler((rig.aabb.pos + enemy.avoidanceDirection), rig.aabb.pos, Constants.Vector3_UP);
			xform.SetEulerAngles(&rotationTarget);
		}
		else {
			rig.SetVelocity(enemy.targetDirection);
			Vector3 rotationTarget = LookRotationEuler((rig.aabb.pos + enemy.targetDirection), rig.aabb.pos, Constants.Vector3_UP);
			xform.SetEulerAngles(&rotationTarget);
		}
	}

	public void OnUpdate(float delta)
	{
		// The idea is that an enemy will follow a set of goals and state
		// the main goal is to catch the player, but it will change priority
		// with getting away from them if he gets too close, idk, might depend on the comp

		this.m_enemiesQuery.Each<Enemy, RigidBody, LocalTransform>(scope (entityRef, enemy, rig, xform) => {
			// Evaluate the State Machine here
			this.ApplyFSM(enemy, xform, &entityRef, rig);

			// Update it here

			// Query the spatial grid with a higher depth to check if the player is here
			const int32 queryDepth = 2;
			ESensorResult sensorRes = .NoObstacleNoPlayer;
			BeefHush.Entity lastNeighborFound = .();
			PhysicsSystem.s_SpatialGrid.UntilNeighborAt(rig.aabb.pos, queryDepth, entityRef.Id, scope [&](neighbor) => {
				lastNeighborFound = .(Scene.EntityFromIdUnchecked(this.m_scene, neighbor));
				// char8[64] buffer = .();
				// lastNeighborFound.InnerEntity().QueryName(&(buffer[0]), (uint64)64);
				// Console.WriteLine(scope $"Spatial grid found {StringView(&(buffer[0]))}");
				// On a single pass we can identify if we found the player, or if we're gonna collide with a wall

				// If it's the player

				let neighborColl = lastNeighborFound.GetComponent<Collider>(EntityRegistry.s_Collider);
				EEntityTag neighborTag = (EEntityTag)neighborColl.identifierTag;

				// TODO: Make a switch
				if (neighborTag == .Player) {
					RigidBody* playerRig = lastNeighborFound.GetComponent<RigidBody>(EntityRegistry.s_Rig);
					Vector3 playerPos = playerRig.aabb.pos;
					Vector3 diff = (playerPos - rig.aabb.pos);
					// float playerDis = diff.length_squared();
					enemy.targetDirection = diff.normalized();
					enemy.targetPos = playerPos;
					enemy.state = EEnemyState.HeadingToPlayer;

					// Reset avoidance
					enemy.avoidanceDirection = .();
					return false;
				}
				else if (neighborTag == .Wall) {
					// RigidBody* wallRig = lastNeighborFound.GetComponent<RigidBody>(EntityRegistry.s_Rig);
					// Do a raycast check from our position to the direction we want to move towards
					RigidBody* wallRig = lastNeighborFound.GetComponent<RigidBody>(EntityRegistry.s_Rig);
					Vector3 directionTaking = enemy.avoidanceDirection != Constants.Vector3_ZERO ? enemy.avoidanceDirection : enemy.targetDirection;
					Ray ray = .(rig.aabb.pos, directionTaking);
					ray.origin.y = 0;
					float distance;
					// Console.WriteLine(scope $"Wall neighbor, ray origin {ray.origin}; ray dir {ray.direction}; enemy pos (AABB pos): {rig.aabb.pos}, wall pos (AABB pos): {wallRig.aabb.pos}, wall min: {wallRig.aabb.min}, wall max: {wallRig.aabb.max}");
					if (!ray.Intersects(wallRig.aabb, out distance) || distance > 1f) {
						return false;
					}

					Vector3 hitPos = ray.origin + (ray.direction * distance);
					Console.WriteLine(scope $"Wall in the way! distance to it: {distance}");

					// Get the direction we need to go to to avoid it

					// targetDirection of the enemy could be treated as forward(?
					Vector3 actualDirectionToPlayer = (enemy.targetPos - rig.aabb.pos).normalized();
					float angle = enemy.targetDirection.angle_between(actualDirectionToPlayer);
					if (angle > (enemy.coneAngle * Constants.DEG2RAD) * 0.5f) {
						return false;
					}

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
					enemy.avoidanceDirection = (rightDot > 0f) ? perpRight : (perpRight * -1f);
					return true;
				}
				return false;
			});
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

