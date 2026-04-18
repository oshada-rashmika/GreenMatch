import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import '../models/supervisor_profile.dart';

class SupervisorService {
  final AuthService _authService = AuthService();

  Future<SupervisorProfile> getSupervisorProfile(String supervisorId) async {
    try {
      if (supervisorId.isEmpty) {
        throw Exception('Supervisor ID is empty. Please log in again.');
      }

      final headers = await _authService.getAuthHeaders();
      final String baseUrl = await _authService.getBaseUrl();
      final url = '$baseUrl/api/supervisors/$supervisorId';

      final response = await http
          .get(Uri.parse(url), headers: headers)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw TimeoutException('Request timeout'),
          );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('✅ Supervisor profile loaded');
        // If the API wraps response in { success: true, data: { ... } }
        final profileData = responseData.containsKey('data') ? responseData['data'] : responseData;
        return SupervisorProfile.fromJson(profileData);
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please log in again.');
      } else if (response.statusCode == 404) {
        throw Exception('Supervisor profile not found.');
      } else {
        throw Exception('Server error (${response.statusCode}): ${response.body}');
      }
    } on TimeoutException {
      throw Exception('Connection timeout. Please check your internet connection.');
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  Future<Map<String, dynamic>> updateOnboarding({
    required String supervisorId,
    required List<String> specifications,
    required int capacityLimit,
  }) async {
    try {
      final headers = await _authService.getAuthHeaders();
      final String baseUrl = await _authService.getBaseUrl();

      final response = await http.patch(
        Uri.parse('$baseUrl/api/supervisors/$supervisorId/onboarding'),
        headers: headers,
        body: jsonEncode({
          'specifications': specifications,
          'capacityLimit': capacityLimit,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': 'Onboarding completed successfully',
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Failed to complete onboarding',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'An error occurred during onboarding: $e',
      };
    }
  }

  Future<Map<String, dynamic>> updateSupervisorProfile({
    required String supervisorId,
    String? fullName,
    String? staffId,
  }) async {
    try {
      final headers = await _authService.getAuthHeaders();
      final String baseUrl = await _authService.getBaseUrl();

      final response = await http.patch(
        Uri.parse('$baseUrl/api/supervisors/$supervisorId'),
        headers: headers,
        body: jsonEncode({
          if (fullName != null) 'fullName': fullName,
          if (staffId != null) 'staffId': staffId,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': 'Profile updated successfully',
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Failed to update profile',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'An error occurred updating profile: $e',
      };
    }
  }
}

