#!/usr/bin/env python3
"""
VTT Cue Merger

Merges WebVTT subtitle cues into larger, more readable blocks based on:
- Time duration targets
- Natural punctuation boundaries
- Silence gaps between cues
"""

import argparse
import re
from dataclasses import dataclass
from pathlib import Path

# Regex patterns for parsing timestamps and cue timing lines
TIMESTAMP_PATTERN = re.compile(r"(?P<hours>\d{2}):(?P<minutes>\d{2}):(?P<seconds>\d{2})\.(?P<milliseconds>\d{3})")
CUE_TIMING_PATTERN = re.compile(r"^(?P<start>\d{2}:\d{2}:\d{2}\.\d{3})\s*-->\s*(?P<end>\d{2}:\d{2}:\d{2}\.\d{3})")
SENTENCE_END_PATTERN = re.compile(r"[.!?]\s*$")


@dataclass
class Cue:
    """Represents a single subtitle cue with timing and text."""

    start: float
    end: float
    text: str


def timestamp_to_seconds(timestamp: str) -> float:
    """
    Convert a VTT timestamp (HH:MM:SS.mmm) to seconds.

    Args:
        timestamp: Timestamp string in format "HH:MM:SS.mmm"

    Returns:
        Total seconds as float

    Raises:
        ValueError: If timestamp format is invalid
    """
    match = TIMESTAMP_PATTERN.match(timestamp.strip())
    if not match:
        raise ValueError(f"Invalid timestamp format: {timestamp}")

    hours = int(match["hours"])
    minutes = int(match["minutes"])
    seconds = int(match["seconds"])
    milliseconds = int(match["milliseconds"])

    return hours * 3600 + minutes * 60 + seconds + milliseconds / 1000.0


def seconds_to_timestamp(seconds: float) -> str:
    """
    Convert seconds to HH:MM:SS timestamp format.

    Args:
        seconds: Time in seconds

    Returns:
        Formatted timestamp string "HH:MM:SS"
    """
    total_seconds = int(seconds)
    hours = total_seconds // 3600
    minutes = (total_seconds % 3600) // 60
    secs = total_seconds % 60
    return f"{hours:02d}:{minutes:02d}:{secs:02d}"


def parse_vtt_file(vtt_content: str) -> list[Cue]:
    """
    Parse a WebVTT file into a list of Cue objects.

    Args:
        vtt_content: Full text content of the VTT file

    Returns:
        List of parsed Cue objects
    """
    lines = [line.rstrip("\n") for line in vtt_content.splitlines()]
    cues = []
    line_index = 0

    # Skip header (WEBVTT lines and initial blank lines)
    while line_index < len(lines):
        line = lines[line_index].strip()
        if not line or line.upper().startswith("WEBVTT"):
            line_index += 1
        else:
            break

    # Parse cues
    while line_index < len(lines):
        line = lines[line_index].strip()

        # Skip blank lines
        if not line:
            line_index += 1
            continue

        # Check if this line contains timing information
        timing_match = CUE_TIMING_PATTERN.match(line)
        if not timing_match:
            line_index += 1
            continue

        # Parse start and end times
        start_time = timestamp_to_seconds(timing_match["start"])
        end_time = timestamp_to_seconds(timing_match["end"])
        line_index += 1

        # Collect all text lines for this cue (until next blank line)
        text_lines = []
        while line_index < len(lines) and lines[line_index].strip():
            text_lines.append(lines[line_index].strip())
            line_index += 1

        # Join and normalize whitespace
        cue_text = " ".join(text_lines).strip()
        cue_text = re.sub(r"\s+", " ", cue_text)

        if cue_text:
            cues.append(Cue(start=start_time, end=end_time, text=cue_text))

        line_index += 1

    return cues


def merge_cues_into_blocks(
    cues: list[Cue],
    target_duration: float,
    min_duration: float,
    gap_threshold: float,
) -> list[tuple[float, float, str]]:
    """
    Merge cues into larger blocks based on timing and punctuation rules.

    Args:
        cues: List of Cue objects to merge
        target_duration: Preferred block duration in seconds
        min_duration: Minimum duration before allowing punctuation break
        gap_threshold: Gap size that forces a new block (seconds)

    Returns:
        List of tuples (start_time, end_time, merged_text)
    """
    if not cues:
        return []

    blocks = []
    current_start = cues[0].start
    current_end = cues[0].end
    current_text_parts = [cues[0].text]

    def save_current_block():
        """Save the current block and reset for next block."""
        nonlocal current_start, current_end, current_text_parts
        merged_text = " ".join(current_text_parts).strip()
        merged_text = re.sub(r"\s+", " ", merged_text)
        if merged_text:
            blocks.append((current_start, current_end, merged_text))
        current_text_parts = []

    # Process each cue, comparing with the previous one
    for previous_cue, current_cue in zip(cues, cues[1:]):
        gap_duration = current_cue.start - previous_cue.end
        block_duration = current_end - current_start

        # Determine if we should start a new block
        has_sentence_ending = bool(SENTENCE_END_PATTERN.search(previous_cue.text))
        should_break = False

        if gap_duration >= gap_threshold:
            # Large silence gap indicates natural break
            should_break = True
        elif block_duration >= target_duration:
            # Block is long enough
            should_break = True
        elif has_sentence_ending and block_duration >= min_duration:
            # Natural sentence boundary with sufficient duration
            should_break = True

        if should_break:
            save_current_block()
            current_start = current_cue.start
            current_text_parts = [current_cue.text]
        else:
            current_text_parts.append(current_cue.text)

        current_end = current_cue.end

    # Save the final block
    save_current_block()
    return blocks


def main() -> int:
    """Main entry point for the VTT merger script."""
    parser = argparse.ArgumentParser(description="Merge WebVTT subtitle cues into larger, more readable blocks")
    parser.add_argument("vtt", type=Path, help="Input .vtt file")
    parser.add_argument("-o", "--out", type=Path, help="Output .txt file (default: <input>.merged.txt)")
    parser.add_argument("--target", type=float, default=75.0, help="Target block duration in seconds (default: 75)")
    parser.add_argument(
        "--min",
        dest="min_duration",
        type=float,
        default=25.0,
        help="Minimum duration before punctuation break (default: 25)",
    )
    parser.add_argument(
        "--gap", type=float, default=1.2, help="Gap duration that forces a new block in seconds (default: 1.2)"
    )
    args = parser.parse_args()

    # Read and parse the VTT file
    vtt_content = args.vtt.read_text(encoding="utf-8", errors="replace")
    cues = parse_vtt_file(vtt_content)

    # Merge cues into blocks
    blocks = merge_cues_into_blocks(
        cues,
        target_duration=args.target,
        min_duration=args.min_duration,
        gap_threshold=args.gap,
    )

    # Write output
    output_path = args.out or args.vtt.with_suffix(".merged.txt")
    with output_path.open("w", encoding="utf-8") as output_file:
        for start_time, end_time, text in blocks:
            output_file.write(f"[{seconds_to_timestamp(start_time)}–{seconds_to_timestamp(end_time)}]\n")
            output_file.write(text + "\n\n")

    print(str(output_path))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
