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
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
          ),
        ),
        child: FutureBuilder<UserStats>(
          future: _statsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data == null) {
              return Center(child: Text('No profile data available.'));
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

                  _buildSectionTitle('Workout Summary'),
                  _buildStatsGrid(stats),

                  const SizedBox(height: 20),
                  _buildSectionTitle('User Details'),

                  _buildEditableRow([
                    _buildEditableStat(stats, 'First Name', Icons.person, (value) => stats.copyWith(firstName: value)),
                    _buildEditableStat(stats, 'Last Name', Icons.person_outline, (value) => stats.copyWith(lastName: value)),
                  ]),

                  _buildEditableRow([
                    _buildEditableStat(stats, 'Email', Icons.email, (value) => stats.copyWith(email: value)),
                    _buildEditableStat(stats, 'Gender', Icons.transgender, (value) => stats.copyWith(gender: value)),
                  ]),

                  _buildEditableRow([
                    _buildEditableStat(stats, 'Birthday', Icons.cake, (value) => stats.copyWith(dateOfBirth: value)),
                    _buildEditableStat(stats, 'Weight (kg)', Icons.monitor_weight, (value) => stats.copyWith(weight: value)),
                  ]),

                  _buildEditableStat(stats, 'Height (cm)', Icons.height, (value) => stats.copyWith(height: value)),

                  const SizedBox(height: 30),
                  Row(
                    children: [
                      _buildActionButton('Reset Stats', Icons.refresh, _resetStats, Colors.redAccent),
                      const SizedBox(width: 16),
                      _buildActionButton('Refresh', Icons.sync, _refreshStats, Colors.blue),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
    );
  }

  Widget _buildStatsGrid(UserStats stats) {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.4,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        StatCard(icon: Icons.fitness_center, label: 'Total Workouts', value: '${stats.totalWorkouts}'),
        StatCard(icon: Icons.check_circle, label: 'Performed', value: '${stats.workoutsPerformed}'),
        StatCard(icon: Icons.list, label: 'Total Exercises', value: '${stats.totalExercises}'),
        StatCard(icon: Icons.history, label: 'Last Workout', value: stats.lastWorkoutName ?? 'None'),
      ],
    );
  }

  Widget _buildEditableRow(List<Widget> children) {
    return Row(
      children: children.map((widget) => Expanded(child: widget)).toList(),
    );
  }

  Widget _buildEditableStat(UserStats stats, String label, IconData icon, Function(String) onChanged) {
    return EditableStatCard(
      icon: icon,
      label: label,
      value: (stats.toJson()[label.toLowerCase()] ?? '').toString(),
      onChanged: (value) {
        _updateUserDetails(onChanged(value));
      },
      onValueChanged: (String newValue) {},
    );
  }

  Widget _buildActionButton(String label, IconData icon, VoidCallback onPressed, Color color) {
    return Expanded(
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        label: Text(label),
      ),
    );
  }
}