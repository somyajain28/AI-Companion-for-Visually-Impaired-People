import os
from faster_whisper import WhisperModel

# Singleton Whisper model instance
_model = None

MODEL_SIZE = os.getenv("WHISPER_MODEL_SIZE", "base")
COMPUTE_TYPE = os.getenv("WHISPER_COMPUTE_TYPE", "int8")
DEVICE = os.getenv("WHISPER_DEVICE", "cpu")


def get_whisper_model():
    """Lazily load and cache the faster-whisper model."""
    global _model

    if _model is None:
        print(f"Loading faster-whisper model ({MODEL_SIZE}) on {DEVICE} ({COMPUTE_TYPE})...")
        _model = WhisperModel(
            MODEL_SIZE,
            device=DEVICE,
            compute_type=COMPUTE_TYPE
        )
        print("Whisper model loaded successfully.")

    return _model


def transcribe_audio(audio_path, language=None):
    """
    Transcribes audio at the given file path.
    :param audio_path: Absolute or relative path to the audio file.
    :param language: Optional 2-letter language code (e.g., 'en', 'hi') to guide transcription.
    :return: Dict containing text, detected language, and confidence.
    """
    model = get_whisper_model()

    transcribe_options = {
        "beam_size": 5,
        "vad_filter": True  # Voice Activity Detection filters out silent background noise
    }

    if language:
        transcribe_options["language"] = language

    segments, info = model.transcribe(audio_path, **transcribe_options)

    text = " ".join(
        segment.text.strip()
        for segment in segments
    ).strip()

    return {
        "text": text,
        "language": info.language,
        "language_probability": getattr(info, "language_probability", 1.0)
    }