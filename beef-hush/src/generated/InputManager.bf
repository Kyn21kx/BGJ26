namespace Hush;
using System;
public static class InputManager {

	public static void SetCursorLock(ECursorLockMode lockMode) {
		BeefHush.EngineDependencies.Instance.FunctionPointerTable.HushFuncPtr_Hush__InputManager__SetCursorLock(lockMode);
	}

	public static bool FetchCharThisFrame(char8* outChar) {
		return BeefHush.EngineDependencies.Instance.FunctionPointerTable.HushFuncPtr_Hush__InputManager__FetchCharThisFrame(outChar);
	}

	public static bool GetMouseButtonPressed(EMouseButton button) {
		return BeefHush.EngineDependencies.Instance.FunctionPointerTable.HushFuncPtr_Hush__InputManager__GetMouseButtonPressed(button);
	}

	public static bool IsKeyHeld(EKeyCode key) {
		return BeefHush.EngineDependencies.Instance.FunctionPointerTable.HushFuncPtr_Hush__InputManager__IsKeyHeld(key);
	}

	public static bool IsKeyUp(EKeyCode key) {
		return BeefHush.EngineDependencies.Instance.FunctionPointerTable.HushFuncPtr_Hush__InputManager__IsKeyUp(key);
	}

	public static bool IsKeyDownThisFrame(EKeyCode key) {
		return BeefHush.EngineDependencies.Instance.FunctionPointerTable.HushFuncPtr_Hush__InputManager__IsKeyDownThisFrame(key);
	}

	public static bool IsKeyDown(EKeyCode key) {
		return BeefHush.EngineDependencies.Instance.FunctionPointerTable.HushFuncPtr_Hush__InputManager__IsKeyDown(key);
	}

}