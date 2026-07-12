class InspectionModel {
  final String id;
  final String planId;
  final String gangId;
  final String supervisorId;
  final int fineLeafPercentage;
  final DateTime checkedAt;

  const InspectionModel({
    required this.id,
    required this.planId,
    required this.gangId,
    required this.supervisorId,
    required this.fineLeafPercentage,
    required this.checkedAt,
  });

  factory InspectionModel.fromJson(Map<String, dynamic> json) {
    return InspectionModel(
      id: json['id'] as String,
      planId: json['plan_id'] as String,
      gangId: json['gang_id'] as String,
      supervisorId: json['supervisor_id'] as String,
      fineLeafPercentage: json['fine_leaf_percentage'] as int,
      checkedAt: DateTime.parse(json['checked_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plan_id': planId,
      'gang_id': gangId,
      'supervisor_id': supervisorId,
      'fine_leaf_percentage': fineLeafPercentage,
      'checked_at': checkedAt.toIso8601String(),
    };
  }
}
