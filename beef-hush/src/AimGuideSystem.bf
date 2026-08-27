namespace BeefHush;

using Hush;
using System;

// Debug system, could turn into actual system
[RegisterSystem]
class AimGuideSystem : GameSystem
{
	Query m_aimGuideQuery;
	Query m_rotatingPlayers;
	BeefHush.Entity m_mainCamEntity;
	bool instanced;

	private void InitEntity() {

		// Create the mesh
		const StringView renderSystemName = "RenderingSystem";
		void* scene = HushEngine.GetScene(EngineDependencies.Instance.Engine);
		var renderingSystem = BeefHush.Entity(Scene.CreateEntityWithKey(scene, (char8*)renderSystemName.ToRawData().Ptr, (uint64)renderSystemName.Length));

		let handle = renderingSystem.GetComponent<RenderingSystemAPI>();
		const StringView path = "res://Box.glb";
		uint64 rootEntId = handle.instantiateMeshEntities(&(path[0]), handle.instance);

		BeefHush.Entity guideMeshEnt = .(Scene.EntityFromIdUnchecked(scene, rootEntId));
		var aimGuide = guideMeshEnt.AddComponent<AimGuide>();
		(*aimGuide) = .();
		
	}

	public void Init()
	{
		this.instanced = false;
		QueryBuilder builder = .();
		builder.With<LocalTransform>();
		builder.With<AimGuide>();
		this.m_aimGuideQuery = builder.Build();

		builder = .();
		builder.With<Camera>();

		Query mainCamQ = builder.Build();
		mainCamQ.EachEntity(scope (entityRef) => {
		   this.m_mainCamEntity = entityRef;
		});

		builder = .();
		builder.With<PlayerTag>();
		builder.With<LocalTransform>();
		builder.With<RigidBody>();
		this.m_rotatingPlayers = builder.Build();
	}

	public void OnShutdown()
	{

	}

	private Vector3 GetPosInWorldSpace(float depth) {
		// Get the mouse position in world space
		Vector2 mouseScreenPos = InputManager.GetMousePosition();
		// Find cam
		Camera* cam = this.m_mainCamEntity.GetComponent<Camera>();
		LocalTransform* xform = this.m_mainCamEntity.GetComponent<LocalTransform>();
		float[16] mat = .();
		xform.GetTransformationMatrixUnsafe(&(mat[0]), 16);
		Vector3 direction = .();
		Vector3 origin = cam.ScreenToWorldPosUnsafe(&(mat[0]), mouseScreenPos, &direction);
		Vector3 worldPos = cam.ProjectPlanePosition(origin, direction, depth);

		// Then we do dest - source
		return worldPos;
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
		const float MODEL_CORRECTION_FACTOR = -1f;
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

	public void OnUpdate(float delta)
	{
		if (!this.instanced) {
			this.InitEntity();
			this.instanced = true;
		}
		this.m_aimGuideQuery.Each<LocalTransform, AimGuide>(scope (entityRef, xform, guide) => {
			xform.SetPosition(GetPosInWorldSpace(guide.depth));
		});

		this.m_rotatingPlayers.Each<PlayerTag, LocalTransform, RigidBody>(scope (entityRef, tag, localXform, rig) => {
			Vector3 target = GetPosInWorldSpace(0f);
			target.y = 0f;
			Vector3 rotationTarget = LookRotationEuler(target, rig.aabb.pos, .(0f, 1f, 0f));
			localXform.SetEulerAngles(&rotationTarget);
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
