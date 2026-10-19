import 'dart:convert';
import 'package:http/http.dart' as http;

class BackendApiService {
  static const String baseUrl = 'http://127.0.0.1:5000';

  /// Registers user in MySQL USER & USER_PREFERENCES tables.
  Future<Map<String, dynamic>> registerUser({
    required String userName,
    required String userEmail,
    required String dateOfBirth,
    required String phoneNumber,
    required String password,
    String preferredLanguage = 'English',
  }) async {
    try {
      final regResponse = await http.post(
        Uri.parse('$baseUrl/api/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_name': userName.trim(),
          'user_email': userEmail.trim().toLowerCase(),
          'password': password.trim(),
          'date_of_birth': dateOfBirth.trim(),
          'phone_number': phoneNumber.trim(),
          'preferred_language': preferredLanguage,
        }),
      );

      final data = jsonDecode(regResponse.body) as Map<String, dynamic>;
      if (regResponse.statusCode == 201) {
        return {
          'success': true,
          'user': data['user'] as Map<String, dynamic>,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Registration failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Cannot connect to backend server: $e',
      };
    }
  }

  /// Logs in a user using userName and password.
  /// Returns structured status including user_not_found or incorrect_password.
  Future<Map<String, dynamic>> loginUser({
    required String userName,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_name': userName.trim(),
          'password': password.trim(),
        }),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return {
          'success': true,
          'user': data['user'] as Map<String, dynamic>,
          'preferences': data['preferences'] as Map<String, dynamic>?,
          'token': data['token'],
        };
      } else {
        return {
          'success': false,
          'error_type': data['error_type'] ?? 'unknown_error',
          'message': data['message'] ?? 'Login failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error_type': 'connection_error',
        'message': 'Cannot connect to backend server: $e',
      };
    }
  }

  /// Adds an emergency contact into MySQL EMERGENCY_CONTACT table.
  Future<Map<String, dynamic>> addEmergencyContact({
    required int userId,
    required String name,
    required String relationship,
    required String phoneNumber,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/emergency-contacts'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'name': name.trim(),
        'relationship': relationship.trim(),
        'phone_number': phoneNumber.trim(),
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add emergency contact: ${response.statusCode} ${response.body}');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  /// Saves a location into MySQL LOCATION table.
  Future<Map<String, dynamic>> addLocation({
    required int userId,
    required String locationName,
    required String locationType,
    String? address,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/locations'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'location_name': locationName.trim(),
        'location_type': locationType.trim(),
        'address': address?.trim() ?? locationName.trim(),
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to save location: ${response.statusCode} ${response.body}');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  /// Saves voice notes into MySQL SAVED_INFORMATION table.
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

  /// Retrieves saved notes from MySQL SAVED_INFORMATION table.
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
