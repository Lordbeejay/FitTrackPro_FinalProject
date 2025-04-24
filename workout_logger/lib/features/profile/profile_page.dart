import 'package:flutter/material.dart';
import 'package:workout_logger/core/models/user_stats.dart';
import 'package:workout_logger/core/services/user_stats_service.dart';
import 'package:workout_logger/features/profile/widgets/stat_card.dart';

class ProfilePage extends StatefulWidget {
  final String username;
  final int totalWorkouts;
  final int totalExercises;
  final String? lastWorkoutName;
  final VoidCallback onLogout;

  const ProfilePage({
    super.key,
    required this.username,
    required this.totalWorkouts,
    required this.totalExercises,
    required this.lastWorkoutName,
    required this.onLogout,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<UserStats> _statsFuture;

  @override
  void initState() {
    super.initState();
    _statsFuture = UserStatsService(username: widget.username).loadStats();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserStats>(
      future: _statsFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final stats = snapshot.data!;
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 50,
                child: Icon(Icons.person, size: 50),
              ),
              const SizedBox(height: 20),
              Text(
                widget.username,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              StatCard(icon: Icons.fitness_center, label: 'Total Workouts', value: '${stats.totalWorkouts}'),
              const SizedBox(height: 12),
              StatCard(
                icon: Icons.fitness_center,
                label: 'Workouts Performed',
                value: '${stats.workoutsPerformed}',
              ),
              const SizedBox(height: 12),
              StatCard(icon: Icons.history, label: 'Last Workout', value: stats.lastWorkoutName ?? 'None yet'),
            ],
          ),
        );
      },
    );
  }
}
