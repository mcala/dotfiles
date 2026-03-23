---
name: extract-list
description: Extract a list of items from a news article listicle or Reddit recommendation post and output a styled Excel spreadsheet. Use when the user provides a URL to an article listicle (e.g. "10 best places to eat") or a Reddit post with recommendations (books, music, places, etc.).
argument-hint: <url> [-o output.xlsx]
allowed-tools: Bash(uv run *), Bash(rm *_content.txt), Bash(rm *_analysis.json), Read, WebFetch
---

# Extract List from Article/Reddit Skill

Extract a list of recommended items from a news article listicle or Reddit
recommendation post and produce a styled Excel spreadsheet.

## Usage

```
/extract-list https://www.reddit.com/r/newjersey/comments/.../best_pizza_in_nj/
/extract-list https://example.com/10-best-restaurants-in-hoboken -o restaurants.xlsx
```

## Process

Follow these steps exactly:

### 1. Validate Input

Parse `$ARGUMENTS` to get the URL and optional `-o output.xlsx`. If `-o` is not
provided, the output filename will be auto-derived from the page title.

### 2. Fetch the Page Content

Run the fetch script:

```bash
uv run .claude/skills/listicle-reddit-extractor/fetch_page.py "<url>"
```

This creates a `<slug>_content.txt` file with the extracted text.

If the fetch script fails (e.g. 403/blocking), fall back to using the WebFetch
tool directly on the URL, then save the text output manually.

### 3. Read and Analyze

Read the content file using the Read tool. Analyze the text to determine:

- **Source type**: Is this a Reddit post or a news/blog article?
- **List type**: What kind of items are being recommended? (restaurants, books,
  albums, movies, places, products, etc.)
- **Columns**: What metadata fields are appropriate? Common examples:
  - Restaurants/Food → Name, Cuisine/Type, Location, Notes
  - Books → Title, Author, Notes
  - Albums/Music → Title, Artist, Notes
  - Movies/TV → Title, Director/Creator, Year, Notes
  - Places/Travel → Name, Location, Notes
  - Products → Name, Brand, Price, Notes
- **Items**: Extract every distinct recommendation. For Reddit posts, focus on
  items mentioned in the **post body and top-level comments** (and highly-upvoted
  replies). De-duplicate items that appear multiple times. If an item is
  mentioned by multiple commenters, note that in a "Mentions" or "Notes" column.
  Include items in rough order of popularity/prominence.

Key extraction rules:
- For **articles**: Extract each numbered/listed item with its metadata.
- For **Reddit**: Extract recommendations from comments. Prioritize items from
  higher-scored comments. Combine duplicate mentions. Capture any context the
  commenter provides (e.g. "their margherita is incredible" → Notes).
- If metadata is unclear, give your best guess and append "(uncertain)".
- Aim for completeness — extract ALL items mentioned, not just the top few.

### 4. Build Spreadsheet

Write the analysis as a JSON file named `<slug>_analysis.json` with this
structure:

```json
{
  "list_type": "restaurants",
  "columns": ["Name", "Cuisine", "Location", "Notes"],
  "items": [
    {"Name": "DeLorenzo's", "Cuisine": "Pizza", "Location": "Robbinsville, NJ", "Notes": "Multiple commenters recommend; tomato pie style"},
    {"Name": "Razza", "Cuisine": "Pizza", "Location": "Jersey City, NJ", "Notes": "Wood-fired, highly rated"}
  ],
  "notes": "Best pizza in NJ - extracted from Reddit r/newjersey thread",
  "source_url": "https://www.reddit.com/r/...",
  "source_type": "reddit"
}
```

Then run the spreadsheet builder:

```bash
uv run .claude/skills/listicle-reddit-extractor/build_spreadsheet.py <slug>_analysis.json -o <output.xlsx>
```

### 5. Clean Up

Remove the temporary files:

```bash
rm <slug>_content.txt
rm <slug>_analysis.json
```

### 6. Report

Tell the user: the output file path, the source type (Reddit/article), the list
type detected, and how many items were extracted.
