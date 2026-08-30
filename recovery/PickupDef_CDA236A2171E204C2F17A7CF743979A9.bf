namespace BeefHush;

using System;

// Content definition for a pickup type: what to instantiate and what it does.
// Not a Hush component - plain data held in the registry below.
public struct PickupStat {
	public StringView meshPath;
	public float lifetime;     // seconds before the pickup despawns
	public float scale;        // render scale for the instanced mesh
}