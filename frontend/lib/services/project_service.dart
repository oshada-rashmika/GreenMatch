import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class AnonymousProject {
  final String id;
  final String title;
  final String abstract;
  final String status;
  final DateTime createdAt;

  final List<String> tags;

  const AnonymousProject({
    required this.id,
    required this.title,
    required this.abstract,
    required this.status,
    required this.createdAt,
    required this.tags,
  });

  factory AnonymousProject.fromJson(Map<String, dynamic> json) {
    final rawTags = json['tags'] as List<dynamic>? ?? [];
    final tagNames = rawTags
        .map((entry) {
          final tagObj = entry['tag'] as Map<String, dynamic>?;
          return tagObj?['name'] as String?;
        })
        .whereType<String>()
        .toList();

    return AnonymousProject(
      id: json['id'] as String,
      title: json['title'] as String,
      abstract: json['abstract'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      tags: tagNames,
    );
  }

  Map<String, dynamic> toDisplayMap() {
    return {
      'id': id,
      'title': title,
      'abstract': abstract,
      'status': status,
      'createdAt': createdAt,
      'techStack': tags,
      'researchArea': tags.isNotEmpty ? tags.first : 'General',
    };
  }
}

class ProjectService {
  final AuthService _authService;

  ProjectService({AuthService? authService})
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

  String _mapNetworkError(Object error) {
    if (error is SocketException) {
      return 'Cannot reach backend at $_baseUrl. '
          'Ensure NestJS is running on port 3000.';
    }
    return 'Network error: ${error.toString()}';
  }

  Future<List<Map<String, dynamic>>> fetchAnonymousProjects() async {
    try {
      final headers = await _authService.getAuthHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/projects/anonymous'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> raw = jsonDecode(response.body) as List<dynamic>;
        return raw
            .map((item) =>
                AnonymousProject.fromJson(item as Map<String, dynamic>)
                    .toDisplayMap())
            .toList();
      }

      if (response.statusCode == 401) {
        throw ProjectServiceException(
          'Session expired. Please log in again.',
          statusCode: 401,
        );
      }

      final body = _tryDecodeBody(response.body);
      final serverMessage =
          body?['message'] as String? ?? 'Unexpected error from server.';
      throw ProjectServiceException(
        serverMessage,
        statusCode: response.statusCode,
      );
    } on ProjectServiceException {
      rethrow;
    } catch (e) {
      throw ProjectServiceException(_mapNetworkError(e));
    }
  }

  Future<void> confirmMatch(String projectId) async {
    try {
      final headers = await _authService.getAuthHeaders();
      final response = await http.post(
        Uri.parse('$_baseUrl/projects/$projectId/match'),
        headers: headers,
        body: jsonEncode({'confirmMatch': true}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) return;

      if (response.statusCode == 401) {
        throw ProjectServiceException(
          'Session expired. Please log in again.',
          statusCode: 401,
        );
      }

      final body = _tryDecodeBody(response.body);
      final serverMessage =
          body?['message'] as String? ?? 'Failed to confirm match.';
      throw ProjectServiceException(
        serverMessage,
        statusCode: response.statusCode,
      );
    } on ProjectServiceException {
      rethrow;
    } catch (e) {
      throw ProjectServiceException(_mapNetworkError(e));
    }
  }

  Map<String, dynamic>? _tryDecodeBody(String body) {
    try {
      return jsonDecode(body) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }
}

class ProjectServiceException implements Exception {
  final String message;
  final int? statusCode;

  const ProjectServiceException(this.message, {this.statusCode});

  @override
  String toString() => 'ProjectServiceException($statusCode): $message';
}
