import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:workout_logger/core/models/user_stats.dart';

class UserStatsService {
  final String username;

  UserStatsService({required this.username});

  Future<File> get _statsFile async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/user_stats_$username.json');
  }

  // Loads stats from file with backward compatibility for missing fields
  Future<UserStats> loadStats() async {
    final file = await _statsFile;
    if (await file.exists()) {
      final content = await file.readAsString();
      final data = json.decode(content);

      // Ensure backward compatibility by adding default values if missing
      return UserStats.fromJson({
        'totalWorkouts': data['totalWorkouts'] ?? 0,
        'totalExercises': data['totalExercises'] ?? 0,
        'workoutsPerformed': data['workoutsPerformed'] ?? 0,  // Default value for backward compatibility
        'lastWorkoutName': data['lastWorkoutName'],  // Handle optional fields
      });
    } else {
      return UserStats(
        totalWorkouts: 0,
        totalExercises: 0,
        workoutsPerformed: 0, // Default to 0 for backward compatibility
      );
    }
  }

  // Save the current stats to file
  Future<void> saveStats(UserStats stats) async {
    final file = await _statsFile;
    await file.writeAsString(json.encode(stats.toJson()));
  }

  // Update stats when a workout is added
  Future<void> updateStatsOnAdd(Map<String, dynamic> workout) async {
    final stats = await loadStats();
    stats.totalWorkouts += 1;
    stats.totalExercises += (workout['exercises'] as List).length;
    stats.lastWorkoutName = workout['name'];
    await saveStats(stats);
  }

  // Update stats when a workout is deleted
  Future<void> updateStatsOnDelete(Map<String, dynamic> workout) async {
    final stats = await loadStats();
    stats.totalWorkouts = (stats.totalWorkouts - 1).clamp(0, double.infinity).toInt();
    stats.totalExercises =
        (stats.totalExercises - (workout['exercises'] as List).length).clamp(0, double.infinity).toInt();

    // Do NOT change `lastWorkoutName` on delete to keep it persistent
    await saveStats(stats);
  }

  // Increment the number of workouts performed
  Future<void> incrementWorkoutsPerformed() async {
    final stats = await loadStats();
    stats.workoutsPerformed += 1;
    await saveStats(stats);
  }
  Future<void> updateStatsOnComplete() async {
    final stats = await loadStats();
    stats.totalWorkoutsPerformed += 1;
    await saveStats(stats);
  }
}