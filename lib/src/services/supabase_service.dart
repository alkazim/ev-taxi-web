import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();

  factory SupabaseService() {
    return _instance;
  }

  SupabaseService._internal();

  // TODO: Replace with your actual Supabase URL and Anon Key
  static const String _supabaseUrl = 'https://bnnzcpgltzjmbxydzbbq.supabase.co';
  static const String _supabaseAnonKey =
      'sb_publishable_ltS-sQc1vrGCks1zRteU4g_KPiSc_Yq';

  Future<void> initialize() async {
    await Supabase.initialize(url: _supabaseUrl, anonKey: _supabaseAnonKey);
  }

  SupabaseClient get client => Supabase.instance.client;

  /// Registers a new driver in the database and returns the generated ID.
  Future<String> registerDriver(Map<String, dynamic> driverData) async {
    try {
      final response = await client
          .from('drivers')
          .insert(driverData)
          .select('id')
          .single();
      return response['id'] as String;
    } catch (e) {
      throw Exception('Failed to register driver: $e');
    }
  }

  /// Fetches an existing driver record by ID.
  Future<Map<String, dynamic>?> getDriverById(String id) async {
    try {
      final response = await client
          .from('drivers')
          .select()
          .eq('id', id)
          .maybeSingle();
      return response;
    } catch (e) {
      throw Exception('Failed to fetch driver: $e');
    }
  }

  /// Updates an existing driver record.
  Future<void> updateDriver(String id, Map<String, dynamic> driverData) async {
    try {
      await client.from('drivers').update(driverData).eq('id', id);
    } catch (e) {
      throw Exception('Failed to update driver: $e');
    }
  }
}
