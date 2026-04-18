import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ModuleData {
  final String id;
  final String moduleCode;
  final String moduleName;

  ModuleData({required this.id, required this.moduleCode, required this.moduleName});

  factory ModuleData.fromJson(Map<String, dynamic> json) {
    return ModuleData(
      id: json['id'],
      moduleCode: json['moduleCode'],
      moduleName: json['moduleName'],
    );
  }
}

class TagData {
  final String id;
  final String name;

  TagData({required this.id, required this.name});

  factory TagData.fromJson(Map<String, dynamic> json) {
    return TagData(
      id: json['id'],
      name: json['name'],
    );
  }
}

class MemberData {
  final String studentId;
  final String fullName;
  final String degree;
  final bool isLeader;

  MemberData({required this.studentId, required this.fullName, required this.degree, required this.isLeader});

  factory MemberData.fromJson(Map<String, dynamic> json) {
    return MemberData(
      studentId: json['student']['studentId'] ?? '',
      fullName: json['student']['fullName'] ?? '',
      degree: json['student']['degree'] ?? '',
      isLeader: json['isLeader'] ?? false,
    );
  }
}

class MyProposalData {
  final String id;
  final String title;
  final String abstractText;
  final String status;
  final String moduleName;
  final List<String> tags;
  final List<MemberData> members;
  final String? supervisorName;
  final String? supervisorEmail;
  final DateTime? milestoneMatchDate;
  final DateTime? milestoneReviewDate;
  final DateTime? milestoneMidtermDate;
  final DateTime? milestoneFinalDate;
  final DateTime? milestoneVivaDate;
  final DateTime? createdAt;

  MyProposalData({
    required this.id,
    required this.title,
    required this.abstractText,
    required this.status,
    required this.moduleName,
    required this.tags,
    required this.members,
    this.supervisorName,
    this.supervisorEmail,
    this.milestoneMatchDate,
    this.milestoneReviewDate,
    this.milestoneMidtermDate,
    this.milestoneFinalDate,
    this.milestoneVivaDate,
    this.createdAt,
  });

  factory MyProposalData.fromJson(Map<String, dynamic> json) {
    var rawTags = json['tags'] as List? ?? [];
    var rawMembers = json['group']?['members'] as List? ?? [];
    final moduleMap = json['module'] ?? <String, dynamic>{};
    return MyProposalData(
      id: json['id'],
      title: json['title'],
      abstractText: json['abstract'],
      status: json['status'],
      moduleName: moduleMap['moduleName'],
      milestoneMatchDate: moduleMap['milestoneMatchDate'] != null ? DateTime.tryParse(moduleMap['milestoneMatchDate'])?.toLocal() : null,
      milestoneReviewDate: moduleMap['milestoneReviewDate'] != null ? DateTime.tryParse(moduleMap['milestoneReviewDate'])?.toLocal() : null,
      milestoneMidtermDate: moduleMap['milestoneMidtermDate'] != null ? DateTime.tryParse(moduleMap['milestoneMidtermDate'])?.toLocal() : null,
      milestoneFinalDate: moduleMap['milestoneFinalDate'] != null ? DateTime.tryParse(moduleMap['milestoneFinalDate'])?.toLocal() : null,
      milestoneVivaDate: moduleMap['milestoneVivaDate'] != null ? DateTime.tryParse(moduleMap['milestoneVivaDate'])?.toLocal() : null,
      tags: rawTags.map((t) => t['tag']['name'] as String).toList(),
      members: rawMembers.map((m) => MemberData.fromJson(m)).toList(),
      supervisorName: json['supervisor']?['fullName'],
      supervisorEmail: json['supervisor']?['email'],
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'])?.toLocal() : null,
    );
  }
}

class MeetingData {
  final String id;
  final String projectId;
  final DateTime scheduledDate;
  final DateTime windowExpiry;
  final String status;
  final String? supervisorNotes;
  final String supervisorName;

  MeetingData({
    required this.id,
    required this.projectId,
    required this.scheduledDate,
    required this.windowExpiry,
    required this.status,
    this.supervisorNotes,
    required this.supervisorName,
  });

  factory MeetingData.fromJson(Map<String, dynamic> json) {
    return MeetingData(
      id: json['id'],
      projectId: json['groupId'],
      scheduledDate: DateTime.parse(json['scheduledDate']).toLocal(),
      windowExpiry: DateTime.parse(json['windowExpiry']).toLocal(),
      status: json['status'],
      supervisorNotes: json['supervisorNotes'],
      supervisorName: json['supervisor']?['fullName'] ?? 'Unknown Supervisor',
    );
  }
}

class StudentService {
  static const String _configuredBaseUrl = String.fromEnvironment('API_BASE_URL');

  String get baseUrl {
    if (_configuredBaseUrl.isNotEmpty) return _configuredBaseUrl;
    if (kIsWeb) return 'http://localhost:3000';
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2:3000';
      default:
        return 'http://localhost:3000';
    }
  }

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  StudentService();

  Future<String?> _getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  Future<List<ModuleData>> fetchModules() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/modules/all'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => ModuleData.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch modules: ${response.body}');
    }
  }

  Future<List<TagData>> fetchTags() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/tags'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => TagData.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch tags: ${response.body}');
    }
  }

  Future<void> submitProposal({
    required String title,
    required String abstractText,
    required String moduleId,
    String? groupName,
    List<String>? tagIds,
    List<String>? memberStudentIds,
  }) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/projects/submit'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'title': title,
        'abstract': abstractText,
        'moduleId': moduleId,
        'groupName': ?groupName,
        'tagIds': ?tagIds,
        'memberStudentIds': ?memberStudentIds,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to submit proposal: ${response.body}');
    }
  }

  Future<List<MyProposalData>> fetchMyProposals() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/projects/my-proposal'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      if (response.body.isNotEmpty) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => MyProposalData.fromJson(json)).toList();
      }
      return [];
    } else if (response.statusCode == 404) {
      return [];
    } else {
      throw Exception('Failed to fetch proposals: ${response.body}');
    }
  }

  Future<List<MeetingData>> fetchMyMeetings() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/meetings/my-meetings'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => MeetingData.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch meetings: ${response.body}');
    }
  }

  Future<void> attendMeeting(String meetingId) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/meetings/$meetingId/attend'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to attend meeting: ${response.body}');
    }
  }
}
