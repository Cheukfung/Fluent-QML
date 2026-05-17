#!/usr/bin/env python3
import argparse
import platform
import subprocess
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parents[1]
GALLERY_NAME = "FluentQMLGallery"


def data_arg(source: str, target: str) -> str:
    separator = ";" if platform.system() == "Windows" else ":"
    return f"{source}{separator}{target}"


def default_icon() -> str:
    system = platform.system()
    if system == "Darwin":
        return "examples/assets/gallery.icns"
    if system == "Windows":
        return "examples/assets/gallery.ico"
    return "examples/assets/gallery.png"


def run(cmd: list[str]) -> None:
    print("+", " ".join(cmd), flush=True)
    subprocess.check_call(cmd, cwd=PROJECT_ROOT)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Package the FluentQML Gallery app.")
    parser.add_argument(
        "--name",
        default=GALLERY_NAME,
        help=f"PyInstaller app name. Defaults to {GALLERY_NAME}.",
    )
    parser.add_argument(
        "--icon",
        default=default_icon(),
        help="Application icon path.",
    )
    parser.add_argument(
        "--console",
        action="store_true",
        help="Keep the console window visible.",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    cmd = [
        "uv",
        "run",
        "--with",
        "pyinstaller",
        "pyinstaller",
        "--icon",
        args.icon,
        "--contents-directory",
        ".",
        "--add-data",
        data_arg("fluentqml", "fluentqml"),
        "--add-data",
        data_arg("examples/assets", "assets"),
        "--add-data",
        data_arg("examples/components", "components"),
        "--add-data",
        data_arg("examples/languages", "languages"),
        "--add-data",
        data_arg("examples/pages", "pages"),
        "--add-data",
        data_arg("examples/gallery.qml", "."),
        "--paths",
        ".",
        "--name",
        args.name,
    ]
    if not args.console:
        cmd.append("--noconsole")
    cmd.append("examples/gallery.py")
    run(cmd)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
