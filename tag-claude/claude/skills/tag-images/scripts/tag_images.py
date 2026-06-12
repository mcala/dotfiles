#!/usr/bin/env python3
# ABOUTME: Apply macOS Finder tags to image files based on aspect, quality, and extra user-supplied tags.
# ABOUTME: Reads dimensions via Pillow (sips fallback for HEIC), merges with existing tags, writes _kMDItemUserTags xattr.

from __future__ import annotations

import argparse
import plistlib
import subprocess
import sys
from pathlib import Path

XATTR_KEY = "com.apple.metadata:_kMDItemUserTags"
IMAGE_EXTS = {".png", ".jpg", ".jpeg", ".webp", ".heic", ".heif", ".gif", ".tiff", ".tif", ".bmp"}
HIGH_RES_PIXELS = 5_000_000
ULTRAWIDE_RATIO = 2.0


def get_dimensions(path: Path) -> tuple[int, int]:
    try:
        from PIL import Image

        with Image.open(path) as img:
            return img.width, img.height
    except Exception:
        pass

    result = subprocess.run(
        ["sips", "-g", "pixelWidth", "-g", "pixelHeight", str(path)],
        capture_output=True,
        text=True,
        check=True,
    )
    width = height = 0
    for line in result.stdout.splitlines():
        line = line.strip()
        if line.startswith("pixelWidth:"):
            width = int(line.split(":", 1)[1].strip())
        elif line.startswith("pixelHeight:"):
            height = int(line.split(":", 1)[1].strip())
    if not (width and height):
        raise RuntimeError(f"could not read dimensions for {path}")
    return width, height


def derived_tags(width: int, height: int) -> list[str]:
    if height > width:
        aspect = "aspect/phone"
    elif width / height >= ULTRAWIDE_RATIO:
        aspect = "aspect/ultrawide"
    else:
        aspect = "aspect/desktop"

    quality = "quality/high-res" if width * height >= HIGH_RES_PIXELS else "quality/low-res"
    return [aspect, quality]


def read_existing_tags(path: Path) -> list[str]:
    result = subprocess.run(
        ["xattr", "-px", XATTR_KEY, str(path)],
        capture_output=True,
        text=True,
    )
    if result.returncode != 0:
        return []
    hex_data = "".join(result.stdout.split())
    if not hex_data:
        return []
    try:
        plist = plistlib.loads(bytes.fromhex(hex_data))
    except Exception:
        return []
    return [t for t in plist if isinstance(t, str)]


def write_tags(path: Path, tags: list[str]) -> None:
    plist_hex = plistlib.dumps(tags, fmt=plistlib.FMT_BINARY).hex()
    subprocess.run(
        ["xattr", "-wx", XATTR_KEY, plist_hex, str(path)],
        check=True,
    )


def merge_tags(existing: list[str], new: list[str]) -> list[str]:
    seen: set[str] = set()
    merged: list[str] = []
    for tag in [*existing, *new]:
        if tag and tag not in seen:
            seen.add(tag)
            merged.append(tag)
    return merged


def collect_files(inputs: list[str]) -> list[Path]:
    files: list[Path] = []
    for raw in inputs:
        path = Path(raw).expanduser()
        if path.is_dir():
            files.extend(p for p in sorted(path.iterdir()) if p.suffix.lower() in IMAGE_EXTS)
        elif path.is_file():
            files.append(path)
        else:
            matches = sorted(Path().glob(raw))
            if not matches:
                print(f"warning: no match for {raw}", file=sys.stderr)
            files.extend(matches)
    return files


def main() -> int:
    parser = argparse.ArgumentParser(description="Tag image files with macOS Finder tags.")
    parser.add_argument("inputs", nargs="+", help="files, directories, or globs")
    parser.add_argument(
        "--tag",
        action="append",
        default=[],
        help="extra tag to apply (repeatable). May be a comma- or space-separated list.",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="print planned tags without writing",
    )
    args = parser.parse_args()

    extra: list[str] = []
    for chunk in args.tag:
        for piece in chunk.replace(",", " ").split():
            extra.append(piece.strip())

    files = collect_files(args.inputs)
    if not files:
        print("no image files found", file=sys.stderr)
        return 1

    for path in files:
        width, height = get_dimensions(path)
        new_tags = [*derived_tags(width, height), *extra]
        existing = read_existing_tags(path)
        final = merge_tags(existing, new_tags)
        if not args.dry_run:
            write_tags(path, final)
        added = [t for t in final if t not in existing]
        print(f"{path.name}  {width}x{height}  +{added}")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
