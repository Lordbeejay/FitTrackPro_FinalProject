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

      // Upload user stats
      await _firestore
          .collection('users')
          .doc(username)
          .set({'stats': stats}, SetOptions(merge: true));

      // Filter and batch upload workouts
      final userWorkouts =
      workouts.where((w) => w['username'] == username).toList();
      final batch = _firestore.batch();

      for (var workout in userWorkouts) {
        final docRef = _firestore
            .collection('users')
            .doc(username)
            .collection('workouts')
            .doc(workout['completed_at']);
        batch.set(docRef, workout, SetOptions(merge: true));
      }

      await batch.commit();
      print('[SYNC] Success: User data synced');
    } catch (e) {
      print('[SYNC] Error: $e');
    }
  }
}