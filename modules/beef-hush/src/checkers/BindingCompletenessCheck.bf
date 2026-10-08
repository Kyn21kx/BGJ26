namespace BeefHush;

using System;
using System.Collections;
using System.Reflection;
using System.Diagnostics;

struct BindingCompletenessCheck<Bindee, Binder> {

	[Comptime]
	protected static bool AllMethodsCovered() {
		// Get all instance methods that are relevant
		let BINDEE_TYPE = typeof(Bindee);
		let BINDER_TYPE = typeof(Binder);

		const BindingFlags METHOD_FILTER = .Instance | .GetField | .GetProperty;
		MethodInfo.Enumerator bindeeMethods = BINDEE_TYPE.GetMethods(METHOD_FILTER);
		MethodInfo.Enumerator wrapperMethods = BINDER_TYPE.GetMethods(METHOD_FILTER);

		// Create a collection of already used methods
		const int GUESS_METHOD_COUNT = 20;
		let bindeeMethodNames = scope List<StringView>(GUESS_METHOD_COUNT);
		let checkedMethods = scope HashSet<StringView>(GUESS_METHOD_COUNT);

		for (let bindeeMethod in bindeeMethods) {
			bindeeMethodNames.Add(bindeeMethod.Name);
		}

		String methodBodyBuffer = scope String(1024 * 4);
		for (let wrapperMethod in wrapperMethods) {
			wrapperMethod.ToString(methodBodyBuffer);
			for (let bindeeMethodName in bindeeMethodNames) {
				if (checkedMethods.Contains(bindeeMethodName) || !methodBodyBuffer.Contains(bindeeMethodName)) continue;
				checkedMethods.Add(bindeeMethodName);
			}
		}

		FieldInfo.Enumerator wrapperFields = BINDER_TYPE.GetFields(METHOD_FILTER);

		for (let wrapperField in wrapperFields) {
			wrapperField.ToString(methodBodyBuffer);
			for (let bindeeMethodName in bindeeMethodNames) {
				if (checkedMethods.Contains(bindeeMethodName) || !methodBodyBuffer.Contains(bindeeMethodName)) continue;
				checkedMethods.Add(bindeeMethodName);
			}
		}

		
		if (checkedMethods.Count < bindeeMethodNames.Count) {
			String binderName = scope String(64);
			String bindeeName = scope String(64);
			BINDER_TYPE.GetFullName(binderName);
			BINDEE_TYPE.GetFullName(bindeeName);
			Debug.FatalError(scope $"Method call count ({checkedMethods.Count}) for binder ({binderName}) does not match the bindee's ({bindeeName}) count ({bindeeMethodNames.Count}), make sure to call all of the bindee's methods somewhere in your binding wrapper");
		}
		
		return checkedMethods.Count == bindeeMethodNames.Count;
	}

}
