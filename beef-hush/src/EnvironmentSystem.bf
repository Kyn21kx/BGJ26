namespace BeefHush;

using Hush;
using System;

[RegisterSystem]
class EnvironmentSystem : GameSystem
{
	const float WIDTH = 30f;
	const float HEIGHT = 20f;
	const float CELL_SIZE = 0.768f;
	const Vector3 SCALE = Constants.Vector3_ONE * 0.415f;

	public void Init()
	{
		void* scene = HushEngine.GetScene(EngineDependencies.Instance.Engine);
		const StringView renderSystemName = "RenderingSystem";
		let renderingSysEnt = BeefHush.Entity(Scene.CreateEntityWithKey(scene, &(renderSystemName[0]), (uint64)renderSystemName.Length));

		let renderAPI = renderingSysEnt.GetComponent<RenderingSystemAPI>();

		BeefHush.Entity parent = .(Scene.CreateEntityWithName(scene, "Floor", (uint64)("Floor").Length));
		// Spawn a tile every X
		for (int32 i = 0; i < WIDTH; i++) {
			for (int32 j = 0; j < HEIGHT; j++) {
				Vector3 position = .(i * CELL_SIZE, 0f, j * CELL_SIZE);
				uint64 rootEntId = renderAPI.instantiateMeshEntities("res://StoneGround.glb", renderAPI.instance);
				BeefHush.Entity rootEnt = .(Scene.EntityFromIdUnchecked(scene, rootEntId));
				parent.AddChild(ref rootEnt);
				var localXform = rootEnt.GetComponent<LocalTransform>();
				localXform.SetPosition(position);
				localXform.SetScale(SCALE);
			}
		}
	}

	public void OnShutdown()
	{

	}

	public void OnUpdate(float delta)
	{

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