import 'package:flutter/material.dart';
import 'package:workout_logger/features/workout/workout_selection_module/workout_service.dart';

class WorkoutStartScreen extends StatelessWidget {
  final List<dynamic> exercises;
  final WorkoutService workoutService;

  const WorkoutStartScreen({
    Key? key,
    required this.exercises,
    required this.workoutService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Start Workout'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Get ready to start your workout!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // Start the workout
                await workoutService.startWorkout(exercises);

                // Ensure that context is still valid before navigating
                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
              child: const Text('Start Workout'),
            ),
          ],
        ),
      ),
    );
  }
}
