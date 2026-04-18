import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class MeetingMark {
  final String id;
  final int meetingNumber;
  final DateTime scheduledDate;
  final String status;
  final String? notes;
  final DateTime createdAt;

  const MeetingMark({
    required this.id,
    required this.meetingNumber,
    required this.scheduledDate,
    required this.status,
    this.notes,
    required this.createdAt,
  });

  factory MeetingMark.fromJson(Map<String, dynamic> json) {
    return MeetingMark(
      id: json['id'] as String,
      meetingNumber: json['meetingNumber'] as int,
      scheduledDate: DateTime.parse(json['scheduledDate'] as String),
      status: json['status'] as String,
      notes: json['supervisorNotes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class MeetingService {
  final AuthService _authService = AuthService();

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

  /// Fetch all marked meeting days for a project group
  Future<List<MeetingMark>> getProjectMeetingMarks(String groupId) async {
    final headers = await _authService.getAuthHeaders();
    final response = await http.get(
      Uri.parse('$_baseUrl/meetings/marks/$groupId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> raw = jsonDecode(response.body) as List<dynamic>;
      return raw
          .map((item) => MeetingMark.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    throw Exception('Failed to fetch meeting marks: ${response.statusCode}');
  }

  /// Mark a meeting day number for a project group
  Future<MeetingMark> markMeetingDay({
    required String groupId,
    required int meetingNumber,
    required DateTime meetingDate,
    String? notes,
  }) async {
    final headers = await _authService.getAuthHeaders();
    final response = await http.post(
      Uri.parse('$_baseUrl/meetings/marks/$groupId'),
      headers: headers,
      body: jsonEncode({
        'meetingNumber': meetingNumber,
        'meetingDate': meetingDate.toIso8601String(),
        'notes': notes,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return MeetingMark.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }

    throw Exception('Failed to mark meeting day: ${response.statusCode}');
  }

  /// Unmark a meeting day
  Future<void> unmarkMeetingDay({
    required String groupId,
    required int meetingNumber,
  }) async {
    final headers = await _authService.getAuthHeaders();
    final response = await http.delete(
      Uri.parse('$_baseUrl/meetings/marks/$groupId/$meetingNumber'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to unmark meeting day: ${response.statusCode}');
    }
  }
}
