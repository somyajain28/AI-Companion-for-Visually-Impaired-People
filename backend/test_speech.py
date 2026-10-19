"""
Verification script for the Speech-to-Text Pipeline (Phase 3 Integration).
Tests both direct WhisperModel transcription and the Flask HTTP endpoint.
"""
import io
import os
import sys

from app import app
from services.speech_service import transcribe_audio

def main():
    print("=" * 60)
    print("STEP 1: Testing Voice Pipeline Verification")
    print("=" * 60)

    sample_audio_path = os.path.join(os.path.dirname(__file__), "test.aiff")
    if not os.path.exists(sample_audio_path):
        print(f"Error: Sample audio file not found at {sample_audio_path}")
        sys.exit(1)

    print(f"\n1. Direct Transcription Test (using faster-whisper service):")
    result = transcribe_audio(sample_audio_path)
    print(f"   Transcribed text: \"{result['text']}\"")
    print(f"   Detected language: {result['language']}")
    assert result['text'], "Direct transcription returned empty text!"
    print("   -> Direct faster-whisper service: PASSED [OK]")

    print(f"\n2. Flask HTTP API Endpoint Test (POST /api/speech-to-text):")
    client = app.test_client()

    with open(sample_audio_path, "rb") as f:
        audio_bytes = f.read()

    response = client.post(
        "/api/speech-to-text",
        data={
            "audio": (io.BytesIO(audio_bytes), "test.wav"),
            "language": "en"
        },
        content_type="multipart/form-data"
    )

    print(f"   HTTP Status Code: {response.status_code}")
    json_data = response.get_json()
    print(f"   Response payload: {json_data}")

    assert response.status_code == 200, f"Expected status 200, got {response.status_code}"
    assert json_data.get("success") is True, "Response success is not True"
    assert "text" in json_data and len(json_data["text"]) > 0, "No text returned"
    print("   -> Flask API Endpoint: PASSED [OK]")

    print("\n" + "=" * 60)
    print("SUCCESS: Voice Conversation Pipeline is verified and working!")
    print("=" * 60)

if __name__ == "__main__":
    main()
