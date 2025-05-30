import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:fitrack_pro/core/services/user_stats_service.dart';
import 'package:fitrack_pro/core/services/auth_service.dart';
import 'package:fitrack_pro/core/services/xp_service.dart';
import 'package:fitrack_pro/features/auth/login/login_page.dart';
import 'package:fitrack_pro/features/workout/homepage/workout_create_sheet.dart';
import 'package:fitrack_pro/features/workout/homepage/workout_selection_module/workout_service.dart';
import 'package:fitrack_pro/features/workout/homepage/workout_selection_module/workout_in_progress_screen.dart';
import 'package:fitrack_pro/features/workout/timer/rest_controller.dart';
import 'package:fitrack_pro/core/services/mini_challenge_service.dart';
import 'package:fitrack_pro/features/workout/mini_challenge/mini_challenge_card.dart';
import 'package:fitrack_pro/features/workout/mini_challenge/mini_challenge_screen.dart';
import 'package:fitrack_pro/core/models/mini_challenge.dart';

class WorkoutHomePage extends StatefulWidget {
  final String username;
  final AuthService authService;
  final XPService xpService;

  const WorkoutHomePage({
    super.key,
    required this.username,
    required this.authService,
    required this.xpService,
  });

  @override
  State<WorkoutHomePage> createState() => _WorkoutHomePageState();
}

class _WorkoutHomePageState extends State<WorkoutHomePage> {
  List<Map<String, dynamic>> _workouts = [];
  final int _selectedIndex = 0;
  bool _isWorkoutInProgress = false;
  late final UserStatsService _userStatsService;
  late final WorkoutService _workoutService;

  @override
  void initState() {
    super.initState();
    _userStatsService = UserStatsService(username: widget.username);
    _workoutService = WorkoutService(
      username: widget.username,
      userStatsService: _userStatsService,
      xpService: widget.xpService,
    );
    _loadWorkouts();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<File> get _workoutFile async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/workouts_${widget.username}.json');
  }

  Future<void> _loadWorkouts() async {
    try {
      final file = await _workoutFile;
      if (await file.exists()) {
        final content = await file.readAsString();
        setState(() {
          _workouts = List<Map<String, dynamic>>.from(json.decode(content));
        });
      }
    } catch (e) {
      debugPrint("Error loading workouts: $e");
    }
  }

  Future<void> _saveWorkouts() async {
    final file = await _workoutFile;
    await file.writeAsString(json.encode(_workouts));
  }

  void _addWorkout() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => WorkoutCreateSheet(
        scrollController: ScrollController(),
        userStatsService: _userStatsService,
        onSave: (newWorkout) async {
          Navigator.pop(context);
          setState(() {
            _workouts.insert(0, newWorkout);
          });
          await _saveWorkouts();
          await _userStatsService.updateStatsOnAdd(newWorkout);
        },
      ),
    );
  }

  void _deleteWorkout(int index) async {
    final workout = _workouts[index];
    setState(() {
      _workouts.removeAt(index);
    });
    await _saveWorkouts();
    await _userStatsService.updateStatsOnDelete(workout);
  }

  void _startWorkout(List<Map<String, dynamic>> exercises) async {
    setState(() {
      _isWorkoutInProgress = true;
    });

    final workoutName = exercises.first['workoutName'] ?? 'Unnamed Workout';
    await _workoutService.startWorkout(exercises, workoutName);
  }

  void _endWorkoutEarly() {
    setState(() {
      _isWorkoutInProgress = false;
    });
  }

  void _showWorkoutCompleteDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.celebration, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            const Text('Workout Complete!', style: TextStyle(color: Color(0xFF4A00E0))),
          ],
        ),
        content: const Text(
          'Great job on finishing your workout!',
          style: TextStyle(color: Color(0xFF6A1B9A), fontSize: 16),
        ),
        actions: [
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutInProgressScreen() {
    final exercisesRaw = _workouts[0]['exercises'];
    final exercises = (exercisesRaw as List)
        .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
        .toList();

    return ChangeNotifierProvider(
      create: (_) => RestTimerController(),
      child: WorkoutInProgressScreen(
        exercises: exercises,
        onWorkoutComplete: () async {
          final workoutName = _workouts[0]['name'] ?? 'Unnamed Workout';
          await _workoutService.completeWorkout(workoutName: workoutName);
          _showWorkoutCompleteDialog();
          setState(() {
            _isWorkoutInProgress = false;
          });
        },
        onBack: _endWorkoutEarly,
      ),
    );
  }

  Widget _buildHomeScreen() {
    if (_isWorkoutInProgress) return _buildWorkoutInProgressScreen();

    final MiniChallengeService challengeService = MiniChallengeService();

    return FutureBuilder<MiniChallenge>(
      future: challengeService.getTodayChallenge(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8E2DE2)),
              strokeWidth: 3,
            ),
          );
        }
        final challenge = snapshot.data!;
        return Container(
          color: Colors.white,
          child: Column(
            children: [
              // Header with purple accent only
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFFB299E5).withOpacity(0.18),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFB299E5), Color(0xFF9DCEFF)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.fitness_center, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Your Workouts',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4A00E0),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              // Add Workout button - outlined style
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.add_circle_outline, color: Color(0xFF6A11CB)),
                  label: const Text(
                    'Add New Workout',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6A11CB),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFB299E5), width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  ),
                  onPressed: _addWorkout,
                ),
              ),
              // Workout cards
              Expanded(
                child: _workouts.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.fitness_center_outlined, size: 64, color: Color(0xFFB299E5)),
                            const SizedBox(height: 16),
                            const Text(
                              'No workouts yet',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF6A1B9A),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap "Add New Workout" to get started!',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF8E2DE2).withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _workouts.length,
                        itemBuilder: (_, index) {
                          final workout = _workouts[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0xFFB299E5).withOpacity(0.12),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                              border: Border.all(
                                color: Color(0xFFB299E5).withOpacity(0.25),
                                width: 1,
                              ),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(20),
                              leading: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Color(0xFFB299E5),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: _getWorkoutIcon(workout['targetAreas'][0]),
                              ),
                              title: Text(
                                workout['name'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Color(0xFF4A00E0),
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 8),
                                  Text(
                                    'Target: ${workout['targetAreas'].join(', ')}',
                                    style: const TextStyle(
                                      color: Color(0xFF6A1B9A),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Icon(Icons.list_alt, size: 16, color: Color(0xFFB299E5)),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${workout['exercises'].length} exercises',
                                        style: const TextStyle(
                                          color: Color(0xFFB299E5),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.play_arrow, color: Color(0xFF6A11CB), size: 24),
                                    onPressed: () {
                                      final exercises = List<Map<String, dynamic>>.from(workout['exercises']);
                                      _startWorkout(exercises);
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 22),
                                    onPressed: () => _deleteWorkout(index),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
              Container(
                margin: const EdgeInsets.all(16),
                child: MiniChallengeCard(
                  challenge: challenge,
                  onStart: () async {
                    final completed = await challengeService.isChallengeCompleted();
                    if (completed) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('You already completed today\'s challenge!'),
                          backgroundColor: Color(0xFF8E2DE2),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                      return;
                    }
                    await showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => MiniChallengeScreen(
                        challenge: challenge,
                        onComplete: () {
                          setState(() {
                            // Optionally update XP here
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
            ),
          ),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.flash_on, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            const Text(
              'FiTrack Pro',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              icon: const Icon(Icons.logout_rounded, color: Colors.white),
              onPressed: _confirmLogout,
            ),
          ),
        ],
      ),
      body: _buildHomeScreen(),
    );
  }

  Icon _getWorkoutIcon(String targetArea) {
    switch (targetArea.toLowerCase()) {
      case 'back':
        return const Icon(Icons.arrow_back, color: Colors.white, size: 20);
      case 'legs':
        return const Icon(Icons.directions_walk, color: Colors.white, size: 20);
      default:
        return const Icon(Icons.fitness_center, color: Colors.white, size: 20);
    }
  }

  Future<void> _confirmLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.logout_rounded, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            const Text('Confirm Logout', style: TextStyle(color: Color(0xFF4A00E0))),
          ],
        ),
        content: const Text(
          'Are you sure you want to log out?',
          style: TextStyle(color: Color(0xFF6A1B9A), fontSize: 16),
        ),
        actions: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Color(0xFF8E2DE2)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel', style: TextStyle(color: Color(0xFF8E2DE2))),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Logout', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );

    if (shouldLogout == true && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => LoginPage(authService: widget.authService),
        ),
      );
    }
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final MiniChallengeService _challengeService = MiniChallengeService();
  MiniChallenge? _todayChallenge;
  int _userXP = 0;
  bool _loadingChallenge = true;

  @override
  void initState() {
    super.initState();
    _loadTodayChallenge();
  }

  Future<void> _loadTodayChallenge() async {
    final challenge = await _challengeService.getTodayChallenge();
    setState(() {
      _todayChallenge = challenge;
      _loadingChallenge = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingChallenge || _todayChallenge == null) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8E2DE2)),
          strokeWidth: 3,
        ),
      );
    }
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF3E5F5),
            Color(0xFFE8EAF6),
            Colors.white,
          ],
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.all(16.0),
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF8E2DE2).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.fitness_center, color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  Text(
                    "Your Workouts",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            // Add the Mini Challenge Card here
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: MiniChallengeCard(
                challenge: _todayChallenge!,
                onStart: () async {
                  final completed = await _challengeService.isChallengeCompleted();
                  if (completed) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('You already completed today\'s challenge!'),
                        backgroundColor: Color(0xFF8E2DE2),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                    return;
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MiniChallengeScreen(
                        challenge: _todayChallenge!,
                        onComplete: () {
                          setState(() {
                            _userXP += _todayChallenge!.xpReward;
                          });
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
            // ...your other workout cards...
          ],
        ),
      ),
    );
  }
}