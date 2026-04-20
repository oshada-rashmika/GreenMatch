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

  Future<List<ModuleLeaderProject>> fetchAllProjects({
    required String jwtToken,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/projects/module-leader/all'),
        headers: _headers(jwtToken),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final records = decoded is Map<String, dynamic>
            ? (decoded['data'] as List<dynamic>? ??
                  decoded['items'] as List<dynamic>? ??
                  decoded['projects'] as List<dynamic>? ??
                  const [])
            : decoded as List<dynamic>;

        return records
            .whereType<Map<String, dynamic>>()
            .map(ModuleLeaderProject.fromJson)
            .toList();
      }

      throw Exception('Failed to fetch projects (${response.statusCode})');
    } catch (error) {
      throw Exception(_mapNetworkError(error));
    }
  }

  Future<ModuleLeaderAcademicModulesPayload> fetchAcademicModules({
    required String jwtToken,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/modules'),
        headers: _headers(jwtToken),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        if (decoded is Map<String, dynamic>) {
          return ModuleLeaderAcademicModulesPayload.fromJson(decoded);
        }

        return ModuleLeaderAcademicModulesPayload(
          modules: const [],
          supervisors: const [],
        );
      }

      throw Exception(
        'Failed to fetch academic modules (${response.statusCode})',
      );
    } catch (error) {
      throw Exception(_mapNetworkError(error));
    }
  }

  Future<ModuleLeaderAcademicModule> createAcademicModule({
    required String jwtToken,
    required String moduleCode,
    required String moduleName,
    required String academicYear,
    required String batch,
    DateTime? milestoneMatchDate,
    DateTime? milestoneReviewDate,
    DateTime? milestoneMidtermDate,
    DateTime? milestoneFinalDate,
    DateTime? milestoneVivaDate,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/modules'),
        headers: _headers(jwtToken),
        body: jsonEncode({
          'moduleCode': moduleCode,
          'moduleName': moduleName,
          'academicYear': academicYear,
          'batch': batch,
          if (milestoneMatchDate != null) 'milestoneMatchDate': milestoneMatchDate.toIso8601String(),
          if (milestoneReviewDate != null) 'milestoneReviewDate': milestoneReviewDate.toIso8601String(),
          if (milestoneMidtermDate != null) 'milestoneMidtermDate': milestoneMidtermDate.toIso8601String(),
          if (milestoneFinalDate != null) 'milestoneFinalDate': milestoneFinalDate.toIso8601String(),
          if (milestoneVivaDate != null) 'milestoneVivaDate': milestoneVivaDate.toIso8601String(),
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          return ModuleLeaderAcademicModule.fromJson(decoded);
        }
      }

      throw Exception('Failed to create module (${response.statusCode})');
    } catch (error) {
      throw Exception(_mapNetworkError(error));
    }
  }

  Future<int> runAutoMatchAlgorithm({
    required String jwtToken,
  }) async {
    // Simulates the algorithmic taxonomy matching delay taking approx 2.5s.
    // In a production backend, this would hit something like:
    // POST /module-leader/auto-match
    await Future.delayed(const Duration(milliseconds: 2500));
    
    // Simulating that the algorithm successfully paired 2 projects.
    return 2;
  }

  Future<ModuleLeaderAcademicModule> assignSupervisorsToModule({
    required String jwtToken,
    required String moduleId,
    required List<String> supervisorIds,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/modules/$moduleId/supervisors'),
        headers: _headers(jwtToken),
        body: jsonEncode({'supervisorIds': supervisorIds}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          return ModuleLeaderAcademicModule.fromJson(decoded);
        }
      }

      throw Exception(
        'Failed to assign supervisors (${response.statusCode})',
      );
    } catch (error) {
      throw Exception(_mapNetworkError(error));
    }
  }

  Future<ModuleLeaderProfile> fetchProfile({
    required String jwtToken,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/module-leader/profile'),
        headers: _headers(jwtToken),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return ModuleLeaderProfile.fromJson(decoded);
      }

      throw Exception('Failed to fetch profile (${response.statusCode})');
    } catch (error) {
      throw Exception(_mapNetworkError(error));
    }
  }

  Future<Map<String, dynamic>> updateProfile({
    required String jwtToken,
    String? fullName,
    String? staffId,
  }) async {
    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/module-leader/profile'),
        headers: _headers(jwtToken),
        body: jsonEncode({
          if (fullName != null) 'fullName': fullName,
          if (staffId != null) 'staffId': staffId,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': 'Profile updated successfully',
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Failed to update profile',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': _mapNetworkError(e),
      };
    }
  }
}

class ModuleLeaderProfile {
  const ModuleLeaderProfile({
    required this.id,
    required this.staffId,
    required this.email,
    required this.fullName,
    required this.ledModules,
  });

