import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Provider này cung cấp instance của Supabase cho bất kỳ file nào cần gọi Database
final supabaseProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});
