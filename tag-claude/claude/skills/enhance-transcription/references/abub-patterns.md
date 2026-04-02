# NJ Assembly Budget Committee (ABUB) Hearing Patterns

## Reference: Known Patterns in ABUB Public Hearings

This file documents patterns observed in actual ABUB FY27 public hearing transcripts
that help with speaker identification.

### Chair Behavior Patterns

The ABUB Chair (typically Pintor Marin) has distinctive speech patterns:

- Opens with logistics: traffic, schedule, 3-minute rule
- Calls speakers by name: "Governor McGreevey", "Heather Sims", "Duncan Harrison"
- Previews the next speaker: "After X, we'll have Y"
- Manages time: "you've got 30 seconds", "3 seconds"
- Uses first names with familiarity for repeat attendees
- Occasionally personal asides: humor, personal connections
- Addresses speakers by "Good morning" / "Good afternoon" / "Good evening" as a
  time-of-day marker that helps identify session boundaries
- Closes sessions: "I will see all of you [date]"

### Speaker Self-Identification Patterns

Most testifying speakers identify themselves early in their testimony:
- "My name is [NAME]" — most common
- "I'm [NAME], [TITLE] at/of [ORG]" — very common
- "Good morning/afternoon, my name is [NAME]" — standard opening
- "[NAME], [ORG]" — abbreviated version

### Committee Member Identification

Committee members don't usually self-identify. They are recognized by:
- Being addressed as "Assemblyman/Assemblywoman [NAME]"
- Asking questions of testifying speakers
- References to specific districts ("the 5th District")
- Parliamentary language ("Madam Chairwoman", "Vice Chair")

### Diarization Error Patterns (AssemblyAI)

Common errors observed in the auto-transcription:

1. **Mid-speech label switches**: One person speaking continuously gets split across
   two labels (e.g., Speaker E → Speaker F → Speaker E). Very common. Look for
   incomplete sentences that span label changes.

2. **Quick interjection misattribution**: When the chair briefly interjects ("Thank you")
   during testimony, the next segment of the testifier's speech may get assigned to
   the chair's label.

3. **Group testimony confusion**: When multiple speakers from the same organization
   take turns, the diarization struggles and may cycle through 3-4 labels for 2 people.

4. **Low-confidence segments**: Short utterances ("Yes", "Thank you", "Go ahead")
   are frequently misattributed. These have low confidence scores in the JSON data.

5. **Label reuse across sessions**: Speaker A in the morning session is NOT necessarily
   Speaker A in the afternoon. Labels can reset or shift.

### Session Boundary Markers

- Time-of-day greetings shift: "Good morning" → "Good afternoon" → "Good evening"
- Chair may announce breaks or transitions
- Timestamp gaps (e.g., 30-minute jump) indicate breaks
- The speaker order list has Session column (AM, Early PM, Late PM)

### Typical Speaker Order Deviations

- Speakers 1-5 are usually in order
- After that, order becomes less reliable
- Late arrivals get slotted in when they show up
- Some speakers leave before being called
- The chair sometimes reorders to accommodate schedules
- Groups sharing an order number testify sequentially

### Name Matching Challenges

The sign-up sheet names may not match how people introduce themselves:
- "Governor McGreevey" on the list → "Jim McGreevey" or "Governor" in speech
- "T.J. Best" → "TJ" in casual reference
- "Dr. Sara Pagliaro" → "Sara Pagliaro" or just "Dr. Pagliaro"
- "Lady Jimenez Torres" → may use partial name
- Typos on the sign-up sheet are possible
- Titles (Dr., Rev., etc.) may or may not be used
