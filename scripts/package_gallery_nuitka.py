#!/usr/bin/env python3
import argparse
import platform
import plistlib
import shutil
import subprocess
import sys
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parents[1]
GALLERY_NAME = "FluentQMLGallery"
ENTRY_FILE = PROJECT_ROOT / "examples" / "gallery.py"
VERSION_FILE = PROJECT_ROOT / "fluentqml" / "__init__.py"


def current_target() -> str:
    system = platform.system()
    if system == "Windows":
        return "windows"
    if system == "Darwin":
        return "macos"
    msg = f"Unsupported platform for Gallery packaging: {system}"
    raise SystemExit(msg)


def current_arch() -> str:
    machine = platform.machine().lower()
    if machine in {"arm64", "aarch64"}:
        return "arm64"
    if machine in {"x86_64", "amd64"}:
        return "x64"
    msg = f"Unsupported architecture for Gallery packaging: {machine}"
    raise SystemExit(msg)


def default_icon(target: str) -> str:
    if target == "macos":
        return "examples/assets/gallery.icns"
    if target == "windows":
        return "examples/assets/gallery.ico"
    msg = f"Unsupported target: {target}"
    raise SystemExit(msg)


def run(cmd: list[str]) -> None:
    print("+", " ".join(cmd), flush=True)
    subprocess.check_call(cmd, cwd=PROJECT_ROOT)


def project_version() -> str:
    namespace: dict[str, object] = {}
    for line in VERSION_FILE.read_text(encoding="utf-8").splitlines():
        if line.startswith("__version__"):
            exec(line, namespace)
            version = namespace.get("__version__")
            if isinstance(version, str):
                return version
    msg = f"Cannot find __version__ in {VERSION_FILE}"
    raise SystemExit(msg)


def clean_path(path: Path) -> None:
    if path.is_dir():
        shutil.rmtree(path)
    elif path.exists():
        path.unlink()


def build_resources() -> None:
    run([sys.executable, "scripts/build_fluentqml_qrc.py"])
    run([sys.executable, "examples/scripts/build_gallery_qrc.py"])


def nuitka_output_paths(output_dir: Path, target: str, name: str) -> tuple[Path, Path]:
    if target == "macos":
        return output_dir / "gallery.app", output_dir / f"{name}.app"
    return output_dir / "gallery.dist", output_dir / name


def rename_output(output_dir: Path, target: str, name: str) -> Path:
    source, target_path = nuitka_output_paths(output_dir, target, name)
    if target_path.exists():
        return target_path
    if not source.exists():
        msg = f"Nuitka output not found: {source}"
        raise SystemExit(msg)
    if source == target_path:
        return target_path
    clean_path(target_path)
    source.rename(target_path)
    return target_path


def archive_windows(source: Path, archive_path: Path) -> None:
    clean_path(archive_path)
    base_name = archive_path.with_suffix("")
    archive = shutil.make_archive(
        str(base_name), "zip", root_dir=source.parent, base_dir=source.name
    )
    if Path(archive) != archive_path:
        Path(archive).rename(archive_path)


def archive_macos(source: Path, archive_path: Path) -> None:
    clean_path(archive_path)
    run(
        [
            "ditto",
            "-c",
            "-k",
            "--sequesterRsrc",
            "--keepParent",
            source.as_posix(),
            archive_path.as_posix(),
        ]
    )


def update_macos_bundle_info(app_dir: Path, name: str, bundle_identifier: str) -> None:
    info_plist = app_dir / "Contents" / "Info.plist"
    if not info_plist.exists():
        msg = f"macOS Info.plist not found: {info_plist}"
        raise SystemExit(msg)

    with info_plist.open("rb") as file:
        info = plistlib.load(file)
    info["CFBundleName"] = name
    info["CFBundleDisplayName"] = name
    info["CFBundleIdentifier"] = bundle_identifier
    with info_plist.open("wb") as file:
        plistlib.dump(info, file, fmt=plistlib.FMT_XML)


