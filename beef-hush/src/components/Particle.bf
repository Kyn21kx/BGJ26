namespace BeefHush;

using Hush;
using System;

[HushComponent, CRepr]
struct ParticleEmitter {
	public int32 maxParticles;
	public float emitRate;
	public float lastEmissionTime;
	public uint32 particleAssetId;
}

[HushComponent, CRepr]
struct Particle
{
}
