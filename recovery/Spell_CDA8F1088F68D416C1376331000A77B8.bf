namespace BeefHush;

using System;




[HushComponent, CRepr]
struct Spell
{
	public float fireRate;
	public float manaCost;
	public float lastFireTime;
	public float projectileSpeed;
	public float range;

	public static Spell makeKalaka (){
		Spell result = .();

	   return result;
	}

	
	public static Spell makeBox (){
		Spell result = .();
		result.fireRate = 1;
		result.lastFireTime = 0;
		result.manaCost = 10;
		result.projectileSpeed = 2f;
		result.range = 15;
	   return result;
	}
}
