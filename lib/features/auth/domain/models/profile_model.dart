class ProfileModel {
  final String id;
  final String role; // 'manager', 'supervisor', 'clerk'
  final String fullName;
  final DateTime createdAt;

  const ProfileModel({
    required this.id,
    required this.role,
    required this.fullName,
    required this.createdAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String,
      role: json['role'] as String,
      fullName: json['full_name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role,
      'full_name': fullName,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
