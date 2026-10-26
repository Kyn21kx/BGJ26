import shutil
import subprocess
from pathlib import Path

SRC_HEADER = Path(r"C:\Users\nefes\Personal\Hush-Engine\src\bindings\HushBindings.h")
BINDING_GEN_DIR = Path(r"C:\Users\nefes\Personal\HushBindingGen")
GENERATED_SRC = BINDING_GEN_DIR / "C:\\Users\\nefes\\Personal\\HushBindingGen\\beef-hush\\src\\generated"
GENERATED_DST = Path(r"C:\Users\nefes\Personal\BGJ26\modules\beef-hush\src\generated")

print(f"Copying {SRC_HEADER.name} to {BINDING_GEN_DIR} ...")
shutil.copy2(SRC_HEADER, BINDING_GEN_DIR / SRC_HEADER.name)

print("Running BeefBuild ...")
subprocess.run(["BeefBuild", "run"], cwd=BINDING_GEN_DIR)

print(f"Copying generated/ to {GENERATED_DST} ...")
if GENERATED_DST.exists():
    shutil.rmtree(GENERATED_DST)
shutil.copytree(GENERATED_SRC, GENERATED_DST)

print("Done.")
