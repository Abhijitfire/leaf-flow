class Worker {
  final String id; // This is the PF Number
  final String name;
  final String dafaId;
  final double dailyQuotaKg;
  final String phoneNumber;
  final bool isPresent; // For Hazira tracking

  const Worker({
    required this.id,
    required this.name,
    required this.dafaId,
    required this.dailyQuotaKg,
    this.phoneNumber = '',
    this.isPresent = false,
  });

  factory Worker.fromJson(Map<String, dynamic> json) {
    return Worker(
      id: json['pf_number'] as String,
      name: json['full_name'] as String,
      dafaId: json['dafa_id'] as String? ?? 'unknown',
      dailyQuotaKg: (json['daily_quota_kg'] as num?)?.toDouble() ?? 20.0,
      phoneNumber: json['phone_number'] as String? ?? '',
      isPresent: false, // Default state
    );
  }

  // To easily toggle state
  Worker copyWith({
    String? id,
    String? name,
    String? dafaId,
    double? dailyQuotaKg,
    String? phoneNumber,
    bool? isPresent,
  }) {
    return Worker(
      id: id ?? this.id,
      name: name ?? this.name,
      dafaId: dafaId ?? this.dafaId,
      dailyQuotaKg: dailyQuotaKg ?? this.dailyQuotaKg,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isPresent: isPresent ?? this.isPresent,
    );
  }
}
