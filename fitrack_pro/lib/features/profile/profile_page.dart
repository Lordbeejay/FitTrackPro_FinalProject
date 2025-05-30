import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitrack_pro/core/models/user_stats.dart';
import 'package:fitrack_pro/core/services/user_stats_service.dart';
import 'package:fitrack_pro/core/services/xp_service.dart';
import 'package:fitrack_pro/features/profile/widgets/editable_profile_header.dart';
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
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  EditableProfileHeader(
                    username: widget.username,
                    initialName: widget.username,
                    onNameChanged: _updateUsername,
                  ),
                  const SizedBox(height: 30),

                  _buildXPProgressBar(_xpService.progress.level, _xpService.progress.currentXP),

                  const SizedBox(height: 50),

                  _buildSectionTitle('Workout Summary'),
                  _buildStatsDisplay(stats),

                  const SizedBox(height: 20),
                  _buildSectionTitle('User Details'),
                  _buildProfileDetails(stats),

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

  Widget _buildXPProgressBar(int level, int currentXP) {
    return Column(
      children: [
        Text(
          "Level $level",
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 10),
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: currentXP.toDouble()),
          duration: const Duration(seconds: 2),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: double.infinity,
                  height: 20,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blueAccent.withValues(alpha: 0.6),
                        blurRadius: 5,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 0,
                  child: Container(
                    width: (value / 100) * MediaQuery.of(context).size.width * 0.7,
                    height: 20,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ),
                Text(
                  "$currentXP XP",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
    );
  }

  Widget _buildStatsDisplay(UserStats stats) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatBox("Total Workouts", "${stats.totalWorkouts}", Icons.fitness_center),
        _buildStatBox("Performed", "${stats.workoutsPerformed}", Icons.check_circle),
        _buildStatBox("Total Exercises", "${stats.totalExercises}", Icons.list),
      ],
    );
  }

  Widget _buildProfileDetails(UserStats stats) {
    return Column(
      children: [
        _buildDetailRow("First Name", stats.firstName, Icons.person),
        _buildDetailRow("Last Name", stats.lastName, Icons.person_outline),
        _buildDetailRow("Email", stats.email, Icons.email),
        _buildDetailRow("Gender", stats.gender, Icons.transgender),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 18, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildStatBox(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 30, color: Colors.white),
        const SizedBox(height: 5),
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        Text(value, style: const TextStyle(fontSize: 16, color: Colors.white)),
      ],
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