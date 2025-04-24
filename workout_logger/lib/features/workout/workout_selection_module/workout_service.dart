import 'package:flutter/foundation.dart';
import 'package:workout_logger/core/services/user_stats_service.dart';

class WorkoutService {
  final String username;
  final UserStatsService userStatsService;

  WorkoutService({required this.username, required this.userStatsService});

  Future<void> completeWorkout() async {
    await userStatsService.updateStatsOnComplete();
    final stats = await userStatsService.loadStats();
    debugPrint('Workout complete. Total workouts performed: ${stats.totalWorkouts}');
  }
}