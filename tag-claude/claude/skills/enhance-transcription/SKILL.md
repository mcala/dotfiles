---
name: enhance-transcription
description: "Enhance and correct speaker identification in legislative hearing transcripts. Use this skill when the user provides a transcript file (text, markdown, or JSON from AssemblyAI) of a legislative hearing along with Excel speaker lists, and wants to improve the accuracy of speaker labels. The transcript will have auto-generated speaker labels (e.g., 'Speaker A', 'Speaker B') that need to be matched to real names using context clues, speaker order lists, and self-identifications. The skill produces a corrected transcript with real names and an uncertainty log as an Excel file. Trigger whenever the user mentions hearing transcripts, speaker identification, transcript correction, speaker labeling, diarization cleanup, or wants to match anonymous speaker labels to known participants. Also trigger when the user has AssemblyAI output or similar auto-transcription with speaker diarization that needs human-readable names."
---

# Enhance Legislative Hearing Transcription

## Overview

This skill corrects auto-generated speaker labels in legislative hearing transcripts
by cross-referencing speaker order lists, committee member rosters, and textual
context clues. It uses a two-pass approach:

- **Pass 1 (Mapping scan)**: Quick scan of all chunks to build a speaker identity map
  using high-confidence signals only (self-identifications, chair introductions)
- **Pass 2 (Full correction)**: Process each chunk using the map from Pass 1, filling
  in remaining identifications and writing corrected output

It produces two output files:

1. **Corrected transcript** (`.txt`) — full transcript with real speaker names
2. **Uncertainty log** (`.xlsx`) — LOW and UNIDENTIFIED entries for human review

## Prerequisites

This skill includes two Python scripts (in `scripts/`):
- `preprocess_transcript.py` — Parses inputs, extracts low-confidence segments,
  chunks the transcript, and writes a manifest for the LLM
- `assemble_transcript.py` — Combines corrected chunks into the final transcript
  and uncertainty Excel file, handling overlap deduplication

Both scripts require the `openpyxl` package. Install it if needed:
```bash
pip install openpyxl --break-system-packages
```

## Step-by-Step Execution

### Step 0: Read skill files

1. Read THIS file completely
2. Read `/mnt/skills/public/xlsx/SKILL.md` for Excel formatting guidance
3. Read `references/abub-patterns.md` for NJ-specific hearing patterns

### Step 1: Run the preprocessing script

The preprocessing script parses all input files, extracts low-confidence segments
from the JSON (if provided), and splits the transcript into overlapping chunks.

```bash
python scripts/preprocess_transcript.py \
    --transcript <path_to_speakers.txt> \
    --speakers <path_to_speaker_order.xlsx> \
    --members <path_to_members.xlsx> \
    --output-dir /home/claude/transcript_chunks \
    [--json <path_to_assemblyai.json>] \
    [--chunk-size 200] \
    [--overlap 20]
```

This produces:
- `manifest.json` — speaker lists, chunk metadata, label frequencies
- `chunk_001.txt`, `chunk_002.txt`, ... — overlapping transcript chunks
- `low_confidence.json` — (if JSON provided) flagged low-confidence segments

### Step 2: Load the manifest

Read `manifest.json` from the output directory. It contains:
- `speakers`: The full speaker order list with session, order, name, title, org
- `committee_members`: The committee members with name, note, district, party
- `chunks`: Metadata for each chunk (filename, time range, utterance indices)
- `speaker_label_frequencies`: How often each label appears (most frequent first)
- `has_low_confidence_data`: Whether low_confidence.json exists
- `unique_speaker_labels`: All speaker labels found in the transcript

### Step 3: Pass 1 — Build the speaker identity map

The goal of Pass 1 is to build a high-confidence mapping of speaker labels to real
names. Process every chunk, but ONLY extract identifications where evidence is strong.

Initialize:
```
speaker_map = {}        # {speaker_label: identified_name}
identification_evidence = {}  # {speaker_label: reason}
speaker_order_cursor = 0  # tracks position in the speaker order list
```

