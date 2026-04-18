import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class SupervisorService {
  final AuthService _authService = AuthService();
  
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
