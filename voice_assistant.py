import sys
from pathlib import Path

# Add OpenJarvis source directory
sys.path.insert(0, str(Path.home() / ".openjarvis/src/src"))

import httpx

from openjarvis.speech.faster_whisper import FasterWhisperBackend
from openjarvis.speech.cartesia_tts import CartesiaTTSBackend
from openjarvis.speech.voice_io import (
    record_until_silence,
    play_audio_file,
)

# Local Qwen server
QWEN_URL = "http://localhost:8080/v1/chat/completions"
MODEL = "mlx-community/Qwen3.5-4B-OptiQ-4bit"

# Initialize speech recognition
stt = FasterWhisperBackend(
    model_size="small",
    device="cpu",
    compute_type="int8",
)

# Initialize Cartesia
tts = CartesiaTTSBackend(language="en")

# Conversation history
messages = [
    {
        "role": "system",
        "content": (
            "You are a helpful AI companion for visually impaired people. "
            "Give clear, concise and useful responses. "
            "Use simple language and provide practical assistance."
        ),
    }
]

EXIT_COMMANDS = {
    "exit",
    "quit",
    "stop",
    "stop assistant",
}


def main():
    print("\n=== AI COMPANION VOICE ASSISTANT ===")
    print("You can speak naturally.")
    print("Say 'exit', 'quit', or 'stop assistant' to end.\n")

    try:
        while True:

            # Step 1: Record microphone audio
            print("\nListening... Speak now.")

            audio = record_until_silence(
                silence_seconds=1.5,
                startup_silence_seconds=5.0,
                max_seconds=30,
            )

            print("Recording finished.")

            # Step 2: Convert speech to text
            print("\nTranscribing English speech...")

            transcription = stt.transcribe(
                audio,
                format="wav",
                language="en",
            )

            user_text = transcription.text.strip()

            if not user_text:
                print("No speech detected. Listening again...")
                continue

            print("\nYou:", user_text)

            # Step 3: Check exit commands
            if user_text.lower().strip(" .!?") in EXIT_COMMANDS:
                print("\nAI Companion: Goodbye! I am here whenever you need me.")
                break

            # Step 4: Ask local Qwen
            print("\nQwen is thinking...")

            messages.append({
                "role": "user",
                "content": user_text,
            })

            payload = {
                "model": MODEL,
                "messages": messages,
                "temperature": 0.7,
                "max_tokens": 512,
                "stream": False,
                "chat_template_kwargs": {
                    "enable_thinking": False
                },
            }

            with httpx.Client(timeout=120.0) as client:
                response = client.post(
                    QWEN_URL,
                    json=payload,
                )
                response.raise_for_status()

            result = response.json()

            assistant_text = (
                result["choices"][0]["message"]["content"] or ""
            ).strip()

            if not assistant_text:
                print("Qwen returned an empty response.")
                messages.pop()
                continue

            print("\nAI Companion:", assistant_text)

            messages.append({
                "role": "assistant",
                "content": assistant_text,
            })

            # Step 5: Convert response to speech
            print("\nGenerating Cartesia speech...")

            audio_result = tts.synthesize(
                assistant_text,
                voice_id="47c38ca4-5f35-497b-b1a3-415245fb35e1",
                output_format="mp3",
                language="en",
            )

            audio_path = Path("/tmp/ai-companion-response.mp3")
            audio_result.save(audio_path)

            # Step 6: Play response
            print("\nPlaying AI Companion response...")
            play_audio_file(audio_path)

            print("\nVoice interaction completed.")
            print("You can speak again.")

    except KeyboardInterrupt:
        print("\n\nAI Companion stopped by keyboard.")

    print("\nAI Companion session ended.")


if __name__ == "__main__":
    main()