**Identify the chair first.** From the manifest:
1. Find the committee member with `note == "Chair"`
2. The most frequent speaker label (from `speaker_label_frequencies`) in the first
   chunk is almost certainly the chair
3. Add to speaker_map: `{most_frequent_label: chair_name}`

**For each chunk**, scan utterances for HIGH-confidence signals only:

1. **Self-identifications**: Look for patterns like:
   - "My name is [NAME]"
   - "I'm [NAME], [TITLE] at/of [ORG]"
   - "I am [NAME]"
   - "[NAME] here" / "This is [NAME]"
   Then match the extracted name against the speaker order list (fuzzy match —
   the list might say "T.J. Best" but the speaker says "TJ Best")

2. **Chair introductions**: The chair (already identified) calling speakers by name:
   - "Next we have [NAME]"
   - "[NAME], you're up"
   - "After [NAME], we'll have [NEXT_NAME]"
   The speaker label of the NEXT utterance after a chair introduction is likely
   the introduced speaker.

3. **Chair previews**: When the chair says "After X, we'll have Y", record Y as
   the expected next speaker even if they haven't spoken yet.

4. **Roll calls**: If a roll call occurs, committee members respond in sequence.
   Each response maps a label to a member.

**Do NOT attempt to resolve ambiguous cases in Pass 1.** Only record identifications
where you have direct textual evidence (a name match). The point is to build a
reliable foundation for Pass 2.

After processing all chunks, the speaker_map should have the chair and most testifying
speakers who self-identified. Some labels will remain unmapped — that's expected.

### Step 4: Pass 2 — Full correction

Process each chunk again, this time writing corrected output and using the full
speaker_map plus additional inference for remaining unknowns.

For each chunk:

1. **Load the chunk text**
2. **Apply known mappings** from speaker_map
3. **Attempt additional identification** for unmapped labels using:
   - **Organization match**: If the text discusses topics clearly aligned with a
     specific org from the speaker list, and the timing fits the expected order
   - **Speaker order position**: If surrounding speakers have been identified and
     this label falls between them in the expected order, the missing speaker from
     the list is a reasonable guess (MEDIUM confidence)
   - **Temporal continuity**: If a speaker label appears in consecutive utterances
     with no evidence of a speaker change, it's the same person
   - **Diarization error repair**: If Speaker E says half a sentence and Speaker F
     completes it (especially mid-phrase), they're likely the same person — assign
     both to whoever was identified
4. **Handle unresolvable labels**: Mark as `[UNIDENTIFIED]`
5. **Write corrected lines** to a running output list
6. **Log LOW and UNIDENTIFIED entries** to the uncertainty list

### Step 5: Write corrected chunks

For each chunk, write the corrected output to a file in a `pass2_corrected/`
directory inside the working directory.

Create the directory:
```bash
mkdir -p /home/claude/transcript_chunks/pass2_corrected
```

Each corrected chunk file (`chunk_001.txt`, `chunk_002.txt`, ...) should contain:

**Corrected utterance lines** — one per line, preserving the `{utterance_NNN}` tag
from the preprocessor for deduplication:
```
[HH:MM:SS] {utterance_42} Eliana Pintor Marin: Thank you. Next we have...
```

**Uncertainty lines** — for LOW and UNIDENTIFIED entries only:
```
UNCERTAINTY|HH:MM:SS|utterance_42|Speaker C|[UNIDENTIFIED]|UNIDENTIFIED|Brief interjection, no clues|If there are—
UNCERTAINTY|HH:MM:SS|utterance_105|Speaker AH|Duncan Harrison|LOW|Order matches but no self-ID|Good morning, we are here...
```

Rules for correction:
- Use the speaker's full name from the speaker list or members list
- If a speaker was confidently identified, just use their name
- If identification is uncertain (LOW confidence), use the best guess name
- If unidentifiable, use `[UNIDENTIFIED]`
- Preserve original timestamps exactly
- Preserve original spoken text exactly — do NOT edit words
- Where diarization clearly split one person's continuous speech across multiple
  speaker labels, keep individual timestamp entries but assign the correct name

