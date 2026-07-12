import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  await Supabase.initialize(
    url: 'https://opgkhukmyxcpisnksuwy.supabase.co',
    publishableKey: 'sb_publishable_3jq4GtcvTzhA__dAqViv9w_sP3fD6uY',
  );

  final supabase = Supabase.instance.client;

  try {
    log('Attempting login...');
    final response = await supabase.auth.signInWithPassword(
      email: 'manager@leafflow.in',
      password: 'password123',
    );
    log('Login successful! User ID: ${response.user?.id}');

    log('Attempting to query profiles...');
    final profile = await supabase
        .from('profiles')
        .select('role')
        .eq('id', response.user!.id)
        .single();
    log('Profile found: $profile');
  } on AuthException catch (e) {
    log('AuthException: ${e.message}');
    log('Status code: ${e.statusCode}');
  } on PostgrestException catch (e) {
    log('PostgrestException: ${e.message}');
    log('Details: ${e.details}');
    log('Code: ${e.code}');
  } catch (e) {
    log('Unknown error: $e');
  }
}
