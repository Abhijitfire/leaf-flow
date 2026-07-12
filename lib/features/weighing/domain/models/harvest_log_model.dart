class HarvestLogModel {
  final String? id;
  final String workerId;
  final String? sectionId;
  final String? planId;
  final String dafaId;
  final DateTime harvestDate;
  final double weightKg;
  final String leafQuality;
  final String clerkId;
  final DateTime? createdAt;

  const HarvestLogModel({
    this.id,
    required this.workerId,
    this.sectionId,
    this.planId,
    required this.dafaId,
    required this.harvestDate,
    required this.weightKg,
    this.leafQuality = 'Fine',
    required this.clerkId,
    this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'worker_id': workerId,
      if (sectionId != null) 'section_id': sectionId,
      if (planId != null) 'plan_id': planId,
      'dafa_id': dafaId,
      'harvest_date': harvestDate.toIso8601String().split('T').first,
      'weight_kg': weightKg,
      'leaf_quality': leafQuality,
      'clerk_id': clerkId,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }

  factory HarvestLogModel.fromJson(Map<String, dynamic> json) {
    return HarvestLogModel(
      id: json['id'] as String?,
      workerId: json['worker_id'] as String,
      sectionId: json['section_id'] as String?,
      planId: json['plan_id'] as String?,
      dafaId: json['dafa_id'] as String? ?? 'unknown',
      harvestDate: DateTime.parse(json['harvest_date'] as String),
      weightKg: (json['weight_kg'] as num).toDouble(),
      leafQuality: json['leaf_quality'] as String? ?? 'Fine',
      clerkId: json['clerk_id'] as String,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
    );
  }
}

