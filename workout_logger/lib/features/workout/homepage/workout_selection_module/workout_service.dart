import 'dart:async';
import 'package:workout_logger/core/services/user_stats_service.dart';
import 'package:workout_logger/core/services/xp_service.dart';

class WorkoutService {
  final String username;
  final UserStatsService userStatsService;
  final XPService xpService;

  WorkoutService({
    required this.username,
    required this.userStatsService,
    required this.xpService,
  });

  Future<void> startWorkout(List<dynamic> exercises, String workoutName) async {
    for (int i = 0; i < exercises.length; i++) {
      await _performExercise(exercises[i]);
      if (i < exercises.length - 1) {
        await _startRestPeriod(30);
      }
    }

    await completeWorkout(workoutName: workoutName);
  }

  Future<void> _performExercise(Map<String, dynamic> exercise) async {
    await Future.delayed(const Duration(seconds: 3));
  }

  Future<void> _startRestPeriod(int seconds) async {
    await Future.delayed(Duration(seconds: seconds));
  }

  Future<void> completeWorkout({required String workoutName}) async {
    await userStatsService.updateStatsOnComplete(workoutName);
    await xpService.addXP(10); // Adds 10 XP on workout completion
  }
}
