import 'dart:math';
import 'roulette_model.dart';

class WorkoutService {
  final List<Workout> _workouts = [
    Workout('Push-ups'),
    Workout('Squats'),
    Workout('Burpees'),
    Workout('Plank'),
    Workout('Jumping Jacks'),
    Workout('Lunges'),
    Workout('Sit-ups'),
    Workout('Pull-ups'),
    Workout('Lat Pulldown'),
    Workout('Bent-over Rows'),
    Workout('Bench Press'),
    Workout('Leg Press'),
    Workout('Bicep Curls'),
    Workout('Tricep Dips'),
    Workout('Hammer Curls'),
    Workout('Crunches'),
    Workout('Leg Raises'),
  ];

  List<Workout> getWorkouts() => List.unmodifiable(_workouts);

  int getRandomIndex() => Random().nextInt(_workouts.length);
}
