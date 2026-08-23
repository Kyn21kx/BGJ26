namespace BeefHush;

using System;
using System.Diagnostics;
using System.Collections;

[AttributeUsage(.Class)]
public struct HushComponent : Attribute {
}

[AttributeUsage(.Class)]
struct SystemRegistryAttribute : Attribute, IComptimeTypeApply
{
    [Comptime]
    public void ApplyToType(Type type)
    {
        var systems = scope List<Type>();
		String typeNameBuff = scope String(SystemInfo.MAX_SYS_NAME * 2);
        for (let t in Type.TypeDeclarations)
        {
			int32 tId = (int32)t.TypeId;
			if (tId <= 0) continue;
			// TypeCode and custom-attribute data live in the declaration struct,
			// written at parse time — safe to read during BfSystem_FixTypes before
			// the resolved TypeInstance is fully populated.
			if (t.TypeCode != .Object) continue;
			if (!t.HasCustomAttribute<RegisterSystemAttribute>()) continue;

			let resolved = t.ResolvedType;
			if (resolved == null) continue;
            systems.Add(resolved);
        }

        let count = systems.Count;
        var code = scope String();

        // Bake count as a compile-time constant
        code.AppendF($"public const int Count = {count};\n");

        // Bake each SystemInfo as a named const field
        for (int i < count)
        {
            let name = systems[i].GetName(.. scope String());
            // Emit a fixed char array initializer matching SystemInfo.name layout
            code.AppendF($"public static readonly SystemInfo System{i} = ");
            code.AppendF($".(\"{name}\", {i});\n");
        }

        // Emit a flat array of all infos for bulk access
		String flatArrayBuffer = scope .();
		String lookupBuffer = scope .();
		flatArrayBuffer.Append($"public static readonly SystemInfo[Count] All = .(\n");
        lookupBuffer.Append($"public static readonly Type[Count] TypeLookup = .(\n");
        for (int i < count)
        {
			typeNameBuff.Clear();
			systems[i].GetFullName(typeNameBuff);
			flatArrayBuffer.AppendF($"    System{i},\n");
            lookupBuffer.AppendF($"    typeof({typeNameBuff}),\n");
        }
		flatArrayBuffer.Append(");\n");
        lookupBuffer.Append(");\n");

		code.Append(flatArrayBuffer);
		code.Append(lookupBuffer);

		code.Append("[Export]\n");
		code.Append("public static void __ForceInclude()\n{\n");
		for (int i < count)
		{
		    let fullName = systems[i].GetFullName(.. scope String());
		    code.AppendF($"    if (true) {{ {fullName} _ = new .(); delete _; }}\n");
		}
		code.Append("}\n");

        Compiler.EmitTypeBody(type, code);
    }
}

[SystemRegistry]
public static class SystemRegistryImpl {}

public class EngineDependencies {

	public static EngineDependencies Instance {
		get {
			if (s_instance == null) {
				s_instance = new EngineDependencies();
			}
			return s_instance;
		}
	}

	private static EngineDependencies s_instance = null;

	public Hush.HushFuncPtrTable* FunctionPointerTable {
		get => this.m_functionPtrTable;
		private set {
			this.m_functionPtrTable = value;
		}
	}

	public void* Engine {
		get => this.m_engine;
		private set {
			this.m_engine = value;
		}
	}

	private Hush.HushFuncPtrTable* m_functionPtrTable;
	private void* m_engine;

	public void Provision(Hush.HushFuncPtrTable* table, void* engine) {
		this.m_functionPtrTable = table;
		this.m_engine = engine;
	}

}

public static class Exports {

	[Export, CLink]
	public static void StartScriptingConnection(Hush.HushFuncPtrTable* table, void* engine) {
		EngineDependencies.Instance.Provision(table, engine);
	}

