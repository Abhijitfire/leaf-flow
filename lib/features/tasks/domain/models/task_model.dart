class TaskModel {
  final String id;
  final DateTime taskDate;
  final String sectionId;
  final String supervisorId;
  final String taskType;
  final String status;
  final int requiredWorkers;
  final DateTime createdAt;

  const TaskModel({
    required this.id,
    required this.taskDate,
    required this.sectionId,
    required this.supervisorId,
    required this.taskType,
    required this.status,
    required this.requiredWorkers,
    required this.createdAt,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as String,
      taskDate: DateTime.parse(json['task_date'] as String),
      sectionId: json['section_id'] as String,
      supervisorId: json['supervisor_id'] as String,
      taskType: json['task_type'] as String,
      status: json['status'] as String,
      requiredWorkers: json['required_workers'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'task_date': taskDate.toIso8601String().split('T')[0],
      'section_id': sectionId,
      'supervisor_id': supervisorId,
      'task_type': taskType,
      'status': status,
      'required_workers': requiredWorkers,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