  factory ModuleLeaderProfile.fromJson(Map<String, dynamic> json) {
    final rawModules = json['ledModules'];
    final ledModules = rawModules is List<dynamic>
        ? rawModules
            .whereType<Map<String, dynamic>>()
            .map(ModuleLeaderAcademicModule.fromJson)
            .toList()
        : <ModuleLeaderAcademicModule>[];

    return ModuleLeaderProfile(
      id: (json['id'] ?? '').toString(),
      staffId: (json['staffId'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      fullName: (json['fullName'] ?? '').toString(),
      ledModules: ledModules,
    );
  }

  final String id;
  final String staffId;
  final String email;
  final String fullName;
  final List<ModuleLeaderAcademicModule> ledModules;
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

class ModuleLeaderProject {
  const ModuleLeaderProject({
    required this.id,
    required this.title,
    required this.status,
    required this.moduleCode,
    required this.moduleName,
    required this.supervisorName,
    required this.groupName,
  });

  factory ModuleLeaderProject.fromJson(Map<String, dynamic> json) {
    final supervisor = json['supervisor'];
    final module = json['module'];
    final group = json['group'];

    return ModuleLeaderProject(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      status: (json['status'] ?? 'PENDING').toString(),
      moduleCode:
          (module is Map<String, dynamic>
                  ? module['moduleCode']
                  : json['moduleCode'] ??
                        json['module_code'] ??
                        json['module'] ??
                        '')
              .toString(),
      moduleName:
          (module is Map<String, dynamic>
                  ? module['moduleName']
                  : json['moduleName'] ?? json['module_name'] ?? '')
              .toString(),
      supervisorName: supervisor is Map<String, dynamic>
          ? supervisor['fullName']?.toString()
          : json['supervisorName']?.toString(),
      groupName: group is Map<String, dynamic>
          ? group['groupName']?.toString()
          : json['groupName']?.toString(),
    );
  }

  final String id;
  final String title;
  final String status;
  final String moduleCode;
  final String moduleName;
  final String? supervisorName;
  final String? groupName;

  bool get isMatched => status.toUpperCase() == 'MATCHED';
  bool get isPending => status.toUpperCase() == 'PENDING';
}

class ModuleLeaderAcademicModulesPayload {
  const ModuleLeaderAcademicModulesPayload({
    required this.modules,
    required this.supervisors,
  });

  factory ModuleLeaderAcademicModulesPayload.fromJson(
    Map<String, dynamic> json,
  ) {
    final rawModules = json['modules'];
    final rawSupervisors = json['supervisors'];

    final modules = rawModules is List<dynamic>
        ? rawModules
            .whereType<Map<String, dynamic>>()
            .map(ModuleLeaderAcademicModule.fromJson)
            .toList()
        : <ModuleLeaderAcademicModule>[];

    final supervisors = rawSupervisors is List<dynamic>
        ? rawSupervisors
            .whereType<Map<String, dynamic>>()
            .map(ModuleLeaderSupervisor.fromJson)
            .toList()
        : <ModuleLeaderSupervisor>[];

    return ModuleLeaderAcademicModulesPayload(
      modules: modules,
      supervisors: supervisors,
    );
  }

  final List<ModuleLeaderAcademicModule> modules;
  final List<ModuleLeaderSupervisor> supervisors;
}

class ModuleLeaderAcademicModule {
  const ModuleLeaderAcademicModule({
    required this.id,
    required this.moduleCode,
    required this.moduleName,
    required this.academicYear,
    required this.batch,
    required this.assignedSupervisors,
  });

  factory ModuleLeaderAcademicModule.fromJson(Map<String, dynamic> json) {
    final rawSupervisors = json['supervisors'];
    final assignedSupervisors = rawSupervisors is List<dynamic>
        ? rawSupervisors
            .whereType<Map<String, dynamic>>()
            .map((item) {
              final supervisorMap = item['supervisor'];
              if (supervisorMap is Map<String, dynamic>) {
                return ModuleLeaderSupervisor.fromJson(supervisorMap);
              }
              return ModuleLeaderSupervisor.fromJson(item);
            })
            .toList()
        : <ModuleLeaderSupervisor>[];

    return ModuleLeaderAcademicModule(
      id: (json['id'] ?? '').toString(),
      moduleCode: (json['moduleCode'] ?? '').toString(),
      moduleName: (json['moduleName'] ?? '').toString(),
      academicYear: (json['academicYear'] ?? '').toString(),
      batch: (json['batch'] ?? '').toString(),
      assignedSupervisors: assignedSupervisors,
    );
  }

  final String id;
  final String moduleCode;
  final String moduleName;
  final String academicYear;
  final String batch;
  final List<ModuleLeaderSupervisor> assignedSupervisors;
}

class ModuleLeaderSupervisor {
  const ModuleLeaderSupervisor({
    required this.id,
    required this.fullName,
    required this.email,
    this.staffId,
  });

  factory ModuleLeaderSupervisor.fromJson(Map<String, dynamic> json) {
    return ModuleLeaderSupervisor(
      id: (json['id'] ?? '').toString(),
      fullName: (json['fullName'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      staffId: json['staffId']?.toString(),
    );
  }

  final String id;
  final String fullName;
  final String email;
  final String? staffId;
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
