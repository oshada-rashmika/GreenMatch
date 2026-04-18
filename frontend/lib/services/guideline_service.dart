import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/guideline.dart';
import 'auth_service.dart';

class GuidelineService {
  final AuthService _authService;

  GuidelineService({AuthService? authService})
    : _authService = authService ?? AuthService();

  static const String _configuredBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
  );

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

  Future<List<Guideline>> fetchGuidelinesForLeader(String leaderId) async {
    if (leaderId.trim().isEmpty) {
      throw const GuidelineServiceException(
        'Unable to load guidelines: leader ID is missing. Please log in again.',
      );
    }

    try {
      final headers = await _authService.getAuthHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/api/module-leaders/$leaderId/guidelines'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final raw = jsonDecode(response.body);
        if (raw is! List) {
          throw const GuidelineServiceException(
            'Unexpected server response while loading guidelines.',
          );
        }

        return raw
            .whereType<Map<String, dynamic>>()
            .map(Guideline.fromJson)
            .toList();
      }

      throw GuidelineServiceException(
        _messageFromHttp(
          response,
          fallback: 'Unable to load guidelines at the moment.',
        ),
        statusCode: response.statusCode,
      );
    } on GuidelineServiceException {
      rethrow;
    } on FormatException {
      throw const GuidelineServiceException(
        'Received invalid data from the server. Please try again shortly.',
      );
    } catch (error) {
      throw GuidelineServiceException(_mapNetworkError(error));
    }
  }

  Future<Guideline> createGuideline(Map<String, dynamic> data) async {
    try {
      final headers = await _authService.getAuthHeaders();
      final response = await http.post(
        Uri.parse('$_baseUrl/api/guidelines'),
        headers: headers,
        body: jsonEncode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final raw = jsonDecode(response.body);
        if (raw is! Map<String, dynamic>) {
          throw const GuidelineServiceException(
            'Unexpected server response while creating the guideline.',
          );
        }
        return Guideline.fromJson(raw);
      }

      throw GuidelineServiceException(
        _messageFromHttp(
          response,
          fallback:
              'Unable to create guideline. Please review the form and retry.',
        ),
        statusCode: response.statusCode,
      );
    } on GuidelineServiceException {
      rethrow;
    } on FormatException {
      throw const GuidelineServiceException(
        'The server returned invalid data after creating the guideline.',
      );
    } catch (error) {
      throw GuidelineServiceException(_mapNetworkError(error));
    }
  }

  String _mapNetworkError(Object error) {
    if (error is SocketException) {
      return 'Cannot connect to the server. Check your internet connection and ensure backend is running.';
    }

    if (error is TimeoutException) {
      return 'Request timed out. Please try again in a moment.';
    }

    if (error is HandshakeException) {
      return 'Secure connection failed. Please verify SSL/server configuration.';
    }

    return 'Unexpected error occurred: ${error.runtimeType}';
  }

  String _messageFromHttp(http.Response response, {required String fallback}) {
    final decoded = _tryDecodeBody(response.body);
    final dynamic messageField = decoded?['message'];
    String serverMessage = fallback;

    if (messageField is String && messageField.trim().isNotEmpty) {
      serverMessage = messageField;
    } else if (messageField is List) {
      final combined = messageField
          .map((entry) => entry.toString().trim())
          .where((entry) => entry.isNotEmpty)
          .join(', ');
      if (combined.isNotEmpty) {
        serverMessage = combined;
      }
    }

    if (response.statusCode == 400) {
      return 'Invalid guideline data: $serverMessage';
    }
    if (response.statusCode == 401) {
      return 'Session expired. Please log in again.';
    }
    if (response.statusCode == 403) {
      return 'You do not have permission to manage guidelines.';
    }
    if (response.statusCode == 404) {
      return 'Related module or endpoint was not found. Please refresh and retry.';
    }
    if (response.statusCode >= 500) {
      return 'Server error while processing guidelines. Please try again later.';
    }

    return serverMessage;
  }

  Map<String, dynamic>? _tryDecodeBody(String body) {
    try {
      return jsonDecode(body) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }
}

class GuidelineServiceException implements Exception {
  final String message;
  final int? statusCode;

  const GuidelineServiceException(this.message, {this.statusCode});

  @override
  String toString() => 'GuidelineServiceException($statusCode): $message';
}
