import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'login_signup.dart';

class WorkoutHomePage extends StatefulWidget {
  final String username;

  const WorkoutHomePage({super.key, required this.username});

  @override
  State<WorkoutHomePage> createState() => _WorkoutHomePageState();
}

class _WorkoutHomePageState extends State<WorkoutHomePage> {
  List<Map<String, dynamic>> _workouts = [];
  int _selectedIndex = 0;
  bool _isWorkoutInProgress = false;
  int _currentExerciseIndex = 0;
  bool _isResting = false;
  int _restSeconds = 30;
  late Timer _restTimer;

  @override
  void initState() {
    super.initState();
    _loadWorkouts();
  }

  @override
  void dispose() {
    _restTimer.cancel();
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

  void _addWorkout() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const WorkoutDialog(),
    );

    if (result != null) {
      setState(() {
        _workouts.insert(0, result);
      });
      await _saveWorkouts();
    }
  }

  void _deleteWorkout(int index) async {
    setState(() {
      _workouts.removeAt(index);
    });
    await _saveWorkouts();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _startWorkout(List<Map<String, dynamic>> exercises) {
    setState(() {
      _isWorkoutInProgress = true;
      _currentExerciseIndex = 0;
      _isResting = false;
    });
    _showExerciseInstructions(exercises);
  }

  void _showExerciseInstructions(List<Map<String, dynamic>> exercises) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final exercise = exercises[_currentExerciseIndex];
        return AlertDialog(
          title: Text("Next: ${exercise['name']}"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Target: ${exercise['target']}"),
              const SizedBox(height: 10),
              Text("Sets: ${exercise['sets']}"),
              Text("Reps: ${exercise['reps']}"),
              const SizedBox(height: 20),
              Image.asset(
                'Assets/${exercise['name'].toLowerCase().replaceAll(' ', '_')}.jpg',
                height: 150,
                errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.fitness_center, size: 100),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _startRestPeriod(exercises);
              },
              child: const Text('Start'),
            ),
          ],
        );
      },
    );
  }

  void _startRestPeriod(List<Map<String, dynamic>> exercises) {
    setState(() {
      _isResting = true;
      _restSeconds = 30;
    });

    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _restSeconds--;
      });

      if (_restSeconds <= 0) {
        timer.cancel();
        setState(() {
          _isResting = false;
        });
        _moveToNextExercise(exercises);
      }
    });
  }

  void _moveToNextExercise(List<Map<String, dynamic>> exercises) {
    if (_currentExerciseIndex < exercises.length - 1) {
      setState(() {
        _currentExerciseIndex++;
      });
      _showExerciseInstructions(exercises);
    } else {
      setState(() {
        _isWorkoutInProgress = false;
      });
      _showWorkoutCompleteDialog();
    }
  }

  void _showWorkoutCompleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FitTrack Pro'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
          ),
        ],
      ),
      body: _selectedIndex == 0
          ? _buildHomeScreen()
          : _buildProfileScreen(),
      floatingActionButton: _selectedIndex == 0 && !_isWorkoutInProgress
          ? FloatingActionButton(
        onPressed: _addWorkout,
        tooltip: 'Add Workout',
        child: const Icon(Icons.add),
      )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildHomeScreen() {
    if (_isWorkoutInProgress) {
      return _buildWorkoutInProgressScreen();
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: const Text(
            'Your Workouts',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: _workouts.isEmpty
              ? const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.fitness_center, size: 100, color: Colors.grey),
                SizedBox(height: 20),
                Text(
                  'No workouts created yet',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 10),
                Text(
                  'Tap the + button to create your first workout!',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          )
              : ListView.builder(
            itemCount: _workouts.length,
            itemBuilder: (context, index) {
              final workout = _workouts[index];
              return Card(
                margin: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: _getWorkoutIcon(workout['targetAreas'][0]),
                  title: Text(
                    workout['name'],
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Target areas: ${workout['targetAreas'].join(', ')}'),
                      Text('${workout['exercises'].length} exercises'),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.play_arrow, color: Colors.green),
                        onPressed: () => _startWorkout(workout['exercises']),
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

  Widget _buildWorkoutInProgressScreen() {
    final currentExercise = _workouts[0]['exercises'][_currentExerciseIndex];

    return Column(
      children: [
        LinearProgressIndicator(
          value: (_currentExerciseIndex + (_isResting ? 0.5 : 0)) /
              _workouts[0]['exercises'].length,
        ),
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isResting)
                  Column(
                    children: [
                      const Text(
                        'REST',
                        style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '$_restSeconds',
                        style: const TextStyle(fontSize: 80, fontWeight: FontWeight.bold),
                      ),
                      Text('Next: ${currentExercise['name']}'),
                    ],
                  )
                else
                  Column(
                    children: [
                      Text(
                        currentExercise['name'],
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        '${currentExercise['sets']} sets x ${currentExercise['reps']} reps',
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(height: 30),
                      Image.asset(
                        'assets/${currentExercise['name'].toLowerCase().replaceAll(' ', '_')}.png',
                        height: 200,
                        errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.fitness_center, size: 150),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: ElevatedButton(
            onPressed: () {
              if (_isResting) {
                _restTimer.cancel();
                _moveToNextExercise(_workouts[0]['exercises']);
              } else {
                _startRestPeriod(_workouts[0]['exercises']);
              }
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: _isResting ? Colors.green : Colors.blue,
            ),
            child: Text(
              _isResting ? 'Skip Rest' : 'Complete Set',
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileScreen() {
    return Center(
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
          const SizedBox(height: 20),
          Text(
            'Total Workouts: ${_workouts.length}',
            style: const TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }

  Icon _getWorkoutIcon(String targetArea) {
    switch (targetArea.toLowerCase()) {
      case 'back':
        return const Icon(Icons.accessibility_new, color: Colors.orange);
      case 'chest':
        return const Icon(Icons.self_improvement, color: Colors.red);
      case 'legs':
        return const Icon(Icons.directions_run, color: Colors.green);
      case 'arms':
        return const Icon(Icons.fitness_center, color: Colors.blue);
      case 'abs':
        return const Icon(Icons.health_and_safety, color: Colors.purple);
      default:
        return const Icon(Icons.fitness_center, color: Colors.grey);
    }
  }
}

class WorkoutDialog extends StatefulWidget {
  const WorkoutDialog({super.key});

  @override
  _WorkoutDialogState createState() => _WorkoutDialogState();
}

class _WorkoutDialogState extends State<WorkoutDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final List<String> _selectedTargetAreas = [];
  final List<Map<String, dynamic>> _exercises = [];

  final List<String> _targetAreas = ['Back', 'Chest', 'Legs', 'Arms', 'Abs'];
  final Map<String, List<Map<String, dynamic>>> _exerciseDatabase = {
    'Back': [
      {'name': 'Pull-ups', 'sets': 3, 'reps': 10, 'target': 'Back'},
      {'name': 'Lat Pulldown', 'sets': 3, 'reps': 12, 'target': 'Back'},
      {'name': 'Bent-over Rows', 'sets': 4, 'reps': 10, 'target': 'Back'},
    ],
    'Chest': [
      {'name': 'Bench Press', 'sets': 4, 'reps': 8, 'target': 'Chest'},
      {'name': 'Push-ups', 'sets': 3, 'reps': 15, 'target': 'Chest'},
      {'name': 'Incline Dumbbell Press', 'sets': 3, 'reps': 10, 'target': 'Chest'},
    ],
    'Legs': [
      {'name': 'Squats', 'sets': 4, 'reps': 8, 'target': 'Legs'},
      {'name': 'Lunges', 'sets': 3, 'reps': 10, 'target': 'Legs'},
      {'name': 'Leg Press', 'sets': 3, 'reps': 12, 'target': 'Legs'},
    ],
    'Arms': [
      {'name': 'Bicep Curls', 'sets': 3, 'reps': 12, 'target': 'Arms'},
      {'name': 'Tricep Dips', 'sets': 3, 'reps': 10, 'target': 'Arms'},
      {'name': 'Hammer Curls', 'sets': 3, 'reps': 12, 'target': 'Arms'},
    ],
    'Abs': [
      {'name': 'Crunches', 'sets': 3, 'reps': 20, 'target': 'Abs'},
      {'name': 'Plank', 'sets': 3, 'reps': 1, 'duration': '30 sec', 'target': 'Abs'},
      {'name': 'Leg Raises', 'sets': 3, 'reps': 15, 'target': 'Abs'},
    ],
  };

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _addExercise(Map<String, dynamic> exercise) {
    setState(() {
      _exercises.add(exercise);
    });
  }

  void _removeExercise(int index) {
    setState(() {
      _exercises.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create New Workout'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Workout Name'),
                validator: (value) =>
                value == null || value.isEmpty ? 'Enter workout name' : null,
              ),
              const SizedBox(height: 20),
              const Text('Select Target Areas:'),
              Wrap(
                spacing: 8.0,
                children: _targetAreas.map((area) {
                  return FilterChip(
                    label: Text(area),
                    selected: _selectedTargetAreas.contains(area),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedTargetAreas.add(area);
                        } else {
                          _selectedTargetAreas.remove(area);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              if (_selectedTargetAreas.isNotEmpty) ...[
                const Text('Select Exercises:'),
                const SizedBox(height: 10),
                ..._selectedTargetAreas.expand((area) {
                  return _exerciseDatabase[area]!.map((exercise) {
                    return ListTile(
                      leading: const Icon(Icons.add),
                      title: Text(exercise['name']),
                      subtitle: Text('${exercise['sets']} sets x ${exercise['reps'] ?? exercise['duration']}'),
                      onTap: () => _addExercise(exercise),
                    );
                  });
                }),
              ],
              const SizedBox(height: 20),
              if (_exercises.isNotEmpty) ...[
                const Text('Selected Exercises:'),
                ..._exercises.asMap().entries.map((entry) {
                  final index = entry.key;
                  final exercise = entry.value;
                  return ListTile(
                    leading: IconButton(
                      icon: const Icon(Icons.remove, color: Colors.red),
                      onPressed: () => _removeExercise(index),
                    ),
                    title: Text(exercise['name']),
                    subtitle: Text('${exercise['sets']} sets x ${exercise['reps'] ?? exercise['duration']}'),
                  );
                }),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate() && _selectedTargetAreas.isNotEmpty && _exercises.isNotEmpty) {
              final newWorkout = {
                'id': DateTime.now().microsecondsSinceEpoch,
                'name': _nameController.text.trim(),
                'targetAreas': _selectedTargetAreas,
                'exercises': _exercises,
                'createdAt': DateTime.now().toIso8601String(),
              };
              Navigator.pop(context, newWorkout);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please select at least one target area and add exercises'),
                ),
              );
            }
          },
          child: const Text('Create'),
        ),
      ],
    );
  }
}