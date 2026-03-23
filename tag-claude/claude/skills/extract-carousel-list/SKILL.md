---
name: extract-carousel-list
description: Extract a list of items (books, music, movies, etc.) from a directory of Instagram carousel images and output a styled Excel spreadsheet. Use when the user provides a folder of carousel images (JPG, PNG, WEBP) to extract items from. Triggers on phrases like "extract from carousel", "turn these images into a spreadsheet", or when a directory of sequential images is provided.
allowed-tools: Bash(uv run *), Bash(rm *_analysis.json), Read, Glob
---

# Extract Carousel List Skill

Extract a list of items from a directory of Instagram carousel images and
produce a styled Excel spreadsheet.

## Usage

```
/extract-carousel-list path/to/carousel-directory
/extract-carousel-list path/to/carousel-directory -o custom_output.xlsx
```

## Process

Follow these steps exactly:

### 1. Validate Input

Parse `$ARGUMENTS` to get the directory path and optional `-o output.xlsx`.
Verify the directory exists. If `-o` is not provided, default output is
`<directory_name>.xlsx` in the current working directory.

### 2. Find Images

Use the Glob tool to find all image files in the directory:
- Extensions: `.jpg`, `.jpeg`, `.png`, `.webp`
- Sort by filename to preserve carousel order.

If no images are found, report an error and stop.

### 3. Read and Analyze

1. Read **every** image in sorted order using the Read tool. Read them all
   before beginning analysis.
2. Auto-detect whether the first image is a **title card** (thematic header,
   no individual item) or a **content card** (contains a list item). Title
   cards typically have large stylized text describing a theme/category with
   no specific item details.
3. Analyze all content cards together. Determine:

- **List type**: What kind of items are listed? (books, albums, movies,
  TV shows, restaurants, places, products, recipes, etc.)
- **Columns**: What metadata fields are appropriate? Common examples:
  - Books → Title, Author, Description
  - Albums/Music → Album, Artist, Description
  - Movies → Title, Director, Year, Description
  - Places → Name, Location, Description
  - Products → Name, Brand, Price, Description
- **Items**: Extract every distinct item, one per content card. Include
  items in carousel order. If metadata is partially visible or unclear,
  give your best guess and append "(uncertain)".
- **Notes**: Include the theme/title from the title card (if detected)
  and the source account if visible (e.g. "@kelshorrdiary").

### 4. Build Spreadsheet

Write the analysis as a JSON file named `<directory_name>_analysis.json`
in the carousel directory with this structure:

```json
{
  "list_type": "books",
  "columns": ["Title", "Author", "Description"],
  "items": [
    {"Title": "Dead Silence", "Author": "S.A. Barnes", "Description": "..."}
  ],
  "notes": "Space Horror Books - via @kelshorrdiary",
  "source_directory": "2026-03-22",
  "image_count": 9
}
```

Then run the spreadsheet builder:

```bash
uv run .claude/skills/extract-carousel-list/build_spreadsheet.py <directory_name>_analysis.json -o <output.xlsx>
```

### 5. Clean Up

Remove the temporary analysis file:

```bash
rm <directory_name>_analysis.json
```

### 6. Report

Tell the user: the output file path, the list type detected, how many
items were extracted, and whether a title card was detected.
