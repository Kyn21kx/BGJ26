namespace BeefHush;

using System;
using System.Collections;
using Hush;

/// @brief Simple unbounded spatial grid implementation, this one unfortunately does allocate on the heap
struct SpatialGrid {

	private const float CELL_SIZE = 2f; // TODO: benchmark
	private const float INV_CELL_SIZE = 1.0f / CELL_SIZE;
	private Dictionary<uint64, List<uint64>> m_entitiesAtCell;

	public void Init() mut {
		this.m_entitiesAtCell = new .();
	}

	public I32Vector3 GetCellIndex(Vector3 position) {
		return .(
			(int32)Math.Floor(position.x * INV_CELL_SIZE),
			(int32)Math.Floor(position.y * INV_CELL_SIZE),
			(int32)Math.Floor(position.z * INV_CELL_SIZE)
		);
	}

	public uint64 HashCell(I32Vector3 cell) {

		const uint32 P1 = 73856093;
		const uint32 P2 = 19349663;
		const uint32 P3 = 83492791;

		// Reinterpret cast to uint32_t (preserves bit pattern)
		uint64 x = (uint64)cell.x;
		uint64 y = 0; // Keep in XZ plane
		uint64 z = (uint64)cell.z;

		// Combine using prime multiplication and XOR
		uint64 hash = unchecked((x * P1) ^ (y * P2) ^ (z * P3));
		return (uint64)hash;
	}

	public void EachNeighborAt(Vector3 pos, int32 depth, uint64 except, delegate void(uint64) callable) {
		I32Vector3 truncated = this.GetCellIndex(pos);
		for (int32 dx = -depth; dx <= depth; dx++) {
			for (int32 dz = -depth; dz <= depth; dz++) {
				I32Vector3 targetCell = .();
				targetCell.x = unchecked(truncated.x + dx);
				targetCell.z = unchecked(truncated.z + dz);
				uint64 hash = this.HashCell(targetCell);
				uint64 outKey;
				List<uint64> entitiesAt;
				bool contains = this.m_entitiesAtCell.TryGet(hash, out outKey, out entitiesAt);
				for (int32 i = 0; contains && i < entitiesAt.Count; i++) {
					if (entitiesAt[i] == except) continue;
					callable(entitiesAt[i]);
				}
			}
		}
	}

	public bool UntilNeighborAt(Vector3 pos, int32 depth, uint64 except, delegate bool(uint64) callable) {
		I32Vector3 truncated = this.GetCellIndex(pos);
		for (int32 dx = -depth; dx <= depth; dx++) {
			for (int32 dz = -depth; dz <= depth; dz++) {
				I32Vector3 targetCell = .();
				targetCell.x = unchecked(truncated.x + dx);
				targetCell.z = unchecked(truncated.z + dz);
				uint64 hash = this.HashCell(targetCell);
				uint64 outKey;
				List<uint64> entitiesAt;
				bool contains = this.m_entitiesAtCell.TryGet(hash, out outKey, out entitiesAt);
				for (int32 i = 0; contains && i < entitiesAt.Count; i++) {
					if (entitiesAt[i] == except) continue;
					if (callable(entitiesAt[i])) {
						return true;
					}
				}
			}
		}
		return false;
	}

	public void RegisterEntityAt(uint64 entity, Vector3 position) {
		I32Vector3 cellIndex = this.GetCellIndex(position);
		uint64 hashedCell = this.HashCell(cellIndex);

		List<uint64> foundEntities;
		uint64 outKey;
		bool contains = this.m_entitiesAtCell.TryGet(hashedCell, out outKey, out foundEntities);
		if (!contains) {
			foundEntities = new .();
			this.m_entitiesAtCell[hashedCell] = foundEntities;
		}
		foundEntities.Add(entity);
	}

	public void ClearNoFree() {
		for (var entry in this.m_entitiesAtCell) {
			entry.value.Clear();
		}
	}
	
	public void Dispose() {
		for (var entry in this.m_entitiesAtCell) {
			delete entry.value;
		}
		delete this.m_entitiesAtCell;
	}
}


