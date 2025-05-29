import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitrack_pro/core/models/user_stats.dart';
import 'package:fitrack_pro/core/services/user_stats_service.dart';
import 'package:fitrack_pro/core/services/xp_service.dart';
import 'package:fitrack_pro/features/profile/widgets/editable_profile_header.dart';
import 'package:fitrack_pro/features/profile/widgets/stat_card.dart';
import 'package:fitrack_pro/features/profile/widgets/editable_stat_card.dart';
import 'package:fitrack_pro/features/profile/widgets/xp_progress_bar.dart';

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
    final messenger = ScaffoldMessenger.of(context);
    await _userStatsService.resetStats();
    await _xpService.resetProgress();
    _refreshStats();
    messenger.showSnackBar(
      const SnackBar(content: Text('Stats and XP have been reset')),
    );
  }

  void _updateUsername(String name) {
    setState(() => displayName = name);
  }

  void _updateUserDetails(UserStats updatedStats) async {
    await _userStatsService.updateUserDetails(updatedStats);
    _refreshStats();
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

                XPProgressBar(
                  currentXP: _xpService.progress.currentXP,
                  level: _xpService.progress.level,
                  showTooltip: true,
                ),
                const SizedBox(height: 30),

                const Text(
                  'Workout Summary',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

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
                const Text(
                  'User Details',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: EditableStatCard(
                        icon: Icons.person,
                        label: 'First Name',
                        value: stats.firstName,
                        onChanged: (value) {
                          _updateUserDetails(stats.copyWith(firstName: value));
                        }, onValueChanged: (String newValue) {  },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: EditableStatCard(
                        icon: Icons.person_outline,
                        label: 'Last Name',
                        value: stats.lastName,
                        onChanged: (value) {
                          _updateUserDetails(stats.copyWith(lastName: value));
                        }, onValueChanged: (String newValue) {  },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: EditableStatCard(
                        icon: Icons.email,
                        label: 'Email',
                        value: stats.email,
                        onChanged: (value) {
                          _updateUserDetails(stats.copyWith(email: value));
                        }, onValueChanged: (String newValue) {  },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: EditableStatCard(
                        icon: Icons.transgender,
                        label: 'Gender',
                        value: stats.gender,
                        onChanged: (value) {
                          _updateUserDetails(stats.copyWith(gender: value));
                        }, onValueChanged: (String newValue) {  },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: EditableStatCard(
                        icon: Icons.cake,
                        label: 'Birthday',
                        value: stats.dateOfBirth,
                        onChanged: (value) {
                          _updateUserDetails(stats.copyWith(dateOfBirth: value));
                        }, onValueChanged: (String newValue) {  },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: EditableStatCard(
                        icon: Icons.monitor_weight,
                        label: 'Weight (kg)',
                        value: stats.weight,
                        onChanged: (value) {
                          _updateUserDetails(stats.copyWith(weight: value));
                        }, onValueChanged: (String newValue) {  },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                EditableStatCard(
                  icon: Icons.height,
                  label: 'Height (cm)',
                  value: stats.height,
                  onChanged: (value) {
                    _updateUserDetails(stats.copyWith(height: value));
                  }, onValueChanged: (String newValue) {  },
                ),
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
