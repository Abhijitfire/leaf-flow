import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/supabase_service.dart';

class ProfileModel {
  final String id;
  final String fullName;
  final String role;

  ProfileModel({required this.id, required this.fullName, required this.role});

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String,
      fullName: json['full_name'] as String,
      role: json['role'] as String,
    );
  }
}

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return ProfileRepository(supabaseClient);
});

class ProfileRepository {
  final SupabaseClient supabaseClient;

  ProfileRepository(this.supabaseClient);

  Future<List<ProfileModel>> getSupervisors() async {
    try {
      final data = await supabaseClient
          .from('profiles')
          .select()
          .eq('role', 'supervisor');
      return (data as List).map((e) => ProfileModel.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }
}

final supervisorsProvider = FutureProvider<List<ProfileModel>>((ref) async {
  final repository = ref.watch(profileRepositoryProvider);
  return repository.getSupervisors();
});
