import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class SupervisorService {
  final AuthService _authService = AuthService();

  Future<Map<String, dynamic>> getSupervisorProfile(String supervisorId) async {
    try {
      if (supervisorId.isEmpty) {
        return {
          'success': false,
          'message': 'Supervisor ID is empty. Please log in again.',
        };
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
        try {
          final data = jsonDecode(response.body);
          print('✅ Supervisor profile loaded: ${data.keys}');
          return {'success': true, 'data': data};
        } catch (e) {
          print('❌ JSON parse error: $e');
          print('❌ Response body: ${response.body}');
          return {
            'success': false,
            'message':
                'Failed to parse response: $e. Response: ${response.body}',
          };
        }
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Unauthorized. Please log in again.',
        };
      } else if (response.statusCode == 404) {
        return {'success': false, 'message': 'Supervisor profile not found.'};
      } else {
        return {
          'success': false,
          'message': 'Server error (${response.statusCode}): ${response.body}',
        };
      }
    } on TimeoutException {
      return {
        'success': false,
        'message': 'Connection timeout. Please check your internet connection.',
      };
    } catch (e) {
      return {'success': false, 'message': 'An error occurred: $e'};
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
}
