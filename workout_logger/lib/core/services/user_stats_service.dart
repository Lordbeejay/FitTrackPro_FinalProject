import 'package:workout_logger/core/models/user_stats.dart';
import 'package:workout_logger/core/services/local_database_service.dart';

class UserStatsService {
  final String username;
  final LocalDatabaseService _localDb = LocalDatabaseService();

  UserStatsService({required this.username});

  /// Loads stats, ensuring the user exists only once.
  Future<UserStats> loadStats() async {
    print("Loading stats for $username");
    final statsMap = await _localDb.ensureUserExistsAndLoadStats(username);
    print("Loaded stats for $username: $statsMap");
    return UserStats.fromJson(statsMap);
  }

  Future<void> saveStats(UserStats stats) async {
    await _localDb.setUserStats(username, stats.toJson());
  }

  /// Call when a workout is completed
  Future<void> updateStatsOnComplete(String workoutName, [length]) async {
    final stats = await loadStats();
    print("Updating stats for workout completion...");
    print("Current stats: $stats");

    final updatedStats = stats.copyWith(
      workoutsPerformed: stats.workoutsPerformed + 1,
      lastWorkoutName: workoutName,
      lastWorkoutDate: DateTime.now(),
    );
    print("Updated stats: $updatedStats");

    await saveStats(updatedStats);
  }


  /// Call when a new workout is added
  Future<void> updateStatsOnAdd(Map<String, dynamic> newWorkout) async {
    final stats = await loadStats();
    final updatedStats = stats.copyWith(
      totalWorkouts: stats.totalWorkouts + 1, // Increment total workouts
      totalExercises: stats.totalExercises + (newWorkout['exercises'] as List).length, // Add exercise count
      lastWorkoutName: newWorkout['name'],
    );
    await saveStats(updatedStats);
  }

  /// Call when a workout is deleted
  Future<void> updateStatsOnDelete(Map<String, dynamic> deletedWorkout) async {
    final stats = await loadStats();
    final updatedStats = stats.copyWith(
      totalWorkouts: (stats.totalWorkouts > 0) ? stats.totalWorkouts - 1 : 0, // Ensure total workouts doesn't go below 0
      totalExercises: stats.totalExercises - (deletedWorkout['exercises'] as List).length, // Subtract exercise count
      lastWorkoutName: null, // Clear last workout
    );
    await saveStats(updatedStats);
  }
  // Reset stats for the user
  Future<void> resetStats() async {
    await _localDb.resetUserStats(username);
  }
}
