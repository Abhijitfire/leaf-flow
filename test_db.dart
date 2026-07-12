import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  await Supabase.initialize(
    url: 'https://purgqctoklddypylokid.supabase.co',
    publishableKey: '...',
  );
  final res = await Supabase.instance.client.from('estate_plans').select();
  log(res.toString());
}
