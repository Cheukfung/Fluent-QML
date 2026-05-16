#!/usr/bin/env python3
import hashlib
import subprocess
import sys
from pathlib import Path

INCLUDE_EXTS = {".qml", ".qm", ".ttf", ".otf", ".svg", ".png", ".jpg", ".jpeg", ".js"}
QRC_PREFIX = "/RinUI"


def get_rcc_path() -> str:
    try:
        import PySide6

        pyside6_dir = Path(PySide6.__file__).parent
        rcc_path = pyside6_dir / "rcc.exe"
        if rcc_path.exists():
            return str(rcc_path)
    except ImportError:
        pass

    return "pyside6-rcc"


def discover_files(rinui_dir: Path) -> list[str]:
    files: list[str] = []
    for path in rinui_dir.rglob("*"):
        if path.is_file() and (path.name == "qmldir" or path.suffix.lower() in INCLUDE_EXTS):
            files.append(path.relative_to(rinui_dir).as_posix())
    return sorted(set(files))


def write_qrc(rinui_dir: Path, files: list[str]) -> Path:
    qrc_path = rinui_dir / "rinui.qrc"
    lines = ["<!DOCTYPE RCC>", '<RCC version="1.0">', f'  <qresource prefix="{QRC_PREFIX}">']
    for file in files:
        lines.append(f"    <file>{file}</file>")
    lines += ["  </qresource>", "</RCC>"]
    qrc_path.write_text("\n".join(lines), encoding="utf-8")
    return qrc_path


def calc_digest(rinui_dir: Path, files: list[str]) -> str:
    digest = hashlib.sha256()
    for file in files:
        path = rinui_dir / file
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
    cmd = [get_rcc_path(), "--generator", "python", qrc_path.as_posix(), "-o", out_py.as_posix()]
    print("Running:", " ".join(cmd))
    subprocess.check_call(cmd)


def main() -> int:
    project_root = Path(__file__).resolve().parents[1]
    rinui_dir = project_root / "RinUI"
    files = discover_files(rinui_dir)
    qrc_path = write_qrc(rinui_dir, files)
    out_py = rinui_dir / "rinui_rc.py"
    digest_path = rinui_dir / "rinui.qrc.sha256"
    digest = calc_digest(rinui_dir, files)

    if should_rebuild(digest_path, digest, [qrc_path, out_py]):
        build_rc(qrc_path, out_py)
        digest_path.write_text(digest + "\n", encoding="utf-8")
        print(f"Generated {out_py}")
    else:
        print("No changes in /RinUI resources, skip rebuild")

    return 0


if __name__ == "__main__":
    sys.exit(main())
