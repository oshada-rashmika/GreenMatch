class SupervisorProfile {
  final String id;
  final String staffId;
  final String email;
  final String fullName;
  final List<String> specifications;
  final int? capacityLimit;
  final int activeProjectsCount;
  final List<SupervisedProject> supervisedProjects;
  final List<ExpertiseTag> expertiseTags;
  final List<Meeting> meetings;
  final DateTime createdAt;
  final DateTime updatedAt;

  SupervisorProfile({
    required this.id,
    required this.staffId,
    required this.email,
    required this.fullName,
    required this.specifications,
    this.capacityLimit,
    required this.activeProjectsCount,
    required this.supervisedProjects,
    required this.expertiseTags,
    required this.meetings,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SupervisorProfile.fromJson(Map<String, dynamic> json) {
    return SupervisorProfile(
      id: json['id'] as String,
      staffId: json['staffId'] as String,
      email: json['email'] as String,
      fullName: json['fullName'] as String,
      specifications: json['specifications'] != null
          ? List<String>.from(json['specifications'] as List)
          : [],
      capacityLimit: json['capacityLimit'] as int?,
      activeProjectsCount: json['activeProjectsCount'] as int? ?? 0,
      supervisedProjects: json['supervisedProjects'] != null
          ? (json['supervisedProjects'] as List)
                .map((p) => SupervisedProject.fromJson(p))
                .toList()
          : [],
      expertiseTags: json['expertiseTags'] != null
          ? (json['expertiseTags'] as List)
                .map((t) => ExpertiseTag.fromJson(t))
                .toList()
          : [],
      meetings: json['meetings'] != null
          ? (json['meetings'] as List).map((m) => Meeting.fromJson(m)).toList()
          : [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

class SupervisedProject {
  final String id;
  final String title;
  final String status;

  SupervisedProject({
    required this.id,
    required this.title,
    required this.status,
  });

  factory SupervisedProject.fromJson(Map<String, dynamic> json) {
    return SupervisedProject(
      id: json['id'] as String? ?? 'unknown',
      title: json['title'] as String? ?? 'Untitled Project',
      status: json['status'] as String? ?? 'PENDING',
    );
  }
}

class ExpertiseTag {
  final String tagId;
  final String tagName;

  ExpertiseTag({required this.tagId, required this.tagName});

  factory ExpertiseTag.fromJson(Map<String, dynamic> json) {
    final tag = json['tag'] as Map<String, dynamic>?;
    return ExpertiseTag(
      tagId: tag?['id'] as String? ?? 'unknown',
      tagName: tag?['name'] as String? ?? 'Unknown Tag',
    );
  }
}

class Meeting {
  final String id;
  final String status;
  final DateTime? scheduledDate;

  Meeting({required this.id, required this.status, this.scheduledDate});

  factory Meeting.fromJson(Map<String, dynamic> json) {
    return Meeting(
      id: json['id'] as String? ?? 'unknown',
      status: json['status'] as String? ?? 'UNKNOWN',
      scheduledDate: json['scheduledDate'] != null
          ? DateTime.parse(json['scheduledDate'] as String)
          : null,
    );
  }
}
