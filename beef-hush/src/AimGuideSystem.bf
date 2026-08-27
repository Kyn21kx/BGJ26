namespace BeefHush;

using Hush;
using System;

[RegisterSystem]
class AimGuideSystem : GameSystem
{
	Query m_aimGuideQuery;
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

	public void OnUpdate(float delta)
	{
		if (!this.instanced) {
			this.InitEntity();
			this.instanced = true;
		}
		this.m_aimGuideQuery.Each<LocalTransform, AimGuide>(scope (entityRef, xform, guide) => {
			xform.SetPosition(GetPosInWorldSpace(guide.depth));
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
