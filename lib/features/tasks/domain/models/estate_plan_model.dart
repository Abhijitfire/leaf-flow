class EstatePlanModel {
  final String id;
  final DateTime planDate;
  final String sectionId;
  final String? sectionName;
  final String dafaId;
  final double targetKg;
  final String status;
  final String taskType;
  final String targetUnit;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;

  const EstatePlanModel({
    required this.id,
    required this.planDate,
    required this.sectionId,
    this.sectionName,
    required this.dafaId,
    required this.targetKg,
    required this.status,
    this.taskType = 'Plucking',
    this.targetUnit = 'kg',
    this.metadata,
    required this.createdAt,
  });

  factory EstatePlanModel.fromJson(Map<String, dynamic> json) {
    return EstatePlanModel(
      id: json['id'] as String,
      planDate: DateTime.parse(json['plan_date'] as String),
      sectionId: json['section_id'] as String,
      sectionName: json['sections'] != null ? json['sections']['name'] as String? : null,
      dafaId: json['dafa_id'] as String? ?? 'unknown',
      targetKg: (json['target_kg'] as num).toDouble(),
      status: json['status'] as String,
      taskType: json['task_type'] as String? ?? 'Plucking',
      targetUnit: json['target_unit'] as String? ?? 'kg',
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plan_date': planDate.toIso8601String().split('T')[0],
      'section_id': sectionId,
      'dafa_id': dafaId,
      'target_kg': targetKg,
      'status': status,
      'task_type': taskType,
      'target_unit': targetUnit,
      'metadata': metadata ?? {},
      'created_at': createdAt.toIso8601String(),
    };
  }
}
