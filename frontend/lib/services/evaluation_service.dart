import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import 'project_service.dart';

class EvaluationService {
  final AuthService _authService;

  EvaluationService({AuthService? authService})
      : _authService = authService ?? AuthService();

  static const String _configuredBaseUrl = String.fromEnvironment('API_BASE_URL');

  String get _baseUrl {
    if (_configuredBaseUrl.isNotEmpty) return _configuredBaseUrl;
    if (kIsWeb) return 'http://localhost:3000';
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

  String _mapNetworkError(Object error) {
    if (error is SocketException) {
      return 'Cannot connect to the server. Please check your network and ensure the backend is running.';
    }
    if (error is TimeoutException) {
      return 'The server took too long to respond. Please try again.';
    }
    if (error is HandshakeException) {
      return 'Secure connection failed. Please check your server configuration.';
    }
    return 'An unexpected network error occurred: ${error.runtimeType}';
  }

  Map<String, dynamic>? _tryDecodeBody(String body) {
    try {
      return jsonDecode(body) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<List<SupervisedProject>> fetchEvaluatedProjects(String supervisorId) async {
    try {
      final headers = await _authService.getAuthHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/api/supervisors/$supervisorId/evaluated-projects'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> raw = jsonDecode(response.body) as List<dynamic>;
        return raw.map((item) => SupervisedProject.fromJson(item as Map<String, dynamic>)).toList();
      }

      if (response.statusCode == 401) {
        throw EvaluationServiceException('Session expired. Please log in again.', statusCode: 401);
      }

      final body = _tryDecodeBody(response.body);
      final serverMessage = body?['message'] as String? ?? 'Failed to load supervised projects.';
      throw EvaluationServiceException(serverMessage, statusCode: response.statusCode);
    } on EvaluationServiceException {
      rethrow;
    } catch (e) {
      throw EvaluationServiceException(_mapNetworkError(e));
    }
  }

  Future<void> submitEvaluation({
    required String projectId,
    required String supervisorId,
    required int finalMark,
    String? feedbackText,
    Map<String, dynamic>? criteriaScores,
  }) async {
    try {
      final headers = await _authService.getAuthHeaders();
      final response = await http.post(
        Uri.parse('$_baseUrl/api/evaluations'),
        headers: headers,
        body: jsonEncode({
          'projectId': projectId,
          'supervisorId': supervisorId,
          'finalMark': finalMark,
          if (feedbackText != null) 'feedbackText': feedbackText,
          if (criteriaScores != null) 'criteriaScores': criteriaScores,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return;
      }

      if (response.statusCode == 401) {
        throw EvaluationServiceException('Session expired. Please log in again.', statusCode: 401);
      }
      
      if (response.statusCode == 409) {
        throw EvaluationServiceException('This project has already been evaluated.', statusCode: 409);
      }

      final body = _tryDecodeBody(response.body);
      final serverMessage = body?['message'] as String? ?? 'Failed to submit evaluation.';
      throw EvaluationServiceException(serverMessage, statusCode: response.statusCode);
    } on EvaluationServiceException {
      rethrow;
    } catch (e) {
      throw EvaluationServiceException(_mapNetworkError(e));
    }
  }
}

class EvaluationServiceException implements Exception {
  final String message;
  final int? statusCode;

  const EvaluationServiceException(this.message, {this.statusCode});

  @override
  String toString() => 'EvaluationServiceException($statusCode): $message';
}
