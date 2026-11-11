namespace Hush;
using System;
public static class InputManager {

	public static bool IsGamepadButtonUp(uint64 controllerIndex, EGamepadButton button) {
		return BeefHush.EngineDependencies.Instance.FunctionPointerTable.HushFuncPtr_Hush__InputManager__IsGamepadButtonUp(controllerIndex, button);
	}

	public static bool IsGamepadButtonDownThisFrame(uint64 controllerIndex, EGamepadButton button) {
		return BeefHush.EngineDependencies.Instance.FunctionPointerTable.HushFuncPtr_Hush__InputManager__IsGamepadButtonDownThisFrame(controllerIndex, button);
	}

	public static bool IsGamepadButtonHeld(uint64 controllerIndex, EGamepadButton button) {
		return BeefHush.EngineDependencies.Instance.FunctionPointerTable.HushFuncPtr_Hush__InputManager__IsGamepadButtonHeld(controllerIndex, button);
	}

	public static bool IsGamepadButtonDown(uint64 controllerIndex, EGamepadButton button) {
		return BeefHush.EngineDependencies.Instance.FunctionPointerTable.HushFuncPtr_Hush__InputManager__IsGamepadButtonDown(controllerIndex, button);
	}

	public static float GetGamepadAxis(uint64 controllerIndex, EGamepadAxis axis) {
		return BeefHush.EngineDependencies.Instance.FunctionPointerTable.HushFuncPtr_Hush__InputManager__GetGamepadAxis(controllerIndex, axis);
	}

	public static void SetCursorLock(ECursorLockMode lockMode) {
		BeefHush.EngineDependencies.Instance.FunctionPointerTable.HushFuncPtr_Hush__InputManager__SetCursorLock(lockMode);
	}

	public static Vector2 GetMouseAcceleration() {
		return BeefHush.EngineDependencies.Instance.FunctionPointerTable.HushFuncPtr_Hush__InputManager__GetMouseAcceleration();
	}

	public static Vector2 GetMousePosition() {
		return BeefHush.EngineDependencies.Instance.FunctionPointerTable.HushFuncPtr_Hush__InputManager__GetMousePosition();
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