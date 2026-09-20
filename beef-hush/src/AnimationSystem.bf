namespace BeefHush;

using System;
using Hush;

[RegisterSystem]
public class AnimationSystem : GameSystem {
	Query m_oscillatedEntities;
	Query m_shakingEntities;
	Query m_tiltingEntities;

	public void Init()
	{
		QueryBuilder builder = .();
		builder.With<Oscillator>();
		builder.With<LocalTransform>();
		builder.With<WorldTransform>();


		this.m_oscillatedEntities = builder.Build();

		builder = .();
		builder.With<TiltAnimation>();
		builder.With<LocalTransform>();
		builder.With<WorldTransform>();

		this.m_tiltingEntities = builder.Build();

		this.m_oscillatedEntities.Each<Oscillator, LocalTransform, WorldTransform>(scope (entityRef, osc, local, globalXform) => {
			var globalScale = globalXform.GetScale();
			local.SetScale(globalScale);
		});

	}

	public void OnShutdown()
	{

	}

	private void Oscillate(float delta, BeefHush.Entity* entityRef, Oscillator* oscillator, LocalTransform* xform, WorldTransform* globalXform) {
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
	}

	private void Tilt(float delta, BeefHush.Entity* entityRef, TiltAnimation* tilter, LocalTransform* xform, WorldTransform* globalXform) {
		// Pitch up and down
		tilter.duration -= delta * tilter.speed;
		if (tilter.duration <= 0.0f) {
			entityRef.RemoveComponent<TiltAnimation>();
			return;
		}
		Vector3 rot = xform.GetEulerAngles();
		if (tilter.direction > 0) {
			rot.x += 35 * delta;
		}
		else {
			rot.x -= 90 * delta;
		}

		xform.SetEulerAngles(&rot);
	}

	public void OnUpdate(float delta)
	{
		this.m_oscillatedEntities.Each<Oscillator, LocalTransform, WorldTransform>(scope (entityRef, oscillator, xform, globalXform) => {
			Oscillate(delta, &entityRef, oscillator, xform, globalXform);
		});
		this.m_tiltingEntities.Each<TiltAnimation, LocalTransform, WorldTransform>(scope (entityRef, tilter, xform, globalXform) => {
			Tilt(delta, &entityRef, tilter, xform, globalXform);
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
