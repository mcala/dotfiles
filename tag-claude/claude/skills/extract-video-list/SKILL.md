---
name: extract-video-list
description: Extract a list of items (books, music, movies, etc.) from a short-form video (.mp4) or still image (.jpg, .png, .webp) and output a styled Excel spreadsheet. Use when the user provides a video or image containing a list to extract items from.
argument-hint: <input.mp4|.jpg|.png|.webp> [-o output.xlsx]
allowed-tools: Bash(uv run *), Bash(rm -rf *_frames), Bash(rm *_transcript.txt), Bash(rm *_analysis.json), Read
---

# Extract Video List Skill

Extract a list of items from a short-form listicle video (Instagram reel,
YouTube short, TikTok) or still image and produce a styled Excel spreadsheet.

## Usage

```
/extract-video-list path/to/video.mp4
/extract-video-list path/to/image.jpg -o custom_output.xlsx
```

## Process

Follow these steps exactly:

### 1. Validate Input

Parse `$ARGUMENTS` to get the input file path and optional `-o output.xlsx`.
Verify the file exists. If `-o` is not provided, the output filename will be
determined after analysis (see step 4).

Determine the input type by file extension:
- **Video** (.mp4) → Follow steps 2a, 3a
- **Image** (.jpg, .jpeg, .png, .webp) → Follow steps 2b, 3b

### 2a. Extract Frames and Transcribe Audio (video only)

Run the preparation script:

```bash
uv run .claude/skills/extract-video-list/prepare_video.py <input.mp4>
```

This creates:
- `<stem>_frames/` directory with JPEG frames from the video
- `<stem>_transcript.txt` with the audio transcription

### 2b. Read Image (image only)

Skip frame extraction and transcription. Read the image directly using the
Read tool in the next step.

### 3a. Read and Analyze (video)

1. Check for a `.description` file alongside the video (e.g., `<stem>.description`).
   If it exists, read it — this is the post caption and often contains the
   complete list of items, especially when the video itself is just an intro.
2. Read the transcript file using the Read tool.
3. Read each frame image in the `<stem>_frames/` directory using the Read tool
   (they are numbered sequentially — read them in order).
4. Analyze all sources together (caption, frames, and transcript). Prefer the
   caption as the primary source for item names and metadata when available,
   using frames and transcript to supplement. Determine the fields described
   in "Analysis Fields" below.

### 3b. Read and Analyze (image)

1. Check for a `.description` file alongside the image (e.g., `<stem>.description`).
   If it exists, read it — this is the post caption and may contain additional
   item details.
2. Read the image file directly using the Read tool.
3. Analyze all sources together (caption and image). Determine the fields
   described in "Analysis Fields" below.

### Analysis Fields

For both video and image inputs, determine:
- **List type**: What kind of items are listed? (books, albums, movies,
  TV shows, restaurants, places, products, recipes, etc.)
- **Columns**: What metadata fields are appropriate? Common examples:
  - Books → Title, Author
  - Albums/Music → Album, Artist
  - Movies → Title, Director, Year
  - Places → Name, Location
  - Products → Name, Brand, Price
- **Items**: Extract every distinct item shown or mentioned. Include items
  in the order they appear. If metadata is partially visible or unclear,
  give your best guess and append "(uncertain)".

### 4. Build Spreadsheet

Choose the output filename. If `-o` was provided, use that. Otherwise, generate
a short, descriptive snake_case filename based on the list content (not the
source video/image name). Examples:
- A list of Irish music recommendations → `irish_music_recs.xlsx`
- 10 NYC stationery stores → `nyc_stationery_stores.xlsx`
- Atheist philosophy books → `atheist_philosophy_books.xlsx`

The file is saved in the same directory as the input file.

Write the analysis as a JSON file named `<stem>_analysis.json` with this
structure:

```json
{
  "list_type": "books",
  "columns": ["Title", "Author"],
  "items": [
    {"Title": "Atomic Habits", "Author": "James Clear"},
    {"Title": "Deep Work", "Author": "Cal Newport"}
  ],
  "notes": "Top 10 productivity books from Instagram reel",
  "source": "original_filename.mp4"
}
```

Then run the spreadsheet builder:

```bash
uv run .claude/skills/extract-video-list/build_spreadsheet.py <stem>_analysis.json -o <output.xlsx>
```

### 5. Clean Up

Remove the temporary files:

For video inputs:
```bash
rm -rf <stem>_frames
rm <stem>_transcript.txt
rm <stem>_analysis.json
```

For image inputs:
```bash
rm <stem>_analysis.json
```

### 6. Report

Tell the user: the output file path, the list type detected, and how many
items were extracted.
