#!/usr/bin/env python3
from __future__ import annotations

import argparse
import shutil
import subprocess
import sys
import zipfile
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parents[1]
DIST_DIR = PROJECT_ROOT / "dist"
PACKAGE_NAME = "fluentqml"
RC_MODULE = f"{PACKAGE_NAME}/fluentqml_rc.py"
RAW_RESOURCE_SUFFIXES = (".qml", ".qm", ".ts", ".qrc")
RAW_RESOURCE_PARTS = (
    f"{PACKAGE_NAME}/assets/",
    f"{PACKAGE_NAME}/components/",
    f"{PACKAGE_NAME}/themes/",
    f"{PACKAGE_NAME}/windows/",
    f"{PACKAGE_NAME}/utils/",
    f"{PACKAGE_NAME}/languages/",
)


def run(cmd: list[str]) -> None:
    print("+", " ".join(cmd), flush=True)
    subprocess.check_call(cmd, cwd=PROJECT_ROOT)


def clean_dist() -> None:
    if DIST_DIR.exists():
        shutil.rmtree(DIST_DIR)
    DIST_DIR.mkdir()


def build_qrc(force: bool) -> None:
    cmd = [sys.executable, "scripts/build_fluentqml_qrc.py"]
    if force:
        cmd.append("--force")
    run(cmd)


def build_package() -> None:
    if shutil.which("uv"):
        run(["uv", "build"])
        return
    run([sys.executable, "-m", "build"])


def module_cmd(package: str, module: str) -> list[str]:
    if shutil.which("uv"):
        return ["uv", "run", "--with", package, "python", "-m", module]
    return [sys.executable, "-m", module]


def dist_files() -> list[Path]:
    return sorted(
        path
        for path in DIST_DIR.glob("*")
        if path.suffix == ".whl" or path.name.endswith(".tar.gz")
    )


def wheel_files() -> list[Path]:
    return sorted(DIST_DIR.glob("*.whl"))


def assert_dist_exists() -> None:
    files = dist_files()
    if not files:
        msg = "No files found in dist/. Run the build step first."
        raise RuntimeError(msg)


def check_wheel_contents() -> None:
    wheels = wheel_files()
    if not wheels:
        msg = "No wheel found in dist/. PyPI releases should include a wheel."
        raise RuntimeError(msg)

    for wheel in wheels:
        with zipfile.ZipFile(wheel) as archive:
            names = archive.namelist()

        if RC_MODULE not in names:
            msg = f"{wheel.name} does not contain {RC_MODULE}."
            raise RuntimeError(msg)

        raw_resources = [
            name
            for name in names
            if name.startswith(RAW_RESOURCE_PARTS)
            and (name.endswith(RAW_RESOURCE_SUFFIXES) or "/assets/" in name)
        ]
        if raw_resources:
            sample = "\n".join(f"  - {name}" for name in raw_resources[:10])
            msg = (
                f"{wheel.name} contains raw Qt resources that should be packed "
                f"into fluentqml_rc.py:\n{sample}"
            )
            raise RuntimeError(msg)

        print(f"Wheel content OK: {wheel.name}")


def twine_check() -> None:
    assert_dist_exists()
    run([*module_cmd("twine", "twine"), "check", *[path.as_posix() for path in dist_files()]])


def upload(repository: str | None) -> None:
    assert_dist_exists()
    cmd = [*module_cmd("twine", "twine"), "upload"]
    if repository:
        cmd += ["--repository", repository]
    cmd += [path.as_posix() for path in dist_files()]
    run(cmd)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Build and publish FluentQML packages.")
    subparsers = parser.add_subparsers(dest="command", required=True)

    build_parser = subparsers.add_parser("build", help="Build sdist and wheel.")
    build_parser.add_argument(
        "--no-clean",
        action="store_true",
        help="Do not remove dist/ before building.",
    )
    build_parser.add_argument(
        "--force-qrc",
        action="store_true",
        help="Force regeneration of fluentqml_rc.py before building.",
    )

    subparsers.add_parser("check", help="Validate existing dist/ artifacts.")
    subparsers.add_parser("upload-testpypi", help="Upload existing dist/ artifacts to TestPyPI.")
    subparsers.add_parser("upload-pypi", help="Upload existing dist/ artifacts to PyPI.")

    return parser.parse_args()


def main() -> int:
    args = parse_args()

    if args.command == "build":
        if not args.no_clean:
            clean_dist()
        build_qrc(force=args.force_qrc)
        build_package()
        check_wheel_contents()
        twine_check()
        return 0

    if args.command == "check":
        check_wheel_contents()
        twine_check()
        return 0

    if args.command == "upload-testpypi":
        check_wheel_contents()
        twine_check()
        upload("testpypi")
        return 0

    if args.command == "upload-pypi":
        check_wheel_contents()
        twine_check()
        upload(None)
        return 0

    return 1


if __name__ == "__main__":
    raise SystemExit(main())
