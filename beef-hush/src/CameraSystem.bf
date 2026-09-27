namespace BeefHush;

using Hush;
using System;
using System.Diagnostics;

[RegisterSystem]
class CameraSystem : GameSystem
{
	// Pitch is fixed — only position is driven at runtime
	const float PITCH_DEG   = 60f;
	const float PITCH_RAD   = PITCH_DEG * Constants.PI / 180f;

	// Extra headroom multiplier on player spread radius.
	// NOTE: ideally derived from Camera FOV + viewport aspect ratio via GetViewportSize,
	// which is not currently exposed in the bindings.
	const float ZOOM_MARGIN = 1.8f;

	Query m_mainCamQuery;
	Query m_targetsQuery;
	BeefHush.Entity m_camEntity;
	Vector3 m_currentPos;

	float m_ellapsed;

	private static CameraSystem s_instance = null;

	public void Init()
	{
		s_instance = this;
		QueryBuilder builder = .();
		EntityRegistry.s_MainCam = builder.With<MainCamTag>();
		builder.With<LocalTransform>();
		this.m_mainCamQuery = builder.Build();

		builder = .();
		builder.With<PlayerTag>();
		builder.With<RigidBody>();
		this.m_targetsQuery = builder.Build();

		// Cache camera entity and bake in the fixed 60° downward pitch
		this.m_mainCamQuery.EachEntity(scope (entityRef) => {
			this.m_camEntity = entityRef;
			LocalTransform* xform = entityRef.GetComponent<LocalTransform>();
			this.m_currentPos = xform.GetPositionValue();
			Vector3 euler = .(-PITCH_RAD, 0f, 0f);
			xform.SetEulerAngles(&euler);
		});
	}

	public static void SendShake(float trauma) {
		// offset = maxOffset * shake * perlin()
		Debug.Assert(s_instance != null, "Camera System is not initialized and a shake was attempted!");
		Debug.Assert(s_instance.m_camEntity.IsValid, "Main Camera has not been set!");
		var mainCamComp = s_instance.m_camEntity.GetComponent<MainCamTag>(EntityRegistry.s_MainCam);
		mainCamComp.SetTrauma(mainCamComp.trauma + trauma);
	}

	public void OnShutdown() {}

	public void OnUpdate(float delta)
	{
		this.m_ellapsed += delta;
		// Pass 1: centroid of all players on the XZ plane
		float cx = 0f, cz = 0f;
		int playerCount = 0;
		this.m_targetsQuery.Each<PlayerTag, RigidBody>(scope [&](entityRef, tag, rig) => {
			cx += rig.aabb.pos.x;
			cz += rig.aabb.pos.z;
			playerCount++;
		});

		if (playerCount == 0) return;
		cx /= (float)playerCount;
		cz /= (float)playerCount;

		// Pass 2: furthest player distance from centroid
		float maxSpread = 0f;
		this.m_targetsQuery.Each<PlayerTag, RigidBody>(scope [&](entityRef, tag, rig) => {
			float dx = rig.aabb.pos.x - cx;
			float dz = rig.aabb.pos.z - cz;
			float dist = (float)Math.Sqrt(dx * dx + dz * dz);
			if (dist > maxSpread) maxSpread = dist;
		});

		this.m_mainCamQuery.Each<MainCamTag, LocalTransform>(scope (entityRef, mainCam, xform) => {
			// Height tall enough to frame all players
			float height = Math.Max(mainCam.minHeight, maxSpread * ZOOM_MARGIN);

			// Z offset so the camera's 60° pitch ray hits the centroid:
			//   tan(pitch) = height / zOffset  →  zOffset = height / tan(pitch)
			float zOffset = height / (float)Math.Tan(PITCH_RAD);

			Vector3 targetPos = .(cx, height, cz + zOffset);

			this.m_currentPos = this.m_currentPos.Lerp(targetPos, Math.Min(mainCam.followSpeed * delta, 1f));
			// Add shake if needed
			if (mainCam.trauma > 0f) {
				float t = this.m_ellapsed * mainCam.noiseSpeed;

				let rotationNoise = MathUtils.GeneratePerlineNoise(t + 0f);
			    let xNoise = MathUtils.GeneratePerlineNoise(t + 100.0f);
			    let yNoise = MathUtils.GeneratePerlineNoise(t + 200.0f);				

				float shake = Math.Pow(mainCam.trauma, MainCamTag.TRAUMA_EXP);
				
			    // let rollOffset = rotationNoise * shake * mainCam.maxAngle;
			    let xOffset = xNoise * shake * mainCam.maxTranslation;
			    let yOffset = yNoise * shake * mainCam.maxTranslation;

				Vector3 pos = this.m_currentPos;
				// Vector3 euler = xform.GetEulerAngles();

				pos.x += xOffset;
				pos.z += yOffset;
				// euler.z += rollOffset;

				xform.SetPosition(pos);
				// xform.SetEulerAngles(&euler);

				mainCam.SetTrauma(mainCam.trauma - (mainCam.traumaDecayPerSecond * delta));
				return;
			}

			xform.SetPosition(this.m_currentPos);
		});
	}

	public void OnFixedUpdate(float delta) {}
	public void OnRender() {}
	public void OnPreRender() {}
	public void OnPostRender() {}
}
