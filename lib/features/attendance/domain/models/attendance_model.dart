class AttendanceModel {
  final String? id; // Supabase generates this, so it can be optional on creation
  final String planId;
  final String workerId;
  final DateTime recordDate;
  final bool isPresent;
  final DateTime createdAt;

  const AttendanceModel({
    this.id,
    required this.planId,
    required this.workerId,
    required this.recordDate,
    required this.isPresent,
    required this.createdAt,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id'] as String?,
      planId: json['plan_id'] as String,
      workerId: json['worker_id'] as String,
      recordDate: DateTime.parse(json['record_date'] as String),
      isPresent: json['is_present'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'plan_id': planId,
      'worker_id': workerId,
      'record_date': recordDate.toIso8601String().split('T')[0],
      'is_present': isPresent,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
