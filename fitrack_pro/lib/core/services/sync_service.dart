import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart'; // for kIsWeb
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fitrack_pro/core/services/local_database_service.dart';

class SyncService {
  // Delay creation until platform check passes
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  final LocalDatabaseService _localDb = LocalDatabaseService();

  Future<void> syncUserData(String username) async {
    // Check for unsupported platforms (Web, Windows, Linux)
    if (kIsWeb ||
        !(Platform.isAndroid || Platform.isIOS || Platform.isMacOS)) {
      print('[SYNC] Firebase not supported on this platform. Sync skipped.');
      return;
    }

    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity == ConnectivityResult.none) {
      print('[SYNC] Offline: Sync skipped');
      return;
    }

    print('[SYNC] Online: Syncing data for $username...');
    try {
      final stats = await _localDb.getUserStats(username);
      final workouts = await _localDb.getAllWorkouts();

      // Sanitize stats to replace nulls (to avoid Firestore issues)
      final sanitizedStats = _sanitizeStats(stats);

      // Upload user stats
      await _firestore
          .collection('users')
          .doc(username)
          .set({'stats': sanitizedStats}, SetOptions(merge: true));

      // Filter and batch upload workouts
      final userWorkouts =
      workouts.where((w) => w['username'] == username).toList();
      final batch = _firestore.batch();

      for (var workout in userWorkouts) {
        final docId = workout['completed_at'] ?? DateTime.now().toIso8601String();
        final docRef = _firestore
            .collection('users')
            .doc(username)
            .collection('workouts')
            .doc(docId);
        batch.set(docRef, workout, SetOptions(merge: true));
      }

      await batch.commit();
      print('[SYNC] Success: User data synced');
    } catch (e) {
      print('[SYNC] Error: $e');
    }
  }

  // New wrapper method to upload full user data, with detailed sanitization and logging
  Future<void> syncFullUserData(String username) async {
    // Platform & connectivity checks
    if (kIsWeb || !(Platform.isAndroid || Platform.isIOS || Platform.isMacOS)) {
      print('[SYNC] Firebase not supported on this platform. Sync skipped.');
      return;
    }

    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity == ConnectivityResult.none) {
      print('[SYNC] Offline: Sync skipped');
      return;
    }

    try {
      print('[SYNC] Starting full sync for user: $username');

      final rawStats = await _localDb.getUserStats(username);

      final sanitizedStats = _sanitizeStats(rawStats);

      final userDocData = {
        'stats': sanitizedStats,
        'lastUpdated': FieldValue.serverTimestamp(),
      };

      print('[SYNC] Uploading user stats: $sanitizedStats');

      await _firestore.collection('users').doc(username).set(userDocData, SetOptions(merge: true));

      final allWorkouts = await _localDb.getAllWorkouts();
      final userWorkouts = allWorkouts.where((w) => w['username'] == username).toList();

      print('[SYNC] Uploading ${userWorkouts.length} workouts for user: $username');

      final batch = _firestore.batch();
      for (var workout in userWorkouts) {
        final workoutId = workout['completed_at'] ?? DateTime.now().toIso8601String();
        final docRef = _firestore.collection('users').doc(username).collection('workouts').doc(workoutId);
        batch.set(docRef, workout, SetOptions(merge: true));
        print('[SYNC] Queued workout upload: $workoutId');
      }

      await batch.commit();
      print('[SYNC] Full sync successful for user: $username');
    } catch (e, stacktrace) {
      print('[SYNC] Error during full sync: $e');
      print(stacktrace);
    }
  }

  // Helper to sanitize stats map by replacing null values appropriately
  Map<String, dynamic> _sanitizeStats(Map<String, dynamic> stats) {
    final sanitized = <String, dynamic>{};
    stats.forEach((key, value) {
      if (value == null) {
        if (key.toLowerCase().contains('date')) {
          sanitized[key] = '';
        } else if (key.toLowerCase().contains('weight') || key.toLowerCase().contains('height')) {
          sanitized[key] = 0;
        } else {
          sanitized[key] = '';
        }
      } else {
        sanitized[key] = value;
      }
    });
    return sanitized;
  }
}
