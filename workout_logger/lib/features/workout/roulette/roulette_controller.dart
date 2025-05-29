import 'dart:math';
import 'roulette_model.dart';
import 'roulette_services.dart';

class RouletteController {
  final WorkoutService _workoutService = WorkoutService();
  double angle = 0;
  String? selectedWorkout;
  bool spinning = false;

  List<Workout> get workouts => _workoutService.getWorkouts();

  double spin() {
    final random = Random();
    final spins = 5 + random.nextInt(5);
    final targetAngle = spins * 2 * pi + random.nextDouble() * 2 * pi;
    angle = targetAngle;
    spinning = true;
    return angle;
  }

  void selectWorkout() {
    final normalizedAngle = angle % (2 * pi);
    final anglePerItem = 2 * pi / workouts.length;
    int selectedIndex =
        ((workouts.length - (normalizedAngle / anglePerItem)) % workouts.length)
            .floor();
    selectedWorkout = workouts[selectedIndex].name;
    spinning = false;
  }
}