	[Export, CLink]
	public static uint8* InstantiateSystem(SystemInfo* systemInfo) {
		Debug.Assert(systemInfo != null, "Cannot instantiate a system with null info");
		StringView sysName = .(&systemInfo.name[0]);

		int32 assumedSystemIdx = systemInfo.registryIndex;
		// Debug.Assert(assumedSystemIdx >= SystemRegistryImpl.Count, scope $"System index {systemInfo.registryIndex} is out of bounds for system count {SystemRegistryImpl.Count}");


		Type assumedSystemInfoType = SystemRegistryImpl.TypeLookup[assumedSystemIdx];
		// let typeRes = Type.GetTypeByName(sysName);

		// if (typeRes case .Err(let err)) {
		// 	Debug.FatalError(scope $"Could not find a system with the name {sysName}");
		// }

		var instanceRes = assumedSystemInfoType.CreateObject();

		if (instanceRes case .Err(let instanceErr)) {
			Debug.FatalError(scope $"Unable to create system {sysName}, error: {instanceErr}");
		}

		Object result = instanceRes.Value;
		var systemResult = (GameSystem)result;
		// Who knows lol
		return (uint8*)Internal.UnsafeCastToPtr(systemResult);
	}

	[Export, CLink]
	public static uint64 GetSystemCount() {
		return SystemRegistryImpl.Count;
	}

	[Export, CLink]
	public static bool GetAvailableSystems(SystemInfo** outSystemInfoArr, uint64 capacity) {
		// Array should be allocated by default
		Debug.Assert(outSystemInfoArr != null && outSystemInfoArr != null);
		Runtime.Assert(capacity >= SystemRegistryImpl.Count, scope $"The systemInfo array does not have enough capacity({capacity}) to store all systems ({SystemRegistryImpl.Count})");

		uint64 cntr = 0;
		for (let systemInfo in SystemRegistryImpl.All) {
			// We add it to our systems array
			// Add the system to the list
			(*outSystemInfoArr)[cntr] = systemInfo;
			cntr++;
		}

		return false;
	}

	[Export, CLink]
	public static void CallSystemInit(void* systemHandle) {
		Debug.Assert(systemHandle != null, "Cannot call init on null system!");
		Object objectHandle = Internal.UnsafeCastToObject(systemHandle);
		var systemImpl = (GameSystem)objectHandle;
		systemImpl.Init();
	}
	
	[Export, CLink]
	public static void CallSystemOnUpdate(void* systemHandle, float delta) {
		Debug.Assert(systemHandle != null, "Cannot call OnUpdate on null system!");
		Object objectHandle = Internal.UnsafeCastToObject(systemHandle);
		var systemImpl = (GameSystem)objectHandle;
		systemImpl.OnUpdate(delta);
	}

	[Export, CLink]
	public static void CallSystemOnFixedUpdate(void* systemHandle, float delta) {
		Debug.Assert(systemHandle != null, "Cannot call OnFixedUpdate on null system!");
		Object objectHandle = Internal.UnsafeCastToObject(systemHandle);
		var systemImpl = (GameSystem)objectHandle;
		systemImpl.OnFixedUpdate(delta);
	}
	
	[Export, CLink]
	public static void CallSystemOnShutdown(void* systemHandle) {
		Debug.Assert(systemHandle != null, "Cannot call OnShutdown on null system!");
		Object objectHandle = Internal.UnsafeCastToObject(systemHandle);
		var systemImpl = (GameSystem)objectHandle;
		systemImpl.OnShutdown();
	}
	
	[Export, CLink]
	public static void CallSystemOnRender(void* systemHandle) {
		Debug.Assert(systemHandle != null, "Cannot call OnRender on null system!");
		Object objectHandle = Internal.UnsafeCastToObject(systemHandle);
		var systemImpl = (GameSystem)objectHandle;
		systemImpl.OnRender();
	}

	[Export, CLink]
	public static void CallSystemOnPreRender(void* systemHandle) {
		Debug.Assert(systemHandle != null, "Cannot call OnPreRender on null system!");
		Object objectHandle = Internal.UnsafeCastToObject(systemHandle);
		var systemImpl = (GameSystem)objectHandle;
		systemImpl.OnPreRender();
	}
	
	[Export, CLink]
	public static void CallSystemOnPostRender(void* systemHandle) {
		Debug.Assert(systemHandle != null, "Cannot call OnPostRender on null system!");
		Object objectHandle = Internal.UnsafeCastToObject(systemHandle);
		var systemImpl = (GameSystem)objectHandle;
		systemImpl.OnPostRender();
	}

	[Export, CLink]
	public static void DisposeScriptingConnection() {
		delete EngineDependencies.Instance;
	}
	
	
}
