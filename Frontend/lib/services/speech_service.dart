import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:record/record.dart';

class SpeechService {
  final AudioRecorder _audioRecorder = AudioRecorder();

  // 1. Start Recording User Voice in the Browser
  Future<void> startRecording() async {
    // This will trigger the browser's native microphone permission popup
    if (await _audioRecorder.hasPermission()) {
      // On web, a path argument can be empty or a dummy name
      await _audioRecorder.start(
        const RecordConfig(encoder: AudioEncoder.opus, sampleRate: 16000), 
        path: '', 
      );
      print("Browser recording started...");
    }
  }

  // 2. Stop Recording & Send Audio to Flask Backend
  Future<String?> stopAndSendRecording() async {
    final path = await _audioRecorder.stop();
    if (path == null) {
      print("Recording failed to stop or path is null.");
      return null;
    }

    try {
      // For a website running locally, use localhost:5000
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://127.0.0.1:5000/api/speech-to-text'),
      );

      // Attach the recorded audio file from the browser blob path
      request.files.add(
        await http.MultipartFile.fromPath('audio', path),
      );

      print("Sending audio to Flask backend...");
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String recognizedText = data['text'];
        print("Recognized Text: $recognizedText");
        return recognizedText; // Hand this text over to your AI conversation flow!
      } else {
        print("Server error: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Network or upload error: $e");
      return null;
    }
  }
}