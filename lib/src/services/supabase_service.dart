import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  SupabaseClient get client => Supabase.instance.client;

  Future<void> initialize() async {
    await Supabase.initialize(
      url: 'https://bnnzcpgltzjmbxydzbbq.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJubnpjcGdsdHpqbWJ4eWR6YmJxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzE5MTQ3MTIsImV4cCI6MjA4NzQ5MDcxMn0.7MNCMppiNoLXP4T58Y2w1q3C3Q-pKSXLN8U7_fALTsk', // Replace with your actual anon key
    );
  }

  /// Registers a driver in one go (Final Submit)
  Future<String> registerDriver(Map<String, dynamic> data) async {
    try {
      final code = data['driver_code'] ?? generateDriverCode();
      final fullData = {
        ...data,
        'driver_code': code,
      };
      // Remove 'status' if it exists in the data map, as per instruction.
      // The instruction implies 'status' should not be part of the submission.
      fullData.remove('status');

      await client.from('drivers').insert(fullData);
      debugPrint('Insert successful [drivers]');
      return code;
    } catch (e) {
      throw _handleError(e);
    }
  }

  String generateDriverCode() {
    final now = DateTime.now();
    final dateStr =
        "${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}";
    final randomStr = List.generate(
      4,
      (_) => 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'[math.Random().nextInt(26)],
    ).join();
    return 'ECABBZ-DRV-$dateStr-$randomStr';
  }

  // ─── Franchise Operations ──────────────────────────────────────────────────

  String generateFranchiseCode(String type) {
    final now = DateTime.now();
    final dateStr =
        "${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}";
    final chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final randomStr = List.generate(
      4,
      (_) => chars[math.Random().nextInt(chars.length)],
    ).join();
    // e.g. ECABBZ-FRN-MEG-20260318-A1B2
    return 'ECABBZ-FRN-$type-$dateStr-$randomStr';
  }

  Future<String> registerMasterFranchise(Map<String, dynamic> data) async {
    try {
      final code = generateFranchiseCode('MST');
      data['franchise_code'] = code;
      debugPrint('Supabase INSERT [master_franchises]: $data');
      await client.from('master_franchises').insert(data);
      debugPrint('Insert successful [master_franchises]');
      return code;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<String> registerMegaFranchise(Map<String, dynamic> data) async {
    try {
      final code = generateFranchiseCode('MEG');
      data['franchise_code'] = code;
      debugPrint('Supabase INSERT [mega_franchises]: $data');
      await client.from('mega_franchises').insert(data);
      debugPrint('Insert successful [mega_franchises]');
      return code;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<String> registerSuperFranchise(Map<String, dynamic> data) async {
    try {
      final code = generateFranchiseCode('SUP');
      data['franchise_code'] = code;
      debugPrint('Supabase INSERT [super_franchises]: $data');
      await client.from('super_franchises').insert(data);
      debugPrint('Insert successful [super_franchises]');
      return code;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ─── Private Helpers ───────────────────────────────────────────────────────

  Exception _handleError(dynamic e) {
    if (e is PostgrestException) {
      if (e.code == '23505') {
        if (e.message.contains('mobile1')) {
          return Exception('This mobile number is already registered.');
        }
        if (e.message.contains('email')) {
          return Exception('This email address is already registered.');
        }
        if (e.message.contains('aadhaar')) {
          return Exception('This Aadhaar number is already registered.');
        }
        if (e.message.contains('pan')) {
          return Exception('This PAN card is already registered.');
        }
        return Exception('A record with these details already exists.');
      }
      return Exception('Database Error: ${e.message}');
    }
    return Exception('An unexpected error occurred: $e');
  }
}
