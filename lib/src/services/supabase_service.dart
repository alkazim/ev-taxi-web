import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();

  factory SupabaseService() {
    return _instance;
  }

  SupabaseService._internal();

  static const String _supabaseUrl = 'https://bnnzcpgltzjmbxydzbbq.supabase.co';
  static const String _supabaseAnonKey =
      'sb_publishable_ltS-sQc1vrGCks1zRteU4g_KPiSc_Yq';

  Future<void> initialize() async {
    await Supabase.initialize(url: _supabaseUrl, anonKey: _supabaseAnonKey);
  }

  SupabaseClient get client => Supabase.instance.client;

  /// Generates a meaningful, sortable driver code.
  /// Format: ECABBZ-DRV-YYYYMMDD-XXXX
  /// Example: ECABBZ-DRV-20260224-A3F7
  String _generateDriverCode() {
    final now = DateTime.now();
    final date =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    const chars =
        'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // no ambiguous chars (0/O, 1/I)
    final rand = Random.secure();
    final suffix = List.generate(
      4,
      (_) => chars[rand.nextInt(chars.length)],
    ).join();
    return 'ECABBZ-DRV-$date-$suffix';
  }

  /// Registers a new driver in the database and returns the generated human-readable driver code.
  /// This method first signs in anonymously to get a real UUID (used as `id` FK to auth.users),
  /// then generates a human-readable `driver_code`, and inserts both into the 'drivers' table.
  Future<String> registerDriver(Map<String, dynamic> driverData) async {
    try {
      // 1. Sign in anonymously to get a user ID (UUID)
      final AuthResponse res = await client.auth.signInAnonymously();
      if (res.user == null) {
        throw Exception('Failed to sign in anonymously.');
      }
      final String userId = res.user!.id; // This is the UUID from auth.users

      // 2. Generate the human-readable driver code
      final String driverCode = _generateDriverCode();

      // 3. Insert the driver record with both the auth ID and the driver code
      await client
          .from('drivers')
          .insert({...driverData, 'id': userId, 'driver_code': driverCode})
          .timeout(const Duration(seconds: 30));
      return driverCode;
    } catch (e) {
      throw Exception('Failed to register driver: $e');
    }
  }

  /// Fetches an existing driver record by its human-readable driver code.
  Future<Map<String, dynamic>?> getDriverByCode(String driverCode) async {
    try {
      final response = await client
          .from('drivers')
          .select()
          .eq('driver_code', driverCode)
          .maybeSingle()
          .timeout(const Duration(seconds: 30));
      return response;
    } catch (e) {
      throw Exception('Failed to fetch driver: $e');
    }
  }

  /// Updates an existing driver record using its human-readable driver code.
  Future<void> updateDriverByCode(
    String driverCode,
    Map<String, dynamic> driverData,
  ) async {
    try {
      await client
          .from('drivers')
          .update(driverData)
          .eq('driver_code', driverCode)
          .timeout(const Duration(seconds: 30));
    } catch (e) {
      throw Exception('Failed to update driver: $e');
    }
  }

  /// Inserts a new Master Franchise application.
  Future<void> insertMasterFranchise(Map<String, dynamic> data) async {
    try {
      await client
          .from('master_franchises')
          .insert(data)
          .timeout(const Duration(seconds: 30));
    } catch (e) {
      throw Exception('Failed to submit franchise application: $e');
    }
  }
}
