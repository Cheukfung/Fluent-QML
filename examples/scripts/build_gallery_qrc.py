#!/usr/bin/env python3
import argparse
import hashlib
import subprocess
import sys
from pathlib import Path

INCLUDE_EXTS = {".qml", ".qm", ".ttf", ".otf", ".svg", ".png", ".jpg", ".jpeg", ".js"}
QRC_PREFIX = "/FluentQMLGallery"
EXAMPLES_DIR_NAME = "examples"
QRC_FILE_NAME = "gallery.qrc"
RC_FILE_NAME = "gallery_rc.py"
DIGEST_FILE_NAME = "gallery.qrc.sha256"
RESOURCE_DIRS = {"assets", "components", "languages", "pages"}
RESOURCE_FILES = {"gallery.qml"}


def get_rcc_command() -> list[str]:
    executable_dir = Path(sys.executable).parent
    pyside6_rcc = executable_dir / "pyside6-rcc"
    if pyside6_rcc.exists():
        return [
            sys.executable,
            "-c",
            "from PySide6.scripts.pyside_tool import rcc; raise SystemExit(rcc())",
        ]

    try:
        import PySide6

        pyside6_dir = Path(PySide6.__file__).parent
        rcc_path = pyside6_dir / "rcc.exe"
        if rcc_path.exists():
            return [str(rcc_path)]
    except ImportError:
        pass

    return ["pyside6-rcc"]


def should_include(path: Path, examples_dir: Path) -> bool:
    rel_path = path.relative_to(examples_dir)
    parts = rel_path.parts
    if path.name == "qmldir":
        return bool(parts and parts[0] in RESOURCE_DIRS)
    if path.name in RESOURCE_FILES:
        return True
    if not parts or parts[0] not in RESOURCE_DIRS:
        return False
    return path.suffix.lower() in INCLUDE_EXTS


def discover_files(examples_dir: Path) -> list[str]:
    files: list[str] = []
    for path in examples_dir.rglob("*"):
        if path.is_file() and should_include(path, examples_dir):
            files.append(path.relative_to(examples_dir).as_posix())
    return sorted(set(files))


def write_qrc(examples_dir: Path, files: list[str]) -> Path:
    qrc_path = examples_dir / QRC_FILE_NAME
    lines = [
        "<!DOCTYPE RCC>",
        '<RCC version="1.0">',
        f'  <qresource prefix="{QRC_PREFIX}">',
    ]
    for file in files:
        lines.append(f"    <file>{file}</file>")
    lines += ["  </qresource>", "</RCC>"]
    qrc_path.write_text("\n".join(lines), encoding="utf-8")
    return qrc_path


def calc_digest(examples_dir: Path, files: list[str]) -> str:
    digest = hashlib.sha256()
    digest.update(f"prefix:{QRC_PREFIX}\0".encode())
    digest.update(f"script:{Path(__file__).name}\0".encode())
    digest.update(f"rc:{RC_FILE_NAME}\0".encode())
    for file in files:
        path = examples_dir / file
        digest.update(file.encode("utf-8"))
        digest.update(b"\0")
        digest.update(path.read_bytes())
        digest.update(b"\0")
    return digest.hexdigest()


def should_rebuild(digest_path: Path, digest: str, outputs: list[Path]) -> bool:
    if any(not output.exists() for output in outputs):
        return True
    if not digest_path.exists():
        return True
    return digest_path.read_text(encoding="utf-8").strip() != digest


def build_rc(qrc_path: Path, out_py: Path) -> None:
    cmd = [
        *get_rcc_command(),
        "--generator",
        "python",
        qrc_path.as_posix(),
        "-o",
        out_py.as_posix(),
    ]
    print("Running:", " ".join(cmd))
    subprocess.check_call(cmd)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Build the FluentQML Gallery Qt resource Python module."
    )
    parser.add_argument(
        "--force",
        action="store_true",
        help="Rebuild gallery_rc.py even when the resource digest is unchanged.",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    examples_dir = Path(__file__).resolve().parents[1]
    if examples_dir.name != EXAMPLES_DIR_NAME:
        msg = f"Expected script to live under {EXAMPLES_DIR_NAME}/scripts"
        raise RuntimeError(msg)

    files = discover_files(examples_dir)
    qrc_path = write_qrc(examples_dir, files)
    out_py = examples_dir / RC_FILE_NAME
    digest_path = examples_dir / DIGEST_FILE_NAME
    digest = calc_digest(examples_dir, files)

    if args.force or should_rebuild(digest_path, digest, [qrc_path, out_py]):
        build_rc(qrc_path, out_py)
        digest_path.write_text(digest + "\n", encoding="utf-8")
        print(f"Generated {out_py}")
    else:
        print("No changes in /FluentQMLGallery resources, skip rebuild")

    return 0


if __name__ == "__main__":
    sys.exit(main())
