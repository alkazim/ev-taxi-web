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

  /// Generates a meaningful, sortable driver ID.
  /// Format: ECABBZ-DRV-YYYYMMDD-XXXX
  /// Example: ECABBZ-DRV-20260224-A3F7
  String _generateDriverId() {
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

  /// Registers a new driver in the database and returns the generated ID.
  /// The ID is generated client-side so we never need a SELECT round-trip.
  Future<String> registerDriver(Map<String, dynamic> driverData) async {
    final id = _generateDriverId();
    try {
      // Insert only — no .select() needed since we already know the ID.
      await client
          .from('drivers')
          .insert({...driverData, 'id': id})
          .timeout(const Duration(seconds: 15));
      return id;
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
          .maybeSingle()
          .timeout(const Duration(seconds: 15));
      return response;
    } catch (e) {
      throw Exception('Failed to fetch driver: $e');
    }
  }

  /// Updates an existing driver record.
  Future<void> updateDriver(String id, Map<String, dynamic> driverData) async {
    try {
      await client
          .from('drivers')
          .update(driverData)
          .eq('id', id)
          .timeout(const Duration(seconds: 15));
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
          .timeout(const Duration(seconds: 15));
    } catch (e) {
      throw Exception('Failed to submit franchise application: $e');
    }
  }
}
