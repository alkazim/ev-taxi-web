import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../../firebase_options.dart';

/// Human-readable error categories returned by FirebaseService.
enum FirebaseErrorKind { network, auth, server, timeout, unknown, permission }

/// Structured error thrown by [FirebaseService] so callers can show
/// meaningful messages to the user.
class FirebaseAppException implements Exception {
  final FirebaseErrorKind kind;
  final String userMessage;
  final String technicalDetail;

  FirebaseAppException({
    required this.kind,
    required this.userMessage,
    required this.technicalDetail,
  });

  @override
  String toString() => userMessage;
}

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();

  factory FirebaseService() => _instance;

  FirebaseService._internal();

  /// Shorter timeout for faster user feedback.
  static const Duration _timeout = Duration(seconds: 15);

  /// Max number of automatic retries for transient network errors.
  static const int _maxRetries = 2;

  Future<void> initialize() async {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  }

  FirebaseAuth get auth => FirebaseAuth.instance;
  FirebaseFirestore get db => FirebaseFirestore.instance;

  // ─── Error classification ───────────────────────────────────────────────────

  FirebaseAppException _classify(Object e) {
    if (e is FirebaseException) {
      switch (e.code) {
        case 'unavailable':
        case 'network-request-failed':
          return FirebaseAppException(
            kind: FirebaseErrorKind.network,
            userMessage:
                'Unable to connect to the server.\nPlease check your internet connection.',
            technicalDetail: e.message ?? e.code,
          );
        case 'deadline-exceeded':
          return FirebaseAppException(
            kind: FirebaseErrorKind.timeout,
            userMessage: 'The request timed out.\nPlease try again.',
            technicalDetail: e.message ?? e.code,
          );
        case 'permission-denied':
          return FirebaseAppException(
            kind: FirebaseErrorKind.permission,
            userMessage: 'Access denied.\nPlease contact support.',
            technicalDetail: e.message ?? e.code,
          );
        case 'user-disabled':
        case 'operation-not-allowed':
          return FirebaseAppException(
            kind: FirebaseErrorKind.auth,
            userMessage: 'Authentication is currently disabled.',
            technicalDetail: e.message ?? e.code,
          );
        default:
          return FirebaseAppException(
            kind: FirebaseErrorKind.unknown,
            userMessage: 'Something went wrong.\nPlease try again.',
            technicalDetail: e.message ?? e.code,
          );
      }
    }

    if (e is TimeoutException) {
      return FirebaseAppException(
        kind: FirebaseErrorKind.timeout,
        userMessage: 'The request timed out.\nPlease try again.',
        technicalDetail: e.toString(),
      );
    }

    return FirebaseAppException(
      kind: FirebaseErrorKind.unknown,
      userMessage: 'An unexpected error occurred.\nPlease try again.',
      technicalDetail: e.toString(),
    );
  }

  // ─── Retry wrapper ──────────────────────────────────────────────────────────

  Future<T> _withRetry<T>(Future<T> Function() fn) async {
    int attempt = 0;
    while (true) {
      try {
        return await fn().timeout(_timeout);
      } catch (e) {
        final classified = _classify(e);
        final isRetryable =
            classified.kind == FirebaseErrorKind.network ||
            classified.kind == FirebaseErrorKind.timeout;

        if (isRetryable && attempt < _maxRetries) {
          attempt++;
          debugPrint(
            '[FirebaseService] Attempt $attempt failed, retrying… ($e)',
          );
          await Future.delayed(Duration(seconds: attempt * 2));
          continue;
        }
        throw classified;
      }
    }
  }

  // ─── Driver code generator ─────────────────────────────────────────────────

  String _generateDriverCode() {
    final now = DateTime.now();
    final date =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rand = Random.secure();
    final suffix = List.generate(
      4,
      (_) => chars[rand.nextInt(chars.length)],
    ).join();
    return 'ECABBZ-DRV-$date-$suffix';
  }

  // ─── Authentication ────────────────────────────────────────────────────────

  Future<User> _ensureAuthenticated() async {
    if (auth.currentUser != null) return auth.currentUser!;
    final userCredential = await auth.signInAnonymously();
    if (userCredential.user == null) {
      throw FirebaseAppException(
        kind: FirebaseErrorKind.auth,
        userMessage: 'Failed to authenticate anonymously.',
        technicalDetail: 'UserCredential.user is null',
      );
    }
    return userCredential.user!;
  }

  // ─── Driver operations ─────────────────────────────────────────────────────

  Future<String> registerDriver(Map<String, dynamic> driverData) async {
    return _withRetry(() async {
      final user = await _ensureAuthenticated();
      final driverCode = _generateDriverCode();

      await db.collection('drivers').doc(driverCode).set({
        ...driverData,
        'id': user.uid, // Keep UID for security rules reference
        'driver_code': driverCode,
        'created_at': FieldValue.serverTimestamp(),
      });

      return driverCode;
    });
  }

  Future<Map<String, dynamic>?> getDriverByCode(String driverCode) async {
    return _withRetry(() async {
      final doc = await db.collection('drivers').doc(driverCode).get();
      if (!doc.exists) return null;
      return doc.data();
    });
  }

  Future<void> updateDriverByCode(
    String driverCode,
    Map<String, dynamic> driverData,
  ) async {
    await _withRetry(() async {
      final docRef = db.collection('drivers').doc(driverCode);
      await docRef.update({
        ...driverData,
        'updated_at': FieldValue.serverTimestamp(),
      });
    });
  }

  // ─── Franchise operations ──────────────────────────────────────────────────

  Future<String> _insertFranchise(
    String collection,
    String prefix,
    Map<String, dynamic> data,
  ) async {
    return _withRetry(() async {
      final user = await _ensureAuthenticated();
      final code = _generateFranchiseCode(prefix);

      await db.collection(collection).doc(code).set({
        ...data,
        'id': user.uid,
        'franchise_code': code,
        'created_at': FieldValue.serverTimestamp(),
      });
      return code;
    });
  }

  Future<String> insertMasterFranchise(Map<String, dynamic> data) async =>
      _insertFranchise('master_franchise', 'MST', data);
  Future<String> insertMegaFranchise(Map<String, dynamic> data) async =>
      _insertFranchise('mega_franchise', 'MEG', data);
  Future<String> insertSuperFranchise(Map<String, dynamic> data) async =>
      _insertFranchise('super_franchise', 'SUP', data);

  String _generateFranchiseCode(String type) {
    final now = DateTime.now();
    final dateStr =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    final suffix = List.generate(
      4,
      (index) => chars[((DateTime.now().microsecondsSinceEpoch + index) % 26)],
    ).join();
    return 'ECABBZ-FRN-$type-$dateStr-$suffix';
  }
}
