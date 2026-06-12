---
name: tag-images
description: Apply macOS Finder tags (xattr `_kMDItemUserTags`) to image files. Auto-derives an `aspect/*` tag (phone/desktop/ultrawide) from image dimensions and a `quality/*` tag (high-res/low-res) from pixel count, then appends any extra tags supplied in the trigger message. Use when the user asks to "tag" image files and provides a path (file, directory, or glob) — e.g. "tag these wallpapers as colorful, abstract", "add tags to ~/Pictures/foo", "tag the iPhone shots with travel". Preserves any existing Finder tags on the file.
---

# Tag Images

## When to invoke

Trigger when the user asks to tag image files and supplies a path. Examples:
- "tag everything in ~/Downloads/wallpapers as nature, calm"
- "add colorful and abstract tags to these"
- "tag this folder of screenshots"

Do **not** invoke for renaming, sorting, or organizing — only tagging.

## How to use

Run the bundled script with the image path(s) and any extra tags from the user's message:

```bash
~/.claude/skills/tag-images/scripts/tag_images.py <paths...> [--tag "tag1, tag2"] [--dry-run]
```

- `<paths...>`: one or more files, directories, or globs. Directories are scanned non-recursively for image extensions.
- `--tag`: repeatable. The value may itself be a comma- or space-separated list, so `--tag "colorful, abstract, dynamic"` works.
- `--dry-run`: print planned tags without writing.

### Parsing extra tags from the user's message

The user will name extra tags inline (e.g. "tag these as colorful, abstract, dynamic"). Extract that list and pass it as a single `--tag` argument. Preserve hierarchical tags as-is (e.g. `quality/high-res`, `aspect/phone`) — slashes are valid tag characters in Finder.

If the user gives no extra tags, that's fine — only the auto-derived aspect/quality tags are applied.

## Auto-derived tags

For every image, the script adds two tags based on its pixel dimensions:

| Rule | Tag |
|---|---|
| `height > width` | `aspect/phone` |
| `width / height >= 2.0` | `aspect/ultrawide` |
| otherwise (incl. square) | `aspect/desktop` |
| `width * height >= 5_000_000` | `quality/high-res` |
| `width * height < 5_000_000` | `quality/low-res` |

Dimensions are read via Pillow when available, with `sips -g pixelWidth -g pixelHeight` as a fallback (needed for HEIC on systems without `pillow-heif`).

## Tag merging

The script reads the file's existing `_kMDItemUserTags` xattr, merges in the new tags (deduped, order-preserved), and writes the result back. Re-running on already-tagged files is safe and idempotent.

## Supported extensions

`.png .jpg .jpeg .webp .heic .heif .gif .tiff .tif .bmp`

Files with other extensions inside a directory input are skipped silently.

## Verifying tags

To inspect what's currently on a file:

```bash
xattr -px com.apple.metadata:_kMDItemUserTags <file> | xxd -r -p | plutil -p -
```
