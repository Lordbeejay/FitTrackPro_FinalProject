import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:workout_logger/core/services/user_stats_service.dart';
import 'package:workout_logger/core/services/auth_service.dart';
import 'package:workout_logger/core/services/xp_service.dart';
import 'package:workout_logger/features/auth/login/login_page.dart';
import 'package:workout_logger/features/profile/profile_page.dart';
import 'package:workout_logger/features/workout/homepage/workout_create_sheet.dart';
import 'package:workout_logger/features/workout/homepage/workout_selection_module/workout_service.dart';
import 'package:workout_logger/features/workout/homepage/workout_selection_module/workout_in_progress_screen.dart';
import 'package:workout_logger/features/workout/timer/rest_controller.dart';

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
        title: const Text('Workout Complete!'),
        content: const Text('Great job on finishing your workout!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
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

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text('Your Workouts',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: _workouts.isEmpty
              ? const Center(child: Text('No workouts yet. Tap + to get started.'))
              : ListView.builder(
            itemCount: _workouts.length,
            itemBuilder: (_, index) {
              final workout = _workouts[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: _getWorkoutIcon(workout['targetAreas'][0]),
                  title: Text(workout['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Target: ${workout['targetAreas'].join(', ')}'),
                      Text('${workout['exercises'].length} exercises'),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.play_arrow, color: Colors.green),
                        onPressed: () {
                          final exercises = List<Map<String, dynamic>>.from(workout['exercises']);
                          _startWorkout(exercises);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteWorkout(index),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalExercises = _workouts.fold<int>(
      0,
          (sum, workout) => sum + ((workout['exercises'] as List).length),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('FitTrack Pro'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _confirmLogout,
          ),
        ],
      ),
      body: (_selectedIndex == 0)
          ? _buildHomeScreen()
          : ProfilePage(
        username: widget.username,
        onLogout: _confirmLogout,
        lastWorkoutName: _workouts.isNotEmpty ? _workouts[0]['name'] : 'None yet',
        totalExercises: totalExercises,
        totalWorkouts: _workouts.length,
      ),
      floatingActionButton: _selectedIndex == 0 && !_isWorkoutInProgress
          ? FloatingActionButton(
        onPressed: _addWorkout,
        tooltip: 'Add Workout',
        child: const Icon(Icons.add),
      )
          : null,
    );
  }

  Icon _getWorkoutIcon(String targetArea) {
    switch (targetArea.toLowerCase()) {
      case 'back':
        return const Icon(Icons.arrow_back);
      case 'legs':
        return const Icon(Icons.directions_walk);
      default:
        return const Icon(Icons.fitness_center);
    }
  }

  Future<void> _confirmLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Logout')),
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