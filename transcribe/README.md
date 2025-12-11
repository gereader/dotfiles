📘 Mini README for Future You

Below is a compact README you can save somewhere (e.g., ~/Documents/whisper-readme.md).

Whisper.cpp Local Transcription Setup (macOS)
Install Dependencies
brew install whisper-cpp ffmpeg

Download a Model

Get the GGML model file (e.g., ggml-large-v3.bin) from:

<https://huggingface.co/ggerganov/whisper.cpp/tree/main>

Place it in:

~/.local/share/whisper.cpp/models/

Environment Variable

Add this to your ~/.zshrc:

export WHISPER_CPP_MODEL_DIR="$HOME/.local/share/whisper.cpp/models"

Reload:

source ~/.zshrc

Automatic Transcription Function

Add this function to ~/.zshrc:

transcribe() {
    if [ -z "$1" ]; then
        echo "Usage: transcribe <input-file>"
        return 1
    fi

    INPUT="$1"
    BASENAME="${INPUT%.*}"
    WAVFILE="${BASENAME}.wav"
    OUTFILE="${BASENAME}"
    MODEL="$WHISPER_CPP_MODEL_DIR/ggml-large-v3.bin"

    ffmpeg -i "$INPUT" -vn -ac 1 -ar 16000 -f wav "$WAVFILE"
    whisper-cli -m "$MODEL" -mc 32 -otxt -of "$OUTFILE" "$WAVFILE"

    echo "Transcript saved to: $OUTFILE"
}

Usage
transcribe meeting.mp4

Outputs:

meeting.wav

meeting.txt (transcription)