def create_archive(
    source: Path, output_dir: Path, name: str, target: str, arch: str
) -> Path:
    platform_name = "Windows" if target == "windows" else "macOS"
    if target == "windows":
        archive_name = f"{name}-{platform_name}-{arch}-nuitka-portable.zip"
    else:
        archive_name = f"{name}-{platform_name}-{arch}-nuitka.zip"
    archive_path = output_dir / archive_name
    if target == "windows":
        archive_windows(source, archive_path)
    else:
        archive_macos(source, archive_path)
    return archive_path


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Package the FluentQML Gallery app with Nuitka."
    )
    parser.add_argument(
        "--name", default=GALLERY_NAME, help=f"App name. Defaults to {GALLERY_NAME}."
    )
    parser.add_argument(
        "--target",
        choices=["auto", "windows", "macos"],
        default="auto",
        help="Target platform. Defaults to the current platform.",
    )
    parser.add_argument(
        "--arch",
        choices=["auto", "x64", "arm64"],
        default="auto",
        help="Target architecture label. Defaults to the current architecture.",
    )
    parser.add_argument("--icon", help="Application icon path.")
    parser.add_argument("--output-dir", default="dist", help="Nuitka output directory.")
    parser.add_argument(
        "--archive", action="store_true", help="Create a release zip after build."
    )
    parser.add_argument(
        "--clean",
        action="store_true",
        help="Remove previous Nuitka Gallery output first.",
    )
    parser.add_argument(
        "--macos-bundle-identifier",
        default="cc.cheukfung.fluentqml.gallery",
        help="macOS bundle identifier.",
    )
    parser.add_argument(
        "--console", action="store_true", help="Keep the console window visible."
    )
    return parser.parse_args()


def build_cmd(
    args: argparse.Namespace, target: str, icon: str, output_dir: Path
) -> list[str]:
    version = project_version()
    cmd = [
        sys.executable,
        "-m",
        "nuitka",
        "--standalone",
        "--plugin-enable=pyside6",
        "--assume-yes-for-downloads",
        "--include-qt-plugins=platforms,platforminputcontexts,imageformats,styles,qml,qmltooling,iconengines,networkinformation",
        f"--output-dir={output_dir}",
        f"--product-version={version}",
        f"--file-version={version}",
        "--follow-import-to=fluentqml",
        "--include-module=gallery_rc",
        "--include-module=config",
    ]
    if target == "windows":
        console_mode = "force" if args.console else "disable"
        cmd.extend(
            [
                f"--windows-console-mode={console_mode}",
                f"--windows-icon-from-ico={icon}",
                f"--windows-product-name={args.name}",
            ]
        )
    else:
        cmd.extend(
            [
                "--macos-create-app-bundle",
                f"--macos-app-icon={icon}",
                f"--macos-app-name={args.name}",
                f"--macos-app-mode={'console' if args.console else 'gui'}",
            ]
        )
    cmd.append(str(ENTRY_FILE))
    return cmd


def main() -> int:
    args = parse_args()
    target = current_target() if args.target == "auto" else args.target
    arch = current_arch() if args.arch == "auto" else args.arch
    icon = args.icon or default_icon(target)
    output_dir = (PROJECT_ROOT / args.output_dir).resolve()

    output_dir.mkdir(parents=True, exist_ok=True)
    if args.clean:
        for path in (
            output_dir / "gallery.build",
            output_dir / "gallery.dist",
            output_dir / "gallery.app",
            output_dir / args.name,
            output_dir / f"{args.name}.app",
        ):
            clean_path(path)

    build_resources()
    run(build_cmd(args, target, icon, output_dir))
    output = rename_output(output_dir, target, args.name)
    if target == "macos":
        update_macos_bundle_info(output, args.name, args.macos_bundle_identifier)

    if args.archive:
        archive_path = create_archive(output, output_dir, args.name, target, arch)
        print(f"Archive created: {archive_path}")
    else:
        print(f"Build output: {output}")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
