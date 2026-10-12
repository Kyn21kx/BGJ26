import os
import shutil

# Just build the game and copy the dll into the modules/beef-hush/bin folder
SRC_DIR = "./modules/beef-hush"
TARGET_BIN_DIR = "./modules/beef-hush/bin"
EXEC_NAME = "beef-hush.dll"
DBG_INFO_NAME = "beef-hush.pdb"


currDir = os.getcwd()
os.chdir(SRC_DIR)
errCode = os.system("BeefBuild")
if errCode != 0:
	print("Could not build project! Returned with code: ", errCode);
	exit(errCode)
os.chdir(currDir)
shutil.copyfile(SRC_DIR + "/build/Debug_Win64/beef-hush/" + EXEC_NAME, TARGET_BIN_DIR + "/" + EXEC_NAME)
shutil.copyfile(SRC_DIR + "/build/Debug_Win64/beef-hush/" + DBG_INFO_NAME, TARGET_BIN_DIR + "/" + DBG_INFO_NAME)
print("Binary Library available at ", TARGET_BIN_DIR)



