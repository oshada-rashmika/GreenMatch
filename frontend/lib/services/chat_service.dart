import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/chat_message.dart';

class ChatService {
  static const String _baseUrl = 'http://10.0.2.3:3000/api';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Get all messages for a project
  Future<List<ChatMessage>> getProjectMessages(String projectId) async {
    try {
      if (projectId.isEmpty) {
        throw Exception('Project ID cannot be empty');
      }

      final token = await _storage.read(key: 'auth_token');
      if (token == null) {
        throw Exception('Authentication token not found. Please login again.');
      }

      final response = await http
          .get(
            Uri.parse('$_baseUrl/messages/project/$projectId'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () =>
                throw Exception('Request timeout. Please try again.'),
          );

      if (response.statusCode == 401) {
        throw Exception('Session expired. Please login again.');
      }

      if (response.statusCode == 404) {
        throw Exception('Project not found or no messages yet.');
      }

      if (response.statusCode != 200) {
        print('❌ Error Response: ${response.statusCode}');
        print('Response: ${response.body}');
        throw Exception('Failed to load messages: ${response.statusCode}');
      }

      print('✅ Messages fetched successfully');
      print('Response: ${response.body}');

      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => ChatMessage.fromJson(json)).toList();
    } catch (e) {
      print('❌ Error fetching messages: $e');
      rethrow;
    }
  }

  // Send a new message
  Future<ChatMessage> sendMessage({
    required String projectId,
    required String content,
    required String senderType, // 'STUDENT' or 'SUPERVISOR'
    required String senderId,
    required String senderName,
  }) async {
    try {
      if (projectId.isEmpty || content.isEmpty) {
        throw Exception('Project ID and message content cannot be empty');
      }

      final token = await _storage.read(key: 'auth_token');
      if (token == null) {
        throw Exception('Authentication token not found. Please login again.');
      }

      final messageData = {
        'projectId': projectId,
        'content': content,
        'senderType': senderType,
        'senderId': senderId,
        'senderName': senderName,
      };

      final response = await http
          .post(
            Uri.parse('$_baseUrl/messages'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(messageData),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () =>
                throw Exception('Request timeout. Please try again.'),
          );

      if (response.statusCode == 401) {
        throw Exception('Session expired. Please login again.');
      }

      if (response.statusCode == 404) {
        throw Exception('Project not found.');
      }

      if (response.statusCode != 201 && response.statusCode != 200) {
        print('❌ Error Response: ${response.statusCode}');
        print('Response: ${response.body}');
        throw Exception('Failed to send message: ${response.statusCode}');
      }

      print('✅ Message sent successfully');
      print('Response: ${response.body}');

      final jsonResponse = jsonDecode(response.body);
      return ChatMessage.fromJson(jsonResponse);
    } catch (e) {
      print('❌ Error sending message: $e');
      rethrow;
    }
  }

  // Delete a message
  Future<void> deleteMessage(String messageId) async {
    try {
      if (messageId.isEmpty) {
        throw Exception('Message ID cannot be empty');
      }

      final token = await _storage.read(key: 'auth_token');
      if (token == null) {
        throw Exception('Authentication token not found. Please login again.');
      }

      final response = await http
          .delete(
            Uri.parse('$_baseUrl/messages/$messageId'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () =>
                throw Exception('Request timeout. Please try again.'),
          );

      if (response.statusCode == 401) {
        throw Exception('Session expired. Please login again.');
      }

      if (response.statusCode != 200) {
        print('❌ Error Response: ${response.statusCode}');
        print('Response: ${response.body}');
        throw Exception('Failed to delete message: ${response.statusCode}');
      }

      print('✅ Message deleted successfully');
    } catch (e) {
      print('❌ Error deleting message: $e');
      rethrow;
    }
  }
}
