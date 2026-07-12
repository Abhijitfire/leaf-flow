import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Provider for the Supabase Client instance.
/// Ensure Supabase.initialize() is called in main.dart before accessing this.
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// A generic base service for Supabase database operations.
class SupabaseService {
  final SupabaseClient client;

  SupabaseService(this.client);

  // Example generic methods can go here, but usually it's better
  // to have domain-specific repositories (e.g., WorkerRepository)
  // that use the supabaseClientProvider.
}
