import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/supabase_service.dart';
import '../../domain/models/estate_plan_model.dart';

final estatePlanRepositoryProvider = Provider<EstatePlanRepository>((ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return EstatePlanRepository(supabaseClient);
});

class EstatePlanRepository {
  final dynamic supabaseClient;

  EstatePlanRepository(this.supabaseClient);

  Future<List<EstatePlanModel>> getActiveEstatePlans() async {
    try {
      final data = await supabaseClient
          .from('estate_plans')
          .select('*, sections(name)')
          .eq('status', 'active');
      return (data as List).map((e) => EstatePlanModel.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> createEstatePlan({
    required String sectionId,
    required String dafaId,
    required String targetValue,
    required String taskType,
    required String targetUnit,
    Map<String, dynamic>? metadata,
  }) async {
    final double? target = double.tryParse(targetValue);
    if (target == null) throw Exception("Invalid target weight");

    await supabaseClient.from('estate_plans').insert({
      'plan_date': DateTime.now().toIso8601String().split('T').first,
      'section_id': sectionId,
      'dafa_id': dafaId,
      'status': 'active',
      'target_kg': target,
      'task_type': taskType,
      'target_unit': targetUnit,
      'metadata': metadata ?? {},
    });
  }

  Future<void> completeEstatePlan(String planId) async {
    await supabaseClient
        .from('estate_plans')
        .update({'status': 'completed'})
        .eq('id', planId);
  }

  Future<List<EstatePlanModel>> getCompletedEstatePlans({
    DateTime? date,
  }) async {
    try {
      var query = supabaseClient
          .from('estate_plans')
          .select('*, sections(name)')
          .eq('status', 'completed');

      if (date != null) {
        final dateStr = DateTime(
          date.year,
          date.month,
          date.day,
        ).toIso8601String().split('T').first;
        query = query.eq('plan_date', dateStr);
      }

      final data = await query;
      return (data as List).map((e) => EstatePlanModel.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }
}

// Provider to expose the active estate plans
final activeEstatePlansProvider =
    FutureProvider.autoDispose<List<EstatePlanModel>>((ref) async {
      final repository = ref.watch(estatePlanRepositoryProvider);
      final supabase = ref.watch(supabaseClientProvider);

      final channel = supabase
          .channel('public_estate_plans_list')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'estate_plans',
            callback: (payload) {
              ref.invalidateSelf();
            },
          )
          .subscribe();

      ref.onDispose(() {
        supabase.removeChannel(channel);
      });

      return repository.getActiveEstatePlans();
    });

// Provider to expose today's completed estate plans
final completedTodayEstatePlansProvider =
    FutureProvider.autoDispose<List<EstatePlanModel>>((ref) async {
      final repository = ref.watch(estatePlanRepositoryProvider);
      final supabase = ref.watch(supabaseClientProvider);

      final channel = supabase
          .channel('public_estate_plans_completed')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'estate_plans',
            callback: (payload) {
              ref.invalidateSelf();
            },
          )
          .subscribe();

      ref.onDispose(() {
        supabase.removeChannel(channel);
      });

      return repository.getCompletedEstatePlans(date: DateTime.now());
    });
