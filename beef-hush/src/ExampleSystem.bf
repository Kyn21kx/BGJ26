namespace BeefHush;

using Hush;
using System;


[HushComponent, CRepr]
struct JohanIdentifier {
	public bool isChecked;
	public int32 id;
}


[RegisterSystem]
class ExampleSystem : GameSystem
{
	Query m_johanssQuery;

	public void Init()
	{
		QueryBuilder builder = .();
		builder.With<JohanIdentifier>();
		this.m_johanssQuery = builder.Build();
	}

	public void OnShutdown()
	{

	}

	public void OnUpdate(float delta)
	{
		this.m_johanssQuery.Each<JohanIdentifier>(scope (entityRef, johanID) => {
			Console.WriteLine($"Matched on entity {entityRef.Id}, Johan ID: {johanID.id}, IsChecked: {johanID.isChecked}");
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