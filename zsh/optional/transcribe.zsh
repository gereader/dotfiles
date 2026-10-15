# Requires whisper-cpp, ffmpeg, and WHISPER_CPP_MODEL_DIR in ~/.zshrc.local. Setup: transcribe/README.md
# Transcribe a video/audio file with Whisper.cpp
transcribe() {
    if [ -z "$1" ]; then
        echo "Usage: transcribe <input-file>"
        return 1
    fi

    INPUT="$1"
    BASENAME="${INPUT%.*}"
    MODEL="$WHISPER_CPP_MODEL_DIR/ggml-large-v3.bin"

    # Temp wav file for processing
    WAVFILE="/tmp/whisper-${BASENAME}.wav"


    # Output Files
    VTTFILE="${BASENAME}.vtt"
    MERGED="${BASENAME}.transcript.txt"

    # Sanity Checks for require resources
    if [ ! -f "$MODEL" ]; then
        echo "Whisper model not found: $MODEL"
        return 1
    fi

    if ! command -v whisper-cli >/dev/null 2>&1; then
        echo "whisper-cli not found in PATH"
        return 1
    fi

    if ! command -v ffmpeg >/dev/null 2>&1; then
        echo "ffmpeg not found in PATH"
        return 1
    fi


    # Extract audio
    ffmpeg -hide_banner -loglevel error -y -i "$INPUT" -vn -ac 1 -ar 16000 -f wav "$WAVFILE" || return 1

    # Transcribe to VTT
    whisper-cli -m "$MODEL" -mc 0 -et 2.0 -lpt -0.5 -nth 0.7 -pp -ovtt -of "$BASENAME" "$WAVFILE" || { rm -f "$WAVFILE"; return 1; }

    # Merge VTT cues into bigger blocks
    "$DOTFILES_DIR/scripts/vtt_merge.py" "$VTTFILE" -o "$MERGED" --target 75 --min 25 --gap 1.2 || { rm -f "$WAVFILE"; return 1; }
    echo "Done. Merged transcript: $MERGED"

    # Cleanup
    rm -f "$WAVFILE"
}
