import 'package:workout_logger/core/models/user_stats.dart';
import 'package:workout_logger/core/services/local_database_service.dart';

class UserStatsService {
  final String username;
  final LocalDatabaseService _localDb = LocalDatabaseService();

  UserStatsService({required this.username});

  Future<UserStats> loadStats() async {
    print("Loading stats for $username");
    final statsMap = await _localDb.ensureUserExistsAndLoadStats(username);
    print("Loaded stats for $username: $statsMap");
    return UserStats.fromJson(statsMap);
  }

  Future<void> saveStats(UserStats stats) async {
    await _localDb.setUserStats(username, stats.toJson());
  }

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

  Future<void> updateStatsOnAdd(Map<String, dynamic> newWorkout) async {
    final stats = await loadStats();
    final updatedStats = stats.copyWith(
      totalWorkouts: stats.totalWorkouts + 1,
      totalExercises: stats.totalExercises + (newWorkout['exercises'] as List).length,
      lastWorkoutName: newWorkout['name'],
    );
    await saveStats(updatedStats);
  }

  Future<void> updateStatsOnDelete(Map<String, dynamic> deletedWorkout) async {
    final stats = await loadStats();
    final updatedStats = stats.copyWith(
      totalWorkouts: (stats.totalWorkouts > 0) ? stats.totalWorkouts - 1 : 0,
      totalExercises: stats.totalExercises - (deletedWorkout['exercises'] as List).length,
      lastWorkoutName: null,
    );
    await saveStats(updatedStats);
  }

  Future<void> resetStats() async {
    await _localDb.resetUserStats(username);
  }

  Future<void> updateUserDetails(UserStats updatedStats) async {
    final existingStats = await loadStats();
    final newStats = existingStats.copyWith(
      firstName: updatedStats.firstName,
      lastName: updatedStats.lastName,
      email: updatedStats.email,
      gender: updatedStats.gender,
      dateOfBirth: updatedStats.dateOfBirth,
      weight: updatedStats.weight,
      height: updatedStats.height,
    );
    await saveStats(newStats);
  }
}