namespace BeefHush;

using Hush;
using System;

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

	public void Init()
	{
		QueryBuilder builder = .();
		builder.With<MainCamTag>();
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

	public void OnShutdown() {}

	public void OnUpdate(float delta)
	{
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

			xform.SetPosition(this.m_currentPos);
		});

	}

	public void OnFixedUpdate(float delta) {}
	public void OnRender() {}
	public void OnPreRender() {}
	public void OnPostRender() {}
}
