import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ModuleLeaderService {
  static const String _configuredBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
  );

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

  Map<String, String> _headers(String jwtToken) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $jwtToken',
    };
  }

  String _mapNetworkError(Object error) {
    if (error is SocketException) {
      return 'Cannot reach backend at $_baseUrl.';
    }

    return 'Network error: ${error.toString()}';
  }

  Future<ModuleLeaderOverviewStatistics> fetchOverviewStatistics({
    required String jwtToken,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/module-leader/overview/statistics'),
        headers: _headers(jwtToken),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return ModuleLeaderOverviewStatistics.fromJson(
          decoded is Map<String, dynamic>
              ? decoded
              : <String, dynamic>{'data': decoded},
        );
      }

      throw Exception(
        'Failed to fetch overview statistics (${response.statusCode})',
      );
    } catch (error) {
      throw Exception(_mapNetworkError(error));
    }
  }

  Future<List<ModuleLeaderActionRequiredGroup>>
  fetchActionRequiredMissedGroups({required String jwtToken}) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/module-leader/overview/action-required?status=MISSED',
        ),
        headers: _headers(jwtToken),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final records = decoded is Map<String, dynamic>
            ? (decoded['data'] as List<dynamic>? ??
                  decoded['items'] as List<dynamic>? ??
                  const [])
            : decoded as List<dynamic>;

        return records
            .whereType<Map<String, dynamic>>()
            .map(ModuleLeaderActionRequiredGroup.fromJson)
            .toList();
      }

      throw Exception(
        'Failed to fetch action required meetings (${response.statusCode})',
      );
    } catch (error) {
      throw Exception(_mapNetworkError(error));
    }
  }

  Future<List<ModuleLeaderTag>> fetchTags({required String jwtToken}) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/tags'),
        headers: _headers(jwtToken),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final records = decoded is Map<String, dynamic>
            ? (decoded['data'] as List<dynamic>? ??
                  decoded['items'] as List<dynamic>? ??
                  decoded['tags'] as List<dynamic>? ??
                  const [])
            : decoded as List<dynamic>;

        return records
            .whereType<Map<String, dynamic>>()
            .map(ModuleLeaderTag.fromJson)
            .toList();
      }

      throw Exception('Failed to fetch tags (${response.statusCode})');
    } catch (error) {
      throw Exception(_mapNetworkError(error));
    }
  }

  Future<ModuleLeaderTag> createTag({
    required String jwtToken,
    required String name,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/tags'),
        headers: _headers(jwtToken),
        body: jsonEncode({'name': name}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        final tagJson = decoded is Map<String, dynamic>
            ? (decoded['data'] is Map<String, dynamic>
                  ? decoded['data'] as Map<String, dynamic>
                  : decoded)
            : <String, dynamic>{'name': name};

        return ModuleLeaderTag.fromJson(tagJson);
      }

      final decoded = jsonDecode(response.body);
      final message = decoded is Map<String, dynamic>
          ? (decoded['message']?.toString() ?? 'Failed to create tag')
          : 'Failed to create tag';
      throw Exception(message);
    } catch (error) {
      throw Exception(_mapNetworkError(error));
    }
  }
}

class ModuleLeaderOverviewStatistics {
  const ModuleLeaderOverviewStatistics({
    required this.totalProjects,
    required this.pendingBlindMatches,
    required this.ghostedMissedMeetings,
  });

  factory ModuleLeaderOverviewStatistics.fromJson(Map<String, dynamic> json) {
    return ModuleLeaderOverviewStatistics(
      totalProjects: _parseInt(
        json['totalProjects'] ?? json['total_projects'] ?? json['projectCount'],
        fallback: 0,
      ),
      pendingBlindMatches: _parseInt(
        json['pendingBlindMatches'] ??
            json['pending_blind_matches'] ??
            json['pendingMatches'],
        fallback: 0,
      ),
      ghostedMissedMeetings: _parseInt(
        json['ghostedMissedMeetings'] ??
            json['ghosted_missed_meetings'] ??
            json['missedMeetings'] ??
            json['missed_meeting_count'],
        fallback: 0,
      ),
    );
  }

  final int totalProjects;
  final int pendingBlindMatches;
  final int ghostedMissedMeetings;
}

class ModuleLeaderActionRequiredGroup {
  const ModuleLeaderActionRequiredGroup({
    required this.groupId,
    required this.groupName,
    required this.projectTitle,
    required this.meetingStatus,
    required this.meetingDate,
    required this.supervisorName,
  });

  factory ModuleLeaderActionRequiredGroup.fromJson(Map<String, dynamic> json) {
    return ModuleLeaderActionRequiredGroup(
      groupId: (json['groupId'] ?? json['group_id'] ?? json['id'] ?? '')
          .toString(),
      groupName: (json['groupName'] ?? json['group_name'])?.toString(),
      projectTitle: (json['projectTitle'] ?? json['project_title'] ?? '')
          .toString(),
      meetingStatus: (json['meetingStatus'] ?? json['status'] ?? 'MISSED')
          .toString(),
      meetingDate: _parseDate(
        json['meetingDate'] ??
            json['meeting_date'] ??
            json['scheduledDate'] ??
            json['scheduled_date'],
      ),
      supervisorName: (json['supervisorName'] ?? json['supervisor_name'])
          ?.toString(),
    );
  }

  final String groupId;
  final String? groupName;
  final String projectTitle;
  final String meetingStatus;
  final DateTime? meetingDate;
  final String? supervisorName;
}

class ModuleLeaderTag {
  const ModuleLeaderTag({required this.id, required this.name});

  factory ModuleLeaderTag.fromJson(Map<String, dynamic> json) {
    return ModuleLeaderTag(
      id: (json['id'] ?? json['tagId'] ?? json['tag_id'] ?? '').toString(),
      name: (json['name'] ?? json['tagName'] ?? json['tag_name'] ?? '')
          .toString(),
    );
  }

  final String id;
  final String name;
}

int _parseInt(Object? value, {required int fallback}) {
  if (value is int) return value;
  if (value is double) return value.round();
  if (value is String) return int.tryParse(value) ?? fallback;
  return fallback;
}

DateTime? _parseDate(Object? value) {
  if (value is DateTime) return value;
  if (value is String) {
    return DateTime.tryParse(value);
  }
  return null;
}
