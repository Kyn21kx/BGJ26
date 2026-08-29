namespace BeefHush;

using System;
using Hush;

[RegisterSystem]
public class AnimationSystem : GameSystem {
	Query m_oscillatedEntities;

	public void Init()
	{
		QueryBuilder builder = .();
		builder.With<Oscillator>();
		builder.With<LocalTransform>();
		builder.With<WorldTransform>();

		this.m_oscillatedEntities = builder.Build();

		this.m_oscillatedEntities.Each<Oscillator, LocalTransform, WorldTransform>(scope (entityRef, osc, local, globalXform) => {
			var globalScale = globalXform.GetScale();
			local.SetScale(globalScale);
		});

	}

	public void OnShutdown()
	{

	}

	public void OnUpdate(float delta)
	{
		this.m_oscillatedEntities.Each<Oscillator, LocalTransform, WorldTransform>(scope (entityRef, oscillator, xform, globalXform) => {
			// Go from height min to height max treating height min as a constant
			oscillator.blend += delta * oscillator.speed;
			// This is in absolute Y-coords
			float currHeight = 0;
			if (oscillator.blend >= 1f) {
				oscillator.direction = -oscillator.direction;
				oscillator.blend = 0f;
			}
			if (oscillator.direction > 0) {
				currHeight = MathUtils.EaseInOut(oscillator.heightMin, oscillator.heightMax, oscillator.blend);
			}
			else {
				currHeight = MathUtils.EaseInOut(oscillator.heightMax, oscillator.heightMin, oscillator.blend);
			}
			Vector3 val = globalXform.GetPositionValue();
			val.y = currHeight;
			globalXform.SetPosition(val);
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
