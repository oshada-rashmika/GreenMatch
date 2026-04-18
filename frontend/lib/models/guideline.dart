class GuidelineModuleData {
  final String moduleCode;
  final String moduleName;

  const GuidelineModuleData({
    required this.moduleCode,
    required this.moduleName,
  });

  factory GuidelineModuleData.fromJson(Map<String, dynamic> json) {
    return GuidelineModuleData(
      moduleCode: (json['moduleCode'] ?? '').toString(),
      moduleName: (json['moduleName'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'moduleCode': moduleCode,
      'moduleName': moduleName,
    };
  }
}

class Guideline {
  final String id;
  final String title;
  final String instructions;
  final Map<String, String> deliverables;
  final DateTime deadline;
  final DateTime createdAt;
  final String moduleId;
  final GuidelineModuleData? module;

  const Guideline({
    required this.id,
    required this.title,
    required this.instructions,
    required this.deliverables,
    required this.deadline,
    required this.createdAt,
    required this.moduleId,
    this.module,
  });

  factory Guideline.fromJson(Map<String, dynamic> json) {
    final dynamic rawDeliverables = json['deliverables'];
    final Map<String, String> parsedDeliverables = {};

    if (rawDeliverables is Map<String, dynamic>) {
      for (final entry in rawDeliverables.entries) {
        final key = entry.key.trim();
        final value = entry.value.toString().trim();
        if (key.isNotEmpty && value.isNotEmpty) {
          parsedDeliverables[key] = value;
        }
      }
    } else if (rawDeliverables is List) {
      // Backward compatibility for older records that stored only names.
      for (final item in rawDeliverables) {
        final key = item.toString().trim();
        if (key.isNotEmpty) {
          parsedDeliverables[key] = '';
        }
      }
    }

    final moduleJson = json['module'];
    return Guideline(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      instructions: (json['instructions'] ?? '').toString(),
      deliverables: parsedDeliverables,
      deadline: DateTime.tryParse((json['deadline'] ?? '').toString()) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      moduleId: (json['moduleId'] ?? '').toString(),
      module: moduleJson is Map<String, dynamic>
          ? GuidelineModuleData.fromJson(moduleJson)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'instructions': instructions,
      'deliverables': Map<String, String>.from(deliverables),
      'deadline': deadline.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'moduleId': moduleId,
      if (module != null) 'module': module!.toJson(),
    };
  }
}
