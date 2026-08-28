namespace BeefHush;

using Hush;
using System;

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

	private void ApplyFSM(Enemy* enemy, BeefHush.Entity* ent, RigidBody* rig) {
		// switch (enemy.state) {
		// 	case EEnemyState.LookingForPlayer:
		// 		// NYI
		// 		break;
		// 	case EEnemyState.HeadingToPlayer:
		// 		// Raw direction
		// 		break;
		// 	case EEnemyState.FleeingFromPlayer:
		// 		break;
		// }
		rig.SetVelocity(enemy.targetDirection);

	}

	public void OnUpdate(float delta)
	{
		// The idea is that an enemy will follow a set of goals and state
		// the main goal is to catch the player, but it will change priority
		// with getting away from them if he gets too close, idk, might depend on the comp

		this.m_enemiesQuery.Each<Enemy, RigidBody>(scope (entityRef, enemy, rig) => {
			// Evaluate the State Machine here
			this.ApplyFSM(enemy, &entityRef, rig);

			// Update it here

			// Query the spatial grid with a higher depth to check if the player is here
			const int32 queryDepth = 2;
			ESensorResult sensorRes = .NoObstacleNoPlayer;
			BeefHush.Entity lastNeighborFound = .();
			PhysicsSystem.s_SpatialGrid.UntilNeighborAt(rig.aabb.pos, queryDepth, entityRef.Id, scope [&](neighbor) => {
				lastNeighborFound = .(Scene.EntityFromIdUnchecked(this.m_scene, neighbor));
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
					enemy.state = EEnemyState.HeadingToPlayer;
					return false;
				}
				else if (neighborTag == .Wall) {
					// RigidBody* wallRig = lastNeighborFound.GetComponent<RigidBody>(EntityRegistry.s_Rig);
					// Do a raycast check from our position to the direction we want to move towards
					RigidBody* wallRig = lastNeighborFound.GetComponent<RigidBody>(EntityRegistry.s_Rig);
					Ray ray = .(rig.aabb.pos, enemy.targetDirection);
					float distance;
					if (!ray.Intersects(wallRig.aabb, out distance)) {
						return false;
					}

					Vector3 hitPos = ray.origin + (ray.direction * distance);
					Console.WriteLine(scope $"Wall in the way! Hit pos: {hitPos}");

					// Get the direction we need to go to to avoid it

					// targetDirection of the enemy could be treated as forward(?
					Vector3 actualDirectionToPlayer = (enemy.targetPos - rig.aabb.pos).normalized();
					float angle = enemy.targetDirection.angle_between(actualDirectionToPlayer);
					if (angle > enemy.coneAngle * 0.5f) {
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

					Vector3 projected = enemy.targetDirection.ProjectOntoPlane(normal).normalized();

					if (projected.length_squared() < Constants.EPSILON) {
						// Cross with up
						projected = normal.cross(Constants.Vector3_UP);
						if (projected.length_squared() < Constants.EPSILON) {
							projected = normal.cross(Constants.Vector3_RIGHT * -1f);
						}
					}

					enemy.targetDirection = projected;
					// Maintain the enemy's state
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

