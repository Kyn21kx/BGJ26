namespace BeefHush;

using Hush;
using System;

[HushComponent, CRepr]
struct Health {
	public float value;
	public function void(BeefHush.Entity*) onKilled;
}
