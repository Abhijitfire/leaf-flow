import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/supabase_service.dart';
import '../../domain/models/section_model.dart';
import '../../../../core/utils/mock_data.dart';

final sectionRepositoryProvider = Provider<SectionRepository>((ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return SectionRepository(supabaseClient);
});

class SectionRepository {
  final dynamic supabaseClient;

  SectionRepository(this.supabaseClient);

  Future<List<SectionModel>> getSections() async {
    try {
      // Fetch all sections
      final data = await supabaseClient.from('sections').select();
      final sections = data as List;

      // Fetch the most recent completed plan date per section.
      // We pull all completed plans ordered by date descending, then group locally.
      final plansData = await supabaseClient
          .from('estate_plans')
          .select('section_id, plan_date')
          .eq('status', 'completed')
          .order('plan_date', ascending: false);
      final plans = plansData as List;

      // Build a map: section_id -> most recent completed plan_date
      final Map<String, DateTime> lastHarvestMap = {};
      for (final plan in plans) {
        final sectionId = plan['section_id'] as String;
        if (!lastHarvestMap.containsKey(sectionId)) {
          lastHarvestMap[sectionId] = DateTime.parse(plan['plan_date'] as String);
        }
      }

      final today = DateTime.now();
      return sections.map((e) {
        final sectionId = e['id'] as String;
        final lastHarvest = lastHarvestMap[sectionId];
        final daysAgo = lastHarvest != null
            ? today.difference(lastHarvest).inDays
            : 999; // Never harvested = very overdue
        return SectionModel.fromJson(e, lastPluckedDaysAgo: daysAgo);
      }).toList();
    } catch (e) {
      return MockData.sections;
    }
  }

  Future<void> createSection({
    required String name,
    required double areaHectares,
    required String clone,
    required int plantYear,
    required int estimatedYieldKg,
  }) async {
    await supabaseClient.from('sections').insert({
      'name': name,
      'area_hectares': areaHectares,
      'clone_type': clone,
      'plant_year': plantYear,
      'current_status': 'Active',
      // Note: estimated_yield_kg was not in the original SQL schema, so we omit it here
      // to prevent "column not found" errors on Supabase.
    });
  }
}

// Provider to expose the sections stream/future to the UI
final sectionsProvider = FutureProvider<List<SectionModel>>((ref) async {
  final repository = ref.watch(sectionRepositoryProvider);
  return repository.getSections();
});
