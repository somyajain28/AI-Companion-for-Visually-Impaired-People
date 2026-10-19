import os
import tempfile

from flask import Blueprint, request, jsonify
from services.speech_service import transcribe_audio

speech_routes = Blueprint("speech_routes", __name__)


@speech_routes.route("/api/speech-to-text", methods=["POST"])
def speech_to_text():
    if "audio" not in request.files:
        return jsonify({
            "success": False,
            "message": "No audio file received"
        }), 400

    audio_file = request.files["audio"]

    if audio_file.filename == "":
        return jsonify({
            "success": False,
            "message": "Empty audio file"
        }), 400

    # Optional language parameter from client (e.g. 'en', 'hi')
    language_hint = request.form.get("language")

    # Use original suffix or default to .wav
    suffix = os.path.splitext(audio_file.filename)[1] or ".wav"
    
    # Secure temporary file creation for Windows (close handle before saving)
    temp = tempfile.NamedTemporaryFile(delete=False, suffix=suffix)
    temp_path = temp.name
    temp.close()

    try:
        audio_file.save(temp_path)

        # Transcribe audio using faster-whisper service
        result = transcribe_audio(temp_path, language=language_hint)
        transcribed_text = result["text"]

        print(f"Transcribed Text: '{transcribed_text}' (Language: {result['language']})")

        return jsonify({
            "success": True,
            "text": transcribed_text,
            "language": result["language"]
        }), 200

    except Exception as e:
        print(f"Error during transcription: {e}")
        return jsonify({
            "success": False,
            "message": "Speech transcription failed",
            "error": str(e)
        }), 500

    finally:
        if os.path.exists(temp_path):
            try:
                os.remove(temp_path)
            except Exception:
                pass