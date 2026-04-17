import 'dart:convert';
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

class StudentService {
  final String baseUrl;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  StudentService({this.baseUrl = 'http://127.0.0.1:3000'}); // Match AuthProvider baseUrl

  Future<String?> _getToken() async {
    return await _storage.read(key: 'jwt');
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
}
