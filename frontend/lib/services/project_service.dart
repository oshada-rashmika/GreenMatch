import 'dart:async';
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
    try {
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
    } catch (e) {
      throw ProjectServiceException(
        'Failed to parse project data from server. '
        'The response format may have changed.',
      );
    }
  }

}

class StudentIdentity {
  final String fullName;
  final String email;

  const StudentIdentity({required this.fullName, required this.email});

  factory StudentIdentity.fromJson(Map<String, dynamic> json) {
    return StudentIdentity(
      fullName: json['fullName'] as String,
      email: json['email'] as String,
    );
  }
}

class ProjectEvaluation {
  final int finalMark;
  final DateTime gradedAt;

  const ProjectEvaluation({required this.finalMark, required this.gradedAt});

  factory ProjectEvaluation.fromJson(Map<String, dynamic> json) {
    return ProjectEvaluation(
      finalMark: json['finalMark'] as int,
      gradedAt: DateTime.parse(json['gradedAt'] as String),
    );
  }
}

class SupervisedProject {
  final String id;
  final String title;
  final String abstract;
  final String status;
  final DateTime createdAt;
  final String groupId;
  final String groupName;
  final List<StudentIdentity> teamMembers;
  final List<String> tags;
  final ProjectEvaluation? evaluation;

  bool get isEvaluated => evaluation != null;

  const SupervisedProject({
    required this.id,
    required this.title,
    required this.abstract,
    required this.status,
    required this.createdAt,
    required this.groupId,
    required this.groupName,
    required this.teamMembers,
    required this.tags,
    this.evaluation,
  });

  factory SupervisedProject.fromJson(Map<String, dynamic> json) {
    try {
      final rawTags = json['tags'] as List<dynamic>? ?? [];
      final tagNames = rawTags
          .map((entry) => (entry['tag'] as Map<String, dynamic>?)?['name'] as String?)
          .whereType<String>()
          .toList();

      final group = json['group'] as Map<String, dynamic>? ?? {};
      final membersList = group['members'] as List<dynamic>? ?? [];
      final parsedMembers = membersList
          .map((m) => (m['student'] as Map<String, dynamic>?))
          .whereType<Map<String, dynamic>>()
          .map((s) => StudentIdentity.fromJson(s))
          .toList();

      return SupervisedProject(
        id: json['id'] as String,
        title: json['title'] as String,
        abstract: json['abstract'] as String,
        status: json['status'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        groupId: json['groupId'] as String,
        groupName: group['groupName'] as String? ?? 'Unknown Group',
        teamMembers: parsedMembers,
        tags: tagNames,
        evaluation: json['evaluation'] != null 
            ? ProjectEvaluation.fromJson(json['evaluation'] as Map<String, dynamic>) 
            : null,
      );
    } catch (e) {
      throw ProjectServiceException(
        'Failed to parse supervised project data: $e'
      );
    }
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
      return 'Cannot connect to the server. '
          'Please check your network and ensure the backend is running.';
    }
    if (error is TimeoutException) {
      return 'The server took too long to respond. Please try again.';
    }
    if (error is HandshakeException) {
      return 'Secure connection failed. Please check your server configuration.';
    }
    return 'An unexpected network error occurred: ${error.runtimeType}';
  }

  Future<List<AnonymousProject>> fetchAnonymousProjects() async {
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
                AnonymousProject.fromJson(item as Map<String, dynamic>))
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

  Future<List<SupervisedProject>> fetchMySupervisedProjects() async {
    try {
      final headers = await _authService.getAuthHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/projects/my-supervised'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> raw = jsonDecode(response.body) as List<dynamic>;
        return raw.map((item) => SupervisedProject.fromJson(item as Map<String, dynamic>)).toList();
      }

      if (response.statusCode == 401) {
        throw ProjectServiceException('Session expired. Please log in again.', statusCode: 401);
      }

      final body = _tryDecodeBody(response.body);
      final serverMessage = body?['message'] as String? ?? 'Unexpected error from server.';
      throw ProjectServiceException(serverMessage, statusCode: response.statusCode);
    } on ProjectServiceException {
      rethrow;
    } catch (e) {
      throw ProjectServiceException(_mapNetworkError(e));
    }
  }

  /// Fetch projects matched/assigned to a student (includes supervisor info)
  Future<List<Map<String, dynamic>>> getStudentProjects(String studentId) async {
    try {
      final headers = await _authService.getAuthHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/projects/student/$studentId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> raw = jsonDecode(response.body) as List<dynamic>;
        return raw.map((e) => e as Map<String, dynamic>).toList();
      }

      if (response.statusCode == 401) {
        throw ProjectServiceException('Session expired. Please log in again.', statusCode: 401);
      }

      final body = _tryDecodeBody(response.body);
      final serverMessage = body?['message'] as String? ?? 'Unexpected error from server.';
      throw ProjectServiceException(serverMessage, statusCode: response.statusCode);
    } on ProjectServiceException {
      rethrow;
    } catch (e) {
      throw ProjectServiceException(_mapNetworkError(e));
    }
  }

  Future<void> scheduleMeeting(String groupId, DateTime scheduledDate, DateTime windowExpiry) async {
    try {
      final headers = await _authService.getAuthHeaders();
      final response = await http.post(
        Uri.parse('$_baseUrl/meetings/schedule'),
        headers: headers,
        body: jsonEncode({
          'groupId': groupId,
          'scheduledDate': scheduledDate.toIso8601String(),
          'windowExpiry': windowExpiry.toIso8601String(),
          'notes': 'Scheduled via Supervisor Dashboard',
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) return;

      if (response.statusCode == 401) {
        throw ProjectServiceException('Session expired. Please log in again.', statusCode: 401);
      }

      final body = _tryDecodeBody(response.body);
      final serverMessage = body?['message'] as String? ?? 'Failed to schedule meeting.';
      throw ProjectServiceException(serverMessage, statusCode: response.statusCode);
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
