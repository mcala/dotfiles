---
name: tufte-research-paper
description: "Convert one or more Markdown files to a Tufte-style research-paper PDF — Edward Tufte's classic layout with a wide right margin, sidenotes in place of footnotes, margin notes, and margin/full-width figures. Built on pandoc + xelatex + the tufte-handout LaTeX class. Use when Andrew wants the Tufte look specifically, or says 'sidenotes', 'margin notes', 'Tufte', 'tufte-handout', 'tufte style', or 'margin notes instead of footnotes' for a PDF from .md sources. This is the Tufte-styled sibling of the `research-paper` skill; for a plain single-column journal/article layout use `research-paper` instead, and if pandoc or xelatex are missing/broken fall back to `md2pdf`. Ships a wrapper (scripts/md2tufte.sh) that concatenates multiple .md inputs and a LaTeX header fragment (assets/header.tex) that routes footnotes to the margin and handles code wrapping, graphics, and tables. YAML frontmatter on the FIRST input drives title, author, abstract, bibliography, and CSL; subsequent inputs have their frontmatter stripped and are prefixed with a page break."
---

# Markdown → Tufte Research Paper PDF

## Overview

Renders Markdown as a research-paper PDF in Edward Tufte's
classic style — narrow main column, wide right margin, and
**sidenotes instead of footnotes** — using pandoc + xelatex
on top of the `tufte-handout` document class. Like its
sibling `research-paper`, this skill is a thin, opinionated
wrapper:

- `scripts/md2tufte.sh` runs pandoc with the right flags.
- `assets/header.tex` is included as `--include-in-header`.
  Its key job is `\let\footnote\sidenote`, which pushes every
  pandoc footnote into the margin; it also patches code
  overflow and loads graphics/table packages.
- Metadata (title, author, abstract, bibliography, CSL,
  fonts) comes from YAML frontmatter, not script flags.
- An AI disclaimer is forced onto the first page of every
  build (rendered as a margin note off the title), and the
  byline falls back to a default when frontmatter omits one.
  See "Author and disclaimer".

