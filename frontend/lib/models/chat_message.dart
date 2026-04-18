import 'package:intl/intl.dart';

class ChatMessage {
  final String id;
  final String content;
  final String senderType; // 'STUDENT' or 'SUPERVISOR'
  final String senderName;
  final String? senderEmail;
  final String projectId;
  final DateTime createdAt;
  final String? studentId;
  final String? supervisorId;

  ChatMessage({
    required this.id,
    required this.content,
    required this.senderType,
    required this.senderName,
    this.senderEmail,
    required this.projectId,
    required this.createdAt,
    this.studentId,
    this.supervisorId,
  });

  // Factory for parsing from JSON
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String? ?? '',
      content: json['content'] as String? ?? '',
      senderType: json['senderType'] as String? ?? 'STUDENT',
      senderName: json['senderName'] as String? ?? 'Unknown',
      senderEmail:
          json['student']?['email'] as String? ?? json['supervisor']?['email'],
      projectId: json['projectId'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      studentId: json['studentId'],
      supervisorId: json['supervisorId'],
    );
  }

  // Convert to JSON for sending
  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'senderType': senderType,
      'senderId': studentId ?? supervisorId,
      'senderName': senderName,
      'projectId': projectId,
    };
  }

  // Format time nicely
  String get formattedTime {
    return DateFormat('HH:mm').format(createdAt);
  }

  String get formattedDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(
      createdAt.year,
      createdAt.month,
      createdAt.day,
    );

    if (messageDate == today) {
      return 'Today';
    } else if (messageDate == today.subtract(Duration(days: 1))) {
      return 'Yesterday';
    } else {
      return DateFormat('MMM dd, yyyy').format(createdAt);
    }
  }

  // Check if message is from supervisor
  bool get isSupervisorMessage => senderType == 'SUPERVISOR';

  // Check if message is from student
  bool get isStudentMessage => senderType == 'STUDENT';
}
