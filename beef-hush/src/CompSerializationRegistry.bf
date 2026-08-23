namespace BeefHush;

using System;
using System.Collections;

public enum ECompPropertyType : int32
{
	Unknown = 0,
	I8,
	U8,
	I16,
	U16,
	I32,
	U32,
	I64,
	U64,
	F32,
	F64,
	Bool,
	String,
	Array,
}

[CRepr]
public struct CompPropertyInfo
{
	public const int MAX_PROP_NAME = 64;
	public char8[MAX_PROP_NAME] name;
	public ECompPropertyType type;
	public uint32 elementCount;
	public uint32 elementSize;

	public this(StringView name, ECompPropertyType type, uint32 elementCount, uint32 elementSize)
	{
		this.name = "";
		name.CopyTo(this.name);
		this.type = type;
		this.elementCount = elementCount;
		this.elementSize = elementSize;
	}
}

[CRepr]
public struct CompSerializationInfo
{
	public const int MAX_COMP_NAME = RegTypeInfo.MAX_SYS_NAME;
	public char8[MAX_COMP_NAME] name;
	public int32 registryIndex;
	public uint64 byteSize;
	public uint64 align;
	public CompPropertyInfo* properties;
	public uint32 propertyCount;

	public this(StringView name, int32 registryIndex, uint64 byteSize, uint64 align, CompPropertyInfo* properties, uint32 propertyCount)
	{
		this.name = "";
		name.CopyTo(this.name);
		this.registryIndex = registryIndex;
		this.byteSize = byteSize;
		this.align = align;
		this.properties = properties;
		this.propertyCount = propertyCount;
	}
}

[AttributeUsage(.Class)]
struct CompSerializationRegistryAttribute : Attribute, IComptimeTypeApply
{
	[Comptime]
	private static bool TypeHasCustomAttribute(TypeDeclaration t, Type attribute)
	{
		if (Compiler.IsComptime)
		{
			int32 attrIdx = -1;
			Type attrType = null;
			repeat
			{
				attrType = Type.[Friend]Comptime_Type_GetCustomAttributeType((int32)t.TypeId, ++attrIdx);
				if (attrType == attribute)
					return true;
			}
			while (attrType != null);
		}
		return false;
	}

	[Comptime]
	private static StringView MapTypeCode(TypeCode typeCode)
	{
		// TODO: This should counsult Hush's reflection DB at runtime if unknown
		switch (typeCode)
		{
		case .Int8:     return ".I8";
		case .UInt8:    return ".U8";
		case .Int16:    return ".I16";
		case .UInt16:   return ".U16";
		case .Int32:    return ".I32";
		case .UInt32:   return ".U32";
		case .Int64:    return ".I64";
		case .UInt64:   return ".U64";
		case .Float:    return ".F32";
		case .Double:   return ".F64";
		case .Boolean:  return ".Bool";
		default:        return ".Unknown";
		}
	}

	[Comptime]
	public void ApplyToType(Type type)
	{
		var registeredTypes = scope List<Type>();
		String typeNameBuff = scope String(CompSerializationInfo.MAX_COMP_NAME * 2);

		for (let t in Type.TypeDeclarations)
		{
			int32 tId = (int32)t.TypeId;
			if (tId <= 0) continue;
			if (!TypeHasCustomAttribute(t, typeof(HushComponentAttribute))) continue;
			let resolved = t.ResolvedType;
			if (resolved == null) continue;
			registeredTypes.Add(resolved);
		}

		let count = registeredTypes.Count;
		var code = scope String();
		code.AppendF($"public const int Count = {count};\n");

		for (int i < count)
		{
			typeNameBuff.Clear();
			registeredTypes[i].GetFullName(typeNameBuff);
			let compType = registeredTypes[i];
			let compName = compType.GetName(.. scope String());

			var propLines = scope String();
			int32 propCount = 0;

			for (let field in compType.GetFields())
			{
				if (field.IsStatic) continue;

				let ft = field.FieldType;
				let fname = field.Name;

				if (ft.IsArray)
				{
					uint32 totalSize = (uint32)ft.Size;
					uint32 elemSize = 1;
					bool isCharArray = false;

					// Beef represents fixed-size arrays internally as a struct of N identical
					// fields, so GetField(0) yields the element type.
					if (ft.FieldCount > 0)
					{
						let elemField = ft.GetField(0);
						if (elemField != null)
						{
							elemSize = (uint32)elemField.GetType().Size;
							isCharArray = elemField.GetType() == typeof(char8);
						}
					}

					uint32 elemCount = (elemSize > 0) ? totalSize / elemSize : 0;
					StringView propTypeStr = isCharArray ? ".String" : ".Array";
					propLines.AppendF($"    .(\"{fname}\", {propTypeStr}, {elemCount}, {elemSize}),\n");
				}
				else
				{
					StringView variant = MapTypeCode(ft.TypeDeclaration.TypeCode);
					propLines.AppendF($"    .(\"{fname}\", {variant}, 0, 0),\n");
				}
				propCount++;
			}

			if (propCount > 0)
			{
				code.AppendF($"public static CompPropertyInfo[{propCount}] Entry{i}Properties = .(\n");
				code.Append(propLines);
				code.Append(");\n");
				code.AppendF($"public static readonly CompSerializationInfo Entry{i} = .(\"{compName}\", {i}, sizeof({typeNameBuff}), alignof({typeNameBuff}), &Entry{i}Properties[0], {propCount});\n");
			}
			else
			{
				code.AppendF($"public static readonly CompSerializationInfo Entry{i} = .(\"{compName}\", {i}, sizeof({typeNameBuff}), alignof({typeNameBuff}), null, 0);\n");
			}
		}

		code.Append("public static readonly CompSerializationInfo[Count] All = .(\n");
		for (int i < count)
			code.AppendF($"    Entry{i},\n");
		code.Append(");\n");

		Compiler.EmitTypeBody(type, code);
	}
}

[CompSerializationRegistry]
public static class CompSerializationRegistryImpl {}
