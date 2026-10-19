import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  final FlutterTts _flutterTts = FlutterTts();

  Future<void> initialize() async {
    await _flutterTts.setVolume(1.0);
    // Faster, crisper speech rate (increased from 0.5 to 0.65)
    await _flutterTts.setSpeechRate(0.65);
    await _flutterTts.setPitch(1.0);
    // Default to Indian English
    await _flutterTts.setLanguage('en-IN');
    await _flutterTts.awaitSpeakCompletion(true);
  }

  Future<void> speak(
    String text, {
    String language = 'en-IN',
  }) async {
    await _flutterTts.setLanguage(language);
    await _flutterTts.speak(text);
  }

  Future<void> stop() async {
    await _flutterTts.stop();
  }

  Future<void> setSpeechRate(double rate) async {
    await _flutterTts.setSpeechRate(rate);
  }
}
