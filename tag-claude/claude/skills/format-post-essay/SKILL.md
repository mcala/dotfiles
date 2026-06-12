---
name: format-post-essay
description: >
  Format a non-listicle Instagram post (essay, thread, guide, how-to) into a
  readable two-column PDF via pandoc. Use when the user provides a video or
  carousel that contains long-form prose rather than a list of discrete items.
  Key distinction from extract-carousel-list / extract-video-list: if each
  slide showcases a different item (book, cafe, album) it is a listicle — use
  those skills. If each slide is a "page" of continuous text forming a coherent
  article, essay, or guide, use this skill. Also use when the user asks to
  "turn a post into a PDF" or "format this post as a document."
argument-hint: <path/to/file-or-directory> [-o output.pdf]
allowed-tools: Read, Glob, Write, Bash(pandoc *), Bash(rm *)
---

# Format Post Essay

Convert an Instagram essay/thread/guide post into a two-column PDF.

## Usage

```
/format-post-essay path/to/directory          # carousel of text slides
/format-post-essay path/to/video.mp4          # video with .description essay
/format-post-essay path/to/image.jpg          # single text image
/format-post-essay path/to/file -o output.pdf # custom output name
```

## Process

### 1. Validate Input

Parse `$ARGUMENTS` for input path and optional `-o output.pdf`.
Determine input type:

- **Directory** → carousel of images (follow step 2a)
- **.mp4 file** → video post (follow step 2b)
- **Image file** (.jpg/.png/.webp) → single image (follow step 2c)

### 2a. Extract Content — Carousel

1. Use Glob to find all `.jpg`, `.jpeg`, `.png`, `.webp` files in the
   directory. Sort by filename.
2. Check for `.description` files in the directory — read them for context
   (author name, post caption).
3. Read **every** image in order using Read.
4. Transcribe the text from each slide. Carousel essays typically have:
   - A title slide (large heading, author/date, tagline)
   - Numbered or titled sections (each slide = one section)
   - A closing slide (CTA, follow prompt)
5. Reconstruct the full text, preserving section structure and headings.
   Drop social CTAs (e.g. "follow @account for more").

### 2b. Extract Content — Video

1. Read the `.description` file alongside the video (same stem, e.g.
   `Video by account.description`). This is usually the full essay text.
2. Optionally read the video frames if the description seems incomplete,
   but for essay-style reels the description typically has everything.
3. Strip hashtags and social CTAs from the end.

### 2c. Extract Content — Single Image

1. Read any adjacent `.description` file.
2. Read the image using Read.
3. Transcribe visible text; supplement with description.

### 3. Structure as Markdown

Write a `.md` file in the same directory as the input with this structure:

```markdown
---
title: "Inferred Title"
subtitle: "via @account"
documentclass: article
classoption: twocolumn
geometry: margin=0.6in
header-includes:
  - \setlength{\parskip}{0.4em}
  - \setlength{\parindent}{0pt}
  - \setlength{\columnsep}{0.3in}
---

## Section Heading

Body text...
```

Guidelines for structuring:
- Infer a clear title from the first slide or opening text.
- Use `## Heading` for major sections, `### Heading` for subsections.
- Keep prose flowing — do not bullet-point what was written as paragraphs.
- Use `**bold**` for key statements that were visually emphasized.
- Use `*italics*` for citations or source attributions.
- Include author/date in the frontmatter if visible in the source.
- Escape underscores in the subtitle (e.g. `@\_account\_name`).

### 4. Convert to PDF

If `-o` was not provided, generate a short descriptive snake_case filename
based on the content (not the source file name). Save in the same directory
as the input.

```bash
pandoc "<input>.md" -o "<output>.pdf" --pdf-engine=xelatex
```

### 5. Clean Up

Remove the intermediate markdown file:

```bash
rm "<input>.md"
```

### 6. Report

Tell the user: the output file path, the inferred title, and roughly how
many sections were extracted.
