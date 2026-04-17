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

class MyProposalData {
  final String id;
  final String title;
  final String abstractText;
  final String status;
  final String moduleName;
  final List<String> tags;
  final String? supervisorName;
  final String? supervisorEmail;

  MyProposalData({
    required this.id,
    required this.title,
    required this.abstractText,
    required this.status,
    required this.moduleName,
    required this.tags,
    this.supervisorName,
    this.supervisorEmail,
  });

  factory MyProposalData.fromJson(Map<String, dynamic> json) {
    var rawTags = json['tags'] as List? ?? [];
    return MyProposalData(
      id: json['id'],
      title: json['title'],
      abstractText: json['abstract'],
      status: json['status'],
      moduleName: json['module']['moduleName'],
      tags: rawTags.map((t) => t['tag']['name'] as String).toList(),
      supervisorName: json['supervisor']?['fullName'],
      supervisorEmail: json['supervisor']?['email'],
    );
  }
}

class MeetingData {
  final String id;
  final DateTime scheduledDate;
  final DateTime windowExpiry;
  final String status;
  final String? supervisorNotes;
  final String supervisorName;

  MeetingData({
    required this.id,
    required this.scheduledDate,
    required this.windowExpiry,
    required this.status,
    this.supervisorNotes,
    required this.supervisorName,
  });

  factory MeetingData.fromJson(Map<String, dynamic> json) {
    return MeetingData(
      id: json['id'],
      scheduledDate: DateTime.parse(json['scheduledDate']).toLocal(),
      windowExpiry: DateTime.parse(json['windowExpiry']).toLocal(),
      status: json['status'],
      supervisorNotes: json['supervisorNotes'],
      supervisorName: json['supervisor']['fullName'],
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
        if (groupName != null) 'groupName': groupName,
        if (tagIds != null) 'tagIds': tagIds,
        if (memberStudentIds != null) 'memberStudentIds': memberStudentIds,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to submit proposal: ${response.body}');
    }
  }

  Future<MyProposalData?> fetchMyProposal() async {
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
        final Map<String, dynamic> data = jsonDecode(response.body);
        return MyProposalData.fromJson(data);
      }
      return null;
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Failed to fetch proposal: ${response.body}');
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
