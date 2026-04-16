import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

/// Represents one anonymised project as returned by the backend.
/// Fields mirror the `getPendingAnonymousProjects` Prisma select block.
class AnonymousProject {
  final String id;
  final String title;
  final String abstract;
  final String status;
  final DateTime createdAt;

  /// Flat list of tag names extracted from the nested
  /// `tags[].tag.name` structure returned by the API.
  final List<String> tags;

  const AnonymousProject({
    required this.id,
    required this.title,
    required this.abstract,
    required this.status,
    required this.createdAt,
    required this.tags,
  });

  /// Deserialise a single project from the API JSON payload:
  /// ```json
  /// {
  ///   "id": "...",
  ///   "title": "...",
  ///   "abstract": "...",
  ///   "status": "PENDING",
  ///   "createdAt": "2026-04-16T...",
  ///   "tags": [{ "tag": { "id": "...", "name": "..." } }]
  /// }
  /// ```
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

  /// Convert to the `Map<String, dynamic>` shape that the dashboard
  /// widgets consume, keeping backward-compatible key names.
  Map<String, dynamic> toDisplayMap() {
    return {
      'id': id,
      'title': title,
      'abstract': abstract,
      'status': status,
      'createdAt': createdAt,
      // `techStack` is the key the card widgets read for badge rendering.
      'techStack': tags,
      // `researchArea` is derived from the first tag for filter chips.
      // Falls back to 'General' if the project has no tags.
      'researchArea': tags.isNotEmpty ? tags.first : 'General',
    };
  }
}

/// Thin HTTP client that wraps the `/projects` endpoints.
///
/// Requires [AuthService] to inject the Bearer token on every
/// authenticated request.
class ProjectService {
  final AuthService _authService;

  ProjectService({AuthService? authService})
      : _authService = authService ?? AuthService();

  // ── Base URL resolution (mirrors AuthService logic) ────────────────

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

  // ── Public API ──────────────────────────────────────────────────────

  /// Fetches the anonymised pending-project feed from `GET /projects/anonymous`.
  ///
  /// Returns a list of display maps ready for consumption by the dashboard.
  /// Throws a [ProjectServiceException] on HTTP errors or network failures.
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

  /// Sends `POST /projects/:id/match` with `{ confirmMatch: true }`.
  ///
  /// Throws a [ProjectServiceException] on failure.
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

  // ── Helpers ─────────────────────────────────────────────────────────

  Map<String, dynamic>? _tryDecodeBody(String body) {
    try {
      return jsonDecode(body) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }
}

/// Typed exception thrown by [ProjectService] methods.
class ProjectServiceException implements Exception {
  final String message;
  final int? statusCode;

  const ProjectServiceException(this.message, {this.statusCode});

  @override
  String toString() => 'ProjectServiceException($statusCode): $message';
}
