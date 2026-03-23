# /// script
# requires-python = ">=3.13"
# dependencies = [
#   "requests",
#   "beautifulsoup4",
# ]
# ///
"""
Fetch a URL and extract clean text content.

For Reddit URLs: uses the .json API to extract the post and top-level comments.
For other URLs: uses BeautifulSoup to extract article text.

Output is written to <stem>_content.txt in the current directory.
"""

from __future__ import annotations

import argparse
import json
import re
import sys
import textwrap
from html import unescape
from pathlib import Path
from urllib.parse import urlparse

import requests
from bs4 import BeautifulSoup

USER_AGENT = "Mozilla/5.0 (compatible; ListExtractor/1.0)"
REDDIT_HOSTS = {"reddit.com", "www.reddit.com", "old.reddit.com", "new.reddit.com"}
MAX_COMMENTS = 200


def slugify(text: str) -> str:
    """Create a short filesystem-safe slug from text."""
    slug = re.sub(r"[^a-z0-9]+", "_", text.lower().strip())
    slug = slug.strip("_")[:60]
    return slug or "page"


def is_reddit_url(url: str) -> bool:
    host = urlparse(url).hostname or ""
    return any(host == h or host.endswith("." + h) for h in REDDIT_HOSTS)


def fetch_reddit(url: str) -> tuple[str, str]:
    """Fetch a Reddit post + comments via JSON API. Returns (slug, content)."""
    # Normalize URL and append .json
    clean = re.sub(r"\.json$", "", url.rstrip("/"))
    json_url = clean + ".json"

    resp = requests.get(json_url, headers={"User-Agent": USER_AGENT}, timeout=30)
    resp.raise_for_status()
    data = resp.json()

    # data is a list: [post_listing, comments_listing]
    post_data = data[0]["data"]["children"][0]["data"]
    title = unescape(post_data.get("title", "Untitled"))
    selftext = unescape(post_data.get("selftext", ""))
    subreddit = post_data.get("subreddit", "")

    lines: list[str] = []
    lines.append(f"TITLE: {title}")
    lines.append(f"SUBREDDIT: r/{subreddit}")
    lines.append(f"URL: {url}")
    lines.append("")
    if selftext:
        lines.append("POST BODY:")
        lines.append(selftext)
        lines.append("")

    lines.append("=" * 60)
    lines.append("COMMENTS (sorted by best):")
    lines.append("=" * 60)

    comment_count = 0

    def extract_comments(children: list[dict], depth: int = 0) -> None:
        nonlocal comment_count
        for child in children:
            if child.get("kind") != "t1":
                continue
            if comment_count >= MAX_COMMENTS:
                return
            cdata = child["data"]
            author = cdata.get("author", "[deleted]")
            body = unescape(cdata.get("body", ""))
            score = cdata.get("score", 0)
            indent = "  " * depth

            comment_count += 1
            lines.append("")
            lines.append(f"{indent}--- COMMENT by u/{author} (score: {score}) ---")
            for line in body.split("\n"):
                lines.append(f"{indent}{line}")

            # Recurse into replies
            replies = cdata.get("replies")
            if isinstance(replies, dict):
                reply_children = replies.get("data", {}).get("children", [])
                extract_comments(reply_children, depth + 1)

    if len(data) > 1:
        top_comments = data[1]["data"]["children"]
        extract_comments(top_comments)

    slug = slugify(title)
    return slug, "\n".join(lines)


def fetch_article(url: str) -> tuple[str, str]:
    """Fetch a generic article page and extract text. Returns (slug, content)."""
    resp = requests.get(url, headers={"User-Agent": USER_AGENT}, timeout=30)
    resp.raise_for_status()

    soup = BeautifulSoup(resp.text, "html.parser")

    # Remove script, style, nav, footer, aside
    for tag in soup.find_all(["script", "style", "nav", "footer", "aside", "header"]):
        tag.decompose()

    title_tag = soup.find("title")
    title = title_tag.get_text(strip=True) if title_tag else "Untitled"

    # Try to find the main article body
    article = soup.find("article") or soup.find("main") or soup.find("body")

    lines: list[str] = []
    lines.append(f"TITLE: {title}")
    lines.append(f"URL: {url}")
    lines.append("")

    if article:
        # Extract headings and paragraphs preserving structure
        for elem in article.find_all(["h1", "h2", "h3", "h4", "h5", "h6", "p", "li", "blockquote"]):
            text = elem.get_text(separator=" ", strip=True)
            if not text:
                continue
            tag_name = elem.name
            if tag_name.startswith("h"):
                lines.append("")
                lines.append(f"## {text}")
                lines.append("")
            elif tag_name == "li":
                lines.append(f"  - {text}")
            elif tag_name == "blockquote":
                lines.append(f"  > {text}")
            else:
                lines.append(text)

    slug = slugify(title)
    return slug, "\n".join(lines)


def main() -> None:
    parser = argparse.ArgumentParser(description="Fetch URL and extract text content")
    parser.add_argument("url", help="URL to fetch (article or Reddit post)")
    parser.add_argument("-o", "--output", help="Output text file path (auto-generated if omitted)")
    args = parser.parse_args()

    url = args.url.strip()

    try:
        if is_reddit_url(url):
            slug, content = fetch_reddit(url)
        else:
            slug, content = fetch_article(url)
    except requests.RequestException as e:
        print(f"Error fetching URL: {e}", file=sys.stderr)
        sys.exit(1)

    if args.output:
        output_path = Path(args.output).resolve()
    else:
        output_path = Path.cwd().joinpath(f"{slug}_content.txt")

    output_path.write_text(content, encoding="utf-8")
    print(f"Wrote {output_path} ({len(content)} chars)")


if __name__ == "__main__":
    main()
