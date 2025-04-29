import 'package:flutter/material.dart';
import 'package:workout_logger/core/models/user_stats.dart';
import 'package:workout_logger/core/services/user_stats_service.dart';
import 'package:workout_logger/core/services/xp_service.dart';
import 'package:workout_logger/features/profile/widgets/editable_profile_header.dart';
import 'package:workout_logger/features/profile/widgets/stat_card.dart';
import 'package:workout_logger/features/profile/widgets/xp_progress_bar.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  final String username;
  final int totalWorkouts;
  final int totalExercises;
  final VoidCallback onLogout;
  final String lastWorkoutName;

  const ProfilePage({
    super.key,
    required this.username,
    required this.totalWorkouts,
    required this.totalExercises,
    required this.onLogout,
    required this.lastWorkoutName,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late UserStatsService _userStatsService;
  late XPService _xpService;
  late Future<UserStats> _statsFuture;
  String displayName = '';

  @override
  void initState() {
    super.initState();
    displayName = widget.username;
    _userStatsService = UserStatsService(username: widget.username);
    _xpService = Provider.of<XPService>(context, listen: false);
    _statsFuture = _userStatsService.loadStats();
  }

  void _refreshStats() {
    setState(() {
      _statsFuture = _userStatsService.loadStats();
    });
  }

  void _resetStats() async {
    await _userStatsService.resetStats();
    await _xpService.resetProgress(); // Reset XP when stats are reset
    _refreshStats();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Stats and XP have been reset')),
    );
  }

  void _updateUsername(String name) {
    setState(() => displayName = name);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: FutureBuilder<UserStats>(
        future: _statsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final stats = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                EditableProfileHeader(
                  username: widget.username,
                  initialName: widget.username,
                  onNameChanged: _updateUsername,
                ),
                const SizedBox(height: 30),
                // XP Progress Bar
                XPProgressBar(
                  currentXP: _xpService.progress.currentXP,
                  level: _xpService.progress.level,
                ),
                const SizedBox(height: 30),
                GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.4,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    StatCard(
                      icon: Icons.fitness_center,
                      label: 'Total Workouts',
                      value: '${stats.totalWorkouts}',
                    ),
                    StatCard(
                      icon: Icons.check_circle,
                      label: 'Performed',
                      value: '${stats.workoutsPerformed}',
                    ),
                    StatCard(
                      icon: Icons.list,
                      label: 'Total Exercises',
                      value: '${stats.totalExercises}',
                    ),
                    StatCard(
                      icon: Icons.history,
                      label: 'Last Workout',
                      value: stats.lastWorkoutName ?? 'None',
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                StatCard(
                  icon: Icons.date_range,
                  label: 'Last Workout Date',
                  value: stats.lastWorkoutDate?.toLocal().toString().split(' ')[0] ?? 'N/A',
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _resetStats,
                        icon: const Icon(Icons.refresh),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.error,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        label: const Text('Reset Stats'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _refreshStats,
                        icon: const Icon(Icons.sync),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        label: const Text('Refresh'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
