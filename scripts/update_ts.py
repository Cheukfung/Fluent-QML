#!/usr/bin/env python3
import argparse
import subprocess
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parents[1]

TARGETS = {
    "library": {
        "source": "fluentqml/",
        "languages": "fluentqml/languages",
    },
    "gallery": {
        "source": "examples/",
        "languages": "examples/languages",
    },
}


def run(cmd: list[str]) -> None:
    print("+", " ".join(cmd), flush=True)
    subprocess.check_call(cmd, cwd=PROJECT_ROOT)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Update FluentQML translation files.")
    parser.add_argument(
        "target",
        choices=TARGETS,
        help="Translation target to update.",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    target = TARGETS[args.target]
    languages_dir = target["languages"]

    for locale in ("en_US", "zh_CN"):
        ts_file = f"{languages_dir}/{locale}.ts"
        run(["pyside6-lupdate", target["source"], "-ts", ts_file])

    for locale in ("en_US", "zh_CN"):
        ts_file = f"{languages_dir}/{locale}.ts"
        run(["pyside6-lrelease", ts_file])

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
