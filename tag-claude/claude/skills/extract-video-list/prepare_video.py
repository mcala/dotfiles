# /// script
# requires-python = ">=3.13"
# dependencies = [
#   "faster-whisper",
#   "socksio",
# ]
# ///
# ABOUTME: Prepares a short-form video for list extraction by extracting
# ABOUTME: frames at regular intervals and transcribing the audio track.
"""
Prepare a short-form video for list extraction.

Extracts frames at regular intervals and transcribes the audio track.
Outputs:
  <stem>_frames/frame_001.jpg, frame_002.jpg, ...
  <stem>_transcript.txt
"""

from __future__ import annotations

import argparse
import json
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

from faster_whisper import WhisperModel


def check_ffmpeg() -> None:
    """Verify ffmpeg and ffprobe are available."""
    for tool in ("ffmpeg", "ffprobe"):
        if shutil.which(tool) is None:
            print(f"Error: {tool} is not installed or not on PATH.", file=sys.stderr)
            print("Install it with: apt install ffmpeg  (or brew install ffmpeg)", file=sys.stderr)
            sys.exit(1)


def get_duration(video_path: Path) -> float:
    """Get video duration in seconds via ffprobe."""
    result = subprocess.run(
        [
            "ffprobe",
            "-v", "error",
            "-show_entries", "format=duration",
            "-of", "json",
            video_path,
        ],
        capture_output=True,
        text=True,
        check=True,
    )
    info = json.loads(result.stdout)
    return float(info["format"]["duration"])


def extract_frames(video_path: Path, output_dir: Path) -> list[Path]:
    """Extract frames from video at calculated intervals.

    Targets ~10 frames, with a minimum interval of 2 seconds.
    Scales to 1024px width, JPEG output.
    """
    duration = get_duration(video_path)
    interval = max(2.0, duration / 10.0)
    fps_filter = f"fps=1/{interval:.2f},scale=1024:-1"

    output_dir.mkdir(parents=True, exist_ok=True)
    pattern = output_dir.joinpath("frame_%03d.jpg")

    subprocess.run(
        [
            "ffmpeg",
            "-i", str(video_path),
            "-vf", fps_filter,
            "-q:v", "2",
            "-y",
            str(pattern),
        ],
        capture_output=True,
        check=True,
    )

    frames = sorted(output_dir.glob("frame_*.jpg"))

    # Fallback: if too few frames, retry at 1fps
    if len(frames) < 2 and duration > 1:
        for f in frames:
            f.unlink()
        subprocess.run(
            [
                "ffmpeg",
                "-i", str(video_path),
                "-vf", "fps=1,scale=1024:-1",
                "-q:v", "2",
                "-y",
                str(pattern),
            ],
            capture_output=True,
            check=True,
        )
        frames = sorted(output_dir.glob("frame_*.jpg"))

    return frames


def transcribe_audio(video_path: Path, output_path: Path) -> str:
    """Extract audio from video and transcribe using faster-whisper."""
    with tempfile.NamedTemporaryFile(suffix=".wav", delete=False) as tmp:
        wav_path = Path(tmp.name)

    try:
        # Extract audio as 16kHz mono WAV
        result = subprocess.run(
            [
                "ffmpeg",
                "-i", str(video_path),
                "-vn",
                "-acodec", "pcm_s16le",
                "-ar", "16000",
                "-ac", "1",
                "-y",
                str(wav_path),
            ],
            capture_output=True,
            text=True,
        )

        if result.returncode != 0:
            print(f"Warning: Audio extraction failed: {result.stderr.strip()}", file=sys.stderr)
            output_path.write_text("[No audio could be extracted from this video]")
            return "[No audio could be extracted from this video]"

        # Transcribe with faster-whisper
        model = WhisperModel("base", compute_type="int8")
        segments, _info = model.transcribe(str(wav_path), beam_size=5)

        transcript_lines: list[str] = []
        for segment in segments:
            transcript_lines.append(f"[{segment.start:.1f}s - {segment.end:.1f}s] {segment.text.strip()}")

        transcript = "\n".join(transcript_lines)

        if not transcript.strip():
            transcript = "[No speech detected in audio]"

        output_path.write_text(transcript)
        return transcript

    except Exception as exc:
        msg = f"[Audio transcription failed: {exc}]"
        print(f"Warning: {msg}", file=sys.stderr)
        output_path.write_text(msg)
        return msg
    finally:
        wav_path.unlink(missing_ok=True)


def main() -> None:
    parser = argparse.ArgumentParser(description="Prepare a video for list extraction")
    parser.add_argument("input", help="Path to .mp4 video file")
    args = parser.parse_args()

    video_path = Path(args.input).resolve()
    if not video_path.exists():
        print(f"Error: File not found: {video_path}", file=sys.stderr)
        sys.exit(1)
    if not video_path.suffix.lower() == ".mp4":
        print(f"Warning: Expected .mp4 file, got {video_path.suffix}", file=sys.stderr)

    check_ffmpeg()

    stem = video_path.stem
    parent = video_path.parent
    frames_dir = parent.joinpath(f"{stem}_frames")
    transcript_path = parent.joinpath(f"{stem}_transcript.txt")

    # Extract frames
    print(f"Extracting frames from {video_path.name}...")
    duration = get_duration(video_path)
    print(f"Video duration: {duration:.1f}s")

    frames = extract_frames(video_path, frames_dir)
    print(f"Extracted {len(frames)} frames to {frames_dir}")
    for frame in frames:
        print(f"  {frame.name}")

    # Transcribe audio
    print(f"\nTranscribing audio...")
    transcript = transcribe_audio(video_path, transcript_path)
    print(f"Transcript saved to {transcript_path}")

    # Preview transcript
    preview = transcript[:500]
    if len(transcript) > 500:
        preview += "..."
    print(f"\nTranscript preview:\n{preview}")

    print(f"\nDone. Ready for analysis.")
    print(f"  Frames directory: {frames_dir}")
    print(f"  Transcript file:  {transcript_path}")


if __name__ == "__main__":
    main()
