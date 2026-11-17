import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

class SpeechApiService {
  static const String baseUrl = 'http://127.0.0.1:5000';

  Future<Map<String, dynamic>> convertSpeechToText(
    Uint8List audioBytes, {
    String? language,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/api/speech-to-text'),
    );

    if (language != null && language.isNotEmpty) {
      request.fields['language'] = language;
    }

    request.files.add(
      http.MultipartFile.fromBytes(
        'audio',
        audioBytes,
        filename: 'input.wav',
      ),
    );

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Speech-to-text request failed: '
        '${response.statusCode} $responseBody',
      );
    }

    return jsonDecode(responseBody) as Map<String, dynamic>;
  }
}