Output layout: the `tufte-handout` class owns the page
geometry — do **not** pass a `geometry` margin (it clashes).
The body font defaults to TeX Gyre Pagella (free Palatino,
the canonical stand-in for Tufte's Bembo); override it from
frontmatter if you want.

This is the same authoring surface as `research-paper` — the
same Markdown, the same multi-file concatenation, the same
disclaimer/author handling — with the layout swapped for
Tufte's. The two skills are interchangeable at the source
level; only the rendered geometry and notes differ.

## Inputs

Ask Andrew for these if not obvious from the request:

1. **Input `.md` file(s)** — one or more sources, in final
   order. YAML frontmatter on the **first** file drives
   document metadata (title, author, abstract, bibliography,
   CSL). Frontmatter on later files is stripped and ignored.
2. **Output path** (optional, `-o <path>`) — defaults to
   `<first-input>.pdf` next to the source.
3. Whether there's a `.bib` in play and which CSL. A
   note-style CSL (e.g. `chicago-note-bibliography.csl`) is
   worth recommending here: it turns citations into footnotes
   which this skill then routes into the margin — the Tufte
   ideal. This skill bundles no CSL; grab one from
   <https://github.com/citation-style-language/styles>.

## Quickstart

Single file:

```bash
/path/to/tufte-research-paper/scripts/md2tufte.sh paper.md
```

Writes `paper.pdf` next to the source.

Multiple files (e.g. the research procedure's REPORT): each
input after the first is prefixed with a `\newpage`.

```bash
/path/to/tufte-research-paper/scripts/md2tufte.sh \
    README.md NOTES.md QUESTION.md \
    -o REPORT_myproject.pdf
```

The first file must carry a YAML frontmatter block with at
least `title`; later files should not, and any they do have
is stripped before concatenation.

## YAML frontmatter conventions

```yaml
---
title: "On the Aesthetics of Margin Notes"
# Byline: the authoring model fills in its own name as MODEL.
author: "Claude (Opus 4.8) under direction of Andrew McAllister"
date: 2026-06-05
abstract: |
  A short abstract. Multiple paragraphs work — use the literal-block
  scalar (`|`) so newlines are preserved.
bibliography: refs.bib    # relative to the .md file
csl: chicago-note-bibliography.csl  # relative; optional, see citations
mainfont: "TeX Gyre Pagella"   # optional; this is also the built-in default
monofont: "JetBrains Mono"     # optional
---
```

`--citeproc` is already passed by the wrapper, so
`bibliography:` and `csl:` just work. Omit them if there are
no citations. Don't set `thanks:` — it is reserved for the
auto-added AI disclaimer. Don't set `geometry:` — the tufte
class controls the layout and a geometry option clashes.

**Font default.** If you omit `mainfont`, the wrapper injects
`TeX Gyre Pagella` so the document gets the classic Palatino
Tufte look (the class's own default is plain Latin Modern).
Set `mainfont` yourself to override — frontmatter wins,
because the wrapper only injects the default when it sees no
`mainfont:` in the first file. On macOS `mainfont: "Palatino"`
also works.

## Author and disclaimer

**Author.** The byline comes from the first file's `author`
frontmatter. Use the form `Claude (MODEL) under direction of
Andrew McAllister`, where the authoring model fills in its
own name (e.g. `Opus 4.8`). If `author` is omitted entirely,
the wrapper falls back to `Claude under direction of Andrew
McAllister`.

**Disclaimer.** Every build gets a first-page margin note
reminding readers that AI output can be wrong:

> This report was generated by an AI system (Claude) under
> human direction. AI can make mistakes and may fabricate
> facts, figures, or citations, so verify independently
> before relying on it.

It is wired in as the title's `\thanks` note and forced via
`-M thanks=...`, so it always appears and overrides any
`thanks` in the source. The string is deliberately pure
ASCII (it's passed on the command line, where a non-UTF-8
locale would mangle an em dash). Edit the `DISCLAIMER` string
in `scripts/md2tufte.sh` to change the wording.

## Sidenotes and the float caveat

Write a footnote in normal pandoc-markdown and it lands in
the margin as a numbered sidenote:

```markdown
The result holds in general.^[A numbered sidenote explaining the edge cases.]
```

This works because `assets/header.tex` does
`\let\footnote\sidenote`. The mechanism is simple and
catches every footnote, including note-style citations.

**Caveat — no notes inside floats.** `\sidenote` is built on
`\marginpar`, which LaTeX forbids inside floats and some
boxes. A footnote placed **inside a table cell or a figure
caption will break the build.** Keep notes in body text. If
you genuinely need to annotate a table, put the note in the
sentence that introduces it, or use a `\marginnote` placed in
the surrounding paragraph.

## Tufte-specific features

These come from the `tufte-handout` class. Drop the raw LaTeX
straight into the Markdown where you want it.

- **Small-caps lead-in** — start a paragraph with a Tufte
  `\newthought`:

  ```latex
  \newthought{In the beginning} the layout was symmetric...
  ```

- **Unnumbered margin note** (no reference mark):

  ```latex
  some text\marginnote{An aside with no number.}
  ```

- **Numbered sidenote** in raw LaTeX (equivalent to a
  markdown footnote): `\sidenote{...}`.

- **Margin figure** — an image sized to the margin column:

  ```latex
  \begin{marginfigure}
  \includegraphics[width=\linewidth]{plots/small.png}
  \caption{A figure that lives in the margin.}
  \end{marginfigure}
  ```

- **Full-width figure** — spans main column + margin:

  ```latex
  \begin{figure*}
  \centering
  \includegraphics[width=\linewidth]{plots/big-heatmap.png}
  \caption{A full-width figure.}
  \end{figure*}
  ```

- **Full-width text/table block** — escape the narrow column
  for wide tables or paragraphs:

  ```latex
  \begin{fullwidth}
  ... wide tabular or prose ...
  \end{fullwidth}
  ```

## Figures

Plain markdown image syntax renders as a standard in-column
`figure`:

```markdown
![A caption.](plots/convergence.png){#fig:conv width=100%}
```

For margin or full-width placement use the `marginfigure` /
`figure*` raw blocks above. The narrow main column is the
Tufte default, so wide images usually want `figure*` or
`fullwidth`.

## Tables

Pipe tables render via pandoc's `longtable` + `booktabs`
rules. **`longtable` does not play well with the Tufte margin
layout** — a wide table will run under the margin. For
anything wider than the narrow column, wrap a hand-written
`tabular` in a `fullwidth` block:

```latex
\begin{fullwidth}
\begin{tabular}{@{}lrrr@{}}
\toprule
Region & FY25 & FY26 & FY27 \\
\midrule
North & 100 & 120 & 132 \\
\bottomrule
\end{tabular}
\end{fullwidth}
```

Use the same raw-LaTeX approach for multi-row headers, spans,
or multi-paragraph cells.

## Bibliography and citations

Write citations in pandoc-markdown style:

```markdown
Earlier work established the basic result [@doe2019; @smith2020, pp. 3-5].
```

Keys match entries in the `.bib` referenced from frontmatter.
`--citeproc` appends the reference list automatically; it has
no heading unless you add `reference-section-title:
"References"` to the frontmatter.

**Tufte tip.** With a normal author-date or numeric CSL,
citations stay inline and the reference list sits at the end
(verified working). With a **note-style CSL**
(`chicago-note-bibliography.csl`), citeproc emits each
citation as a footnote — which `\let\footnote\sidenote` then
drops into the margin, giving the marginal-citation style
Tufte favors, with the full bibliography still collected at
the end.

## Code blocks

Handled by pandoc's skylighting highlighter
(`--highlight-style=tango`). `assets/header.tex` redefines
the `Highlighting` environment via `fvextra` to wrap long
lines at `\footnotesize` — important here, because the Tufte
main column is narrow. To change theme, edit the
`--highlight-style` flag in `scripts/md2tufte.sh`
(`pandoc --list-highlight-styles` shows options).

## Customization

**`scripts/md2tufte.sh`** — edit flags to change:

- `-V classoption=justified` — full justification instead of
  Tufte's default ragged-right. Other class options:
  `symmetric`, `twoside`, `nobib`, `nofonts`.
- `-V colorlinks=true` — already on; drop it for plain black
  print-style links.
- `--highlight-style=...` — code theme.
- `DISCLAIMER` — the first-page disclaimer text (keep ASCII).
- Add `--number-sections` for numbered headings.
- The `mainfont` default (`TeX Gyre Pagella`).

**`assets/header.tex`** — edit the preamble to change code
wrapping, the footnote→sidenote aliasing, or to add
`\usepackage{}` lines. Do **not** add `\setmainfont` here —
this file is included at the end of the preamble and would
clobber a user's frontmatter `mainfont`; font defaults belong
in the wrapper's detect-then-inject logic instead.

Leave both files alone for the default case.

## Files in this skill

```text
tufte-research-paper/
├── SKILL.md              # this file
├── scripts/
│   └── md2tufte.sh       # the wrapper; run this
└── assets/
    └── header.tex        # LaTeX preamble added via --include-in-header
```

## Dependencies

- `pandoc` (3.x). Note: this wrapper uses the modern
  `--highlight-style` flag (not the older
  `--syntax-highlighting`).
- TeX Live with `xelatex`, the `tufte-latex` classes
  (`tufte-handout.cls`), and the packages loaded by
  `assets/header.tex`: `fvextra`, `graphicx`, `tabularx`,
  `booktabs`, plus `longtable` (used by pandoc tables). On
  MacPorts these are all in `texlive-latex-extra`; the
  `tufte-latex` classes ship there too.
- `TeX Gyre Pagella` (the default body font) ships with every
  TeX Live install.
- A `.csl` file if citations are used.
