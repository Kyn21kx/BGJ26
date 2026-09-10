namespace BeefHush;

using Hush;
using System;

[HushComponent, CRepr]
struct ParticleEmitter {
	public int32 maxParticles;
	public int32 currentParticleCount;

	public float emitRate;
	public float lastEmissionTime;
	//index al array de meshes
	public uint32 particleAssetId;
	public float particleLifeTime;
	public float minScale;
	public float maxScale;
	public Vector3 velocity;
}
