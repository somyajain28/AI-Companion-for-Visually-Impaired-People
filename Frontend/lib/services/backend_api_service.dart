import 'dart:convert';
import 'package:http/http.dart' as http;

class BackendApiService {
  static const String baseUrl = 'http://127.0.0.1:5000';

  /// Registers user in MySQL USER & USER_PREFERENCES tables.
  /// If already registered, logs them in.
  Future<Map<String, dynamic>> registerOrLoginUser({
    required String userName,
    required String userEmail,
    required String phoneNumber,
    String preferredLanguage = 'English',
  }) async {
    const defaultPassword = 'CompanionUser123!';

    try {
      // 1. Try to register
      final regResponse = await http.post(
        Uri.parse('$baseUrl/api/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_name': userName.trim(),
          'user_email': userEmail.trim().toLowerCase(),
          'password': defaultPassword,
          'phone_number': phoneNumber.trim(),
          'preferred_language': preferredLanguage,
        }),
      );

      if (regResponse.statusCode == 201) {
        final data = jsonDecode(regResponse.body);
        return data['user'] as Map<String, dynamic>;
      }

      // 2. If email already exists (409 Conflict), log in
      if (regResponse.statusCode == 409) {
        final loginResponse = await http.post(
          Uri.parse('$baseUrl/api/login'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'user_email': userEmail.trim().toLowerCase(),
            'password': defaultPassword,
          }),
        );

        if (loginResponse.statusCode == 200) {
          final data = jsonDecode(loginResponse.body);
          return data['user'] as Map<String, dynamic>;
        }
      }

      throw Exception('Registration error: ${regResponse.statusCode} ${regResponse.body}');
    } catch (e) {
      throw Exception('Backend connection error: $e');
    }
  }

  /// Adds an emergency contact into the MySQL EMERGENCY_CONTACT table.
  Future<Map<String, dynamic>> addEmergencyContact({
    required int userId,
    required String name,
    required String phoneNumber,
    String relationship = 'Caregiver',
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/emergency-contacts'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'name': name.trim(),
        'phone_number': phoneNumber.trim(),
        'relationship': relationship,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add emergency contact: ${response.statusCode} ${response.body}');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  /// Saves a location into the MySQL LOCATION table.
  Future<Map<String, dynamic>> addLocation({
    required int userId,
    required String locationName,
    required String address,
    String locationType = 'home',
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/locations'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'location_name': locationName.trim(),
        'location_type': locationType,
        'address': address.trim(),
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to save location: ${response.statusCode} ${response.body}');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  /// Saves voice notes into the MySQL SAVED_INFORMATION table.
  Future<Map<String, dynamic>> saveInformation({
    required int userId,
    required String content,
    String title = 'Voice Note',
    String informationType = 'voice_memory',
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/saved-information'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'title': title,
        'content': content.trim(),
        'information_type': informationType,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to save information: ${response.statusCode} ${response.body}');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  /// Retrieves saved notes from the MySQL SAVED_INFORMATION table.
  Future<List<Map<String, dynamic>>> getSavedInformation(int userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/saved-information/$userId'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch saved information: ${response.statusCode}');
    }

    final data = jsonDecode(response.body);
    final items = data['saved_information'] as List<dynamic>;
    return items.map((e) => e as Map<String, dynamic>).toList();
  }
}
