namespace BeefHush;

using System;
using System.Collections;
using Hush;

/// @brief Simple unbounded spatial grid implementation, this one unfortunately does allocate on the heap
struct SpatialGrid {

	private const float CELL_SIZE = 200.0f;
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
		uint32 x = (uint32)cell.x;
		uint32 y = (uint32)cell.y;
		uint32 z = (uint32)cell.z;

		// Combine using prime multiplication and XOR
		return (uint64)((x * P1) ^ (y * P2) ^ (z * P3));
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


