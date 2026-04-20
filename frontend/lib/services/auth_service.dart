import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static const String _configuredBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
  );
  static const String _tokenKey = 'auth_token';

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  String get _baseUrl {
    if (_configuredBaseUrl.isNotEmpty) {
      return _configuredBaseUrl;
    }

    if (kIsWeb) {
      return 'http://localhost:3000';
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2:3000';
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        return 'http://localhost:3000';
    }
  }

  Future<String> getBaseUrl() async {
    return _baseUrl;
  }

  String _mapNetworkError(Object error) {
    if (error is SocketException) {
      return 'Cannot reach backend at $_baseUrl. '
          'If using Android emulator, 10.0.2.2 is required. '
          'Also ensure NestJS is running on port 3000.';
    }

    return 'Network error: ${error.toString()}';
  }

  Future<Map<String, dynamic>> studentLogin({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/student/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _storeToken(data['access_token']);
        return {
          'success': true,
          'accessToken': data['access_token'],
          'message': 'Student login successful',
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Invalid credentials',
        };
      }
    } catch (e) {
      return {'success': false, 'message': _mapNetworkError(e)};
    }
  }

  Future<Map<String, dynamic>> supervisorLogin({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/supervisor/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _storeToken(data['access_token']);
        
        final user = data['user'] as Map<String, dynamic>?;
        final String userId = user?['id'] ?? '';
        final bool isFirstLogin = user?['isFirstLogin'] ?? false;

        return {
          'success': true,
          'accessToken': data['access_token'],
          'userId': userId,
          'isFirstLogin': isFirstLogin,
          'message': 'Supervisor login successful',
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Invalid credentials',
        };
      }
    } catch (e) {
      return {'success': false, 'message': _mapNetworkError(e)};
    }
  }

  Future<Map<String, dynamic>> moduleLeaderLogin({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/module-leader/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _storeToken(data['access_token']);

        final user = data['user'] as Map<String, dynamic>?;
        final String userId = user?['id'] ?? '';

        return {
          'success': true,
          'accessToken': data['access_token'],
          'userId': userId,
          'message': 'Module Leader login successful',
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Invalid credentials',
        };
      }
    } catch (e) {
      return {'success': false, 'message': _mapNetworkError(e)};
    }
  }

  Future<Map<String, dynamic>> registerStudent({
    required String email,
    required String password,
    required String fullName,
    required String studentId,
    required String degree,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/users/register/student'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'fullName': fullName,
          'studentId': studentId,
          'degree': degree,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'user': data,
          'message': 'Registration successful',
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Registration failed',
        };
      }
    } catch (e) {
      return {'success': false, 'message': _mapNetworkError(e)};
    }
  }

  Future<void> _storeToken(String token) async {
    await _secureStorage.write(key: _tokenKey, value: token);
  }
  Future<String?> getToken() async {
    return await _secureStorage.read(key: _tokenKey);
  }

  Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> logout() async {
    await _secureStorage.deleteAll();
  }
  Future<Map<String, String>> getAuthHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
}
