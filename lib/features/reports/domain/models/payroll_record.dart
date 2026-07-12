class PayrollRecord {
  final String workerId;
  final String workerName;
  final String gangId;
  final bool isPresent;
  final double totalKg;
  final double quotaKg;
  final double baseWage;
  final double incentiveWage;
  final double totalWage;

  const PayrollRecord({
    required this.workerId,
    required this.workerName,
    required this.gangId,
    required this.isPresent,
    required this.totalKg,
    required this.quotaKg,
    required this.baseWage,
    required this.incentiveWage,
    required this.totalWage,
  });

  factory PayrollRecord.fromJson(Map<String, dynamic> json) {
    return PayrollRecord(
      workerId: json['workerId'] as String,
      workerName: json['workerName'] as String,
      gangId: json['gangId'] as String,
      isPresent: json['isPresent'] as bool,
      totalKg: (json['totalKg'] as num).toDouble(),
      quotaKg: (json['quotaKg'] as num).toDouble(),
      baseWage: (json['baseWage'] as num).toDouble(),
      incentiveWage: (json['incentiveWage'] as num).toDouble(),
      totalWage: (json['totalWage'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'workerId': workerId,
      'workerName': workerName,
      'gangId': gangId,
      'isPresent': isPresent,
      'totalKg': totalKg,
      'quotaKg': quotaKg,
      'baseWage': baseWage,
      'incentiveWage': incentiveWage,
      'totalWage': totalWage,
    };
  }
}