### Step 6: Run the assembly script

The assembly script combines all corrected chunks, deduplicates overlapping
utterances (keeping the later chunk's version which has more context), and
produces the final formatted outputs.

```bash
python scripts/assemble_transcript.py \
    --corrected-dir /home/claude/transcript_chunks/pass2_corrected \
    --output-transcript /mnt/user-data/outputs/corrected_transcript.txt \
    --output-uncertainties /mnt/user-data/outputs/uncertainties.xlsx
```

The script produces:
- **Corrected transcript** (`.txt`) — clean `[HH:MM:SS] Speaker Name: text...` format
- **Uncertainty log** (`.xlsx`) — formatted with yellow fill for LOW, red for
  UNIDENTIFIED, frozen header, auto-filter

### Step 7: Present results

Present both files to the user and summarize:
- Total speakers identified (with count by confidence level)
- Number of LOW-confidence identifications needing review
- Number of UNIDENTIFIED utterances
- Any speakers from the sign-up sheet who were NOT found in the transcript
- Any notable issues (groups, out-of-order speakers, possible diarization errors)

## Input File Formats

### Speaker-labeled transcript (`.txt`)
Lines formatted as: `[HH:MM:SS] Speaker A: text...`
The speaker label is always `Speaker` followed by one or two letters (A-Z, AA-CZ).

### AssemblyAI JSON (`.json`, optional)
Contains `utterances` array with `speaker`, `text`, `start`, `end`, `confidence`,
and `words` fields. The `speaker` field has letter codes (A, B, AA, etc.).
Word-level confidence scores help identify unreliable segments.

### Speaker order list (`.xlsx`)
Columns: Session, #, Name, Title, Organization
- Session: time block (AM, Early PM, Late PM)
- \#: rough order within session (NOT reliable — speakers share numbers, skip, etc.)
- Multiple speakers can share the same order number (group testimony)

### Committee members list (`.xlsx`)
Columns: Name, Note, District, Party
- Note: role like "Chair", "Vice Chair", "Minority Budget Officer"
- These people interject with questions but are NOT on the speaker order list

## Context Clues — Priority Order

1. **Self-identification**: "My name is X" — strongest signal
2. **Chair introduction**: "Next we have X" — very strong
3. **Chair preview**: "After X, we'll have Y" — strong for predicting next speaker
4. **Organization match**: Speaker discusses topics matching a specific org
5. **Speaker order position**: Timing and sequence match expected order
6. **Temporal continuity**: Same label across consecutive utterances = same person
7. **Diarization error repair**: Incomplete sentences spanning label changes

## Key Challenges to Watch For

- **Diarization label instability**: The most common error. One person gets 2-3
  different labels across their testimony. Look for mid-sentence breaks.
- **Group testimony**: A lead speaker (e.g., Governor McGreevey) brings associates.
  They share one order number but each speaks separately.
- **Committee member interjections**: Legislators ask questions throughout — they're
  on the members list, not the speaker order list.
- **Name variations**: Sign-up says "T.J. Best", chair says "TJ", speaker says
  "Thomas Best". Use fuzzy matching (last name is usually reliable).
- **Out-of-order speakers**: Speakers arrive late, leave early, or get reordered.
  Don't force sequence matches.
- **Session boundaries**: Speaker labels may reset or shift between AM/PM sessions.
  Re-verify identifications after apparent session transitions.

## Important Constraints

- **Never fabricate identifications.** Wrong name is worse than `[UNIDENTIFIED]`.
- **The speaker order is ROUGH.** Use it as a tiebreaker, not primary evidence.
- **Preserve original text exactly.** Never edit the spoken words.
- **Label instability across time.** Speaker A at minute 5 may not be Speaker A
  at minute 300. Always verify using context, not just label consistency.
