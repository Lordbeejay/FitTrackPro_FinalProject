import 'dart:async';
import 'package:workout_logger/core/services/user_stats_service.dart';

class WorkoutService {
  final String username;
  final UserStatsService userStatsService;

  WorkoutService({required this.username, required this.userStatsService});

  Future<void> startWorkout(List<dynamic> exercises) async {
    int restSeconds = 30;

    for (int i = 0; i < exercises.length; i++) {
      final exercise = exercises[i];

      // Perform the exercise
      await _performExercise(exercise);

      // If this is not the last exercise, rest before next
      if (i < exercises.length - 1) {
        await _startRestPeriod(
          restSeconds: restSeconds,
          onRestPeriodEnd: () {
            // You can log here if needed
          },
        );
      }
    }

    // Workout complete after the last exercise
    await completeWorkout();
  }

  Future<void> _performExercise(Map<String, dynamic> exercise) async {
    // Simulate the exercise logic here (could be time-based or reps-based)
    // Here we replace the print statement with a comment or log
    // Log: 'Performing exercise: ${exercise['name']}'
    await Future.delayed(const Duration(seconds: 3)); // Simulate exercise time
  }

  Future<void> _startRestPeriod({
    required int restSeconds,
    required Function onRestPeriodEnd,
  }) async {
    // Simulate rest period countdown
    // Log: 'Resting for $restSeconds seconds...'
    await Future.delayed(Duration(seconds: restSeconds));
    onRestPeriodEnd();  // Notify that rest period is over
  }

  Future<void> completeWorkout() async {
    // Increment the number of workouts performed
    await userStatsService.updateStatsOnComplete();

    // Get the updated stats after incrementing workouts performed
    final stats = await userStatsService.loadStats();
    // Log the number of workouts performed (use proper logging here in production)
    // Log: 'Workout complete. Total workouts performed: ${stats.totalWorkouts}'
  }
}
