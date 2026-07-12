class DispatchLogModel {
  final String id;
  final String planId;
  final String vehicleNumber;
  final String driverName;
  final double totalWeightKg;
  final String status;
  final DateTime? dispatchTime;
  final String? clerkId;
  final DateTime createdAt;

  const DispatchLogModel({
    required this.id,
    required this.planId,
    required this.vehicleNumber,
    required this.driverName,
    required this.totalWeightKg,
    required this.status,
    this.dispatchTime,
    this.clerkId,
    required this.createdAt,
  });

  factory DispatchLogModel.fromJson(Map<String, dynamic> json) {
    return DispatchLogModel(
      id: json['id'] as String,
      planId: json['plan_id'] as String,
      vehicleNumber: json['vehicle_number'] as String,
      driverName: json['driver_name'] as String,
      totalWeightKg: (json['total_weight_kg'] as num).toDouble(),
      status: json['status'] as String,
      dispatchTime: json['dispatch_time'] != null ? DateTime.parse(json['dispatch_time'] as String) : null,
      clerkId: json['clerk_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plan_id': planId,
      'vehicle_number': vehicleNumber,
      'driver_name': driverName,
      'total_weight_kg': totalWeightKg,
      'status': status,
      'dispatch_time': dispatchTime?.toIso8601String(),
      'clerk_id': clerkId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
