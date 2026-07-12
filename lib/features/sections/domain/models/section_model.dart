class SectionModel {
  final String id;
  final String name;
  final double areaHectares;
  final String clone;
  final int plantYear;
  final String status; // Active, Resting, Pruning
  final int lastPluckedDaysAgo;
  final int estimatedYieldKg;
  
  const SectionModel({
    required this.id,
    required this.name,
    required this.areaHectares,
    required this.clone,
    required this.plantYear,
    required this.status,
    required this.lastPluckedDaysAgo,
    required this.estimatedYieldKg,
  });

  factory SectionModel.fromJson(Map<String, dynamic> json, {int lastPluckedDaysAgo = 0}) {
    return SectionModel(
      id: json['id'] as String,
      name: json['name'] as String,
      areaHectares: (json['area_hectares'] as num).toDouble(),
      clone: json['clone_type'] ?? '',
      plantYear: json['plant_year'] ?? 0,
      status: json['current_status'] ?? 'Active',
      lastPluckedDaysAgo: lastPluckedDaysAgo,
      estimatedYieldKg: json['estimated_yield_kg'] ?? 0,
    );
  }
}
