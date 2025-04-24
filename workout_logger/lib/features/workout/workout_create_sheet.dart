import 'package:flutter/material.dart';
import 'package:workout_logger/core/services/user_stats_service.dart';

class WorkoutCreateSheet extends StatefulWidget {
  final ScrollController scrollController;
  final Function(Map<String, dynamic>) onSave;
  final UserStatsService userStatsService;  // Add this line to accept userStatsService

  const WorkoutCreateSheet({
    super.key,
    required this.scrollController,
    required this.onSave,
    required this.userStatsService,  // Pass this in the constructor
  });

  @override
  State<WorkoutCreateSheet> createState() => _WorkoutCreateSheetState();
}

class _WorkoutCreateSheetState extends State<WorkoutCreateSheet>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final List<String> _selectedTargetAreas = [];
  final List<Map<String, dynamic>> _exercises = [];

  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  final List<String> _targetAreas = ['Back', 'Chest', 'Legs', 'Arms', 'Abs'];
  final Map<String, List<Map<String, dynamic>>> _exerciseDatabase = {
    'Back': [
      {'name': 'Pull-ups', 'sets': 3, 'reps': 10, 'target': 'Back', 'image': 'assets/images/pull_ups.jpg'},
      {'name': 'Lat Pulldown', 'sets': 3, 'reps': 12, 'target': 'Back', 'image': 'assets/images/lat_pulldown.jpg'},
      {'name': 'Bent-over Rows', 'sets': 4, 'reps': 10, 'target': 'Back', 'image': 'assets/images/bent_over_rows.jpg' },
    ],
    'Chest': [
      {'name': 'Bench Press', 'sets': 4, 'reps': 8, 'target': 'Chest', 'image': 'assets/images/bench_press.jpg'},
      {'name': 'Push-ups', 'sets': 3, 'reps': 15, 'target': 'Chest', 'image': 'assets/images/push_ups.jpg'},
      {'name': 'Incline Dumbbell Press', 'sets': 3, 'reps': 10, 'target': 'Chest', 'image': 'assets/images/inclide_dumbell_press.jpg'},
    ],
    'Legs': [
      {'name': 'Squats', 'sets': 4, 'reps': 8, 'target': 'Legs', 'image': 'assets/images/squats.jpg'},
      {'name': 'Lunges', 'sets': 3, 'reps': 10, 'target': 'Legs', 'image': 'assets/images/lunges.jpg'},
      {'name': 'Leg Press', 'sets': 3, 'reps': 12, 'target': 'Legs', 'image': 'assets/images/leg_press.jpg'},
    ],
    'Arms': [
      {'name': 'Bicep Curls', 'sets': 3, 'reps': 12, 'target': 'Arms', 'image': 'assets/images/bicep_curl.jpg'},
      {'name': 'Tricep Dips', 'sets': 3, 'reps': 10, 'target': 'Arms', 'image': 'assets/images/tricep_dips.jpg'},
      {'name': 'Hammer Curls', 'sets': 3, 'reps': 12, 'target': 'Arms', 'image': 'assets/images/hammer_curls.jpg'},
    ],
    'Abs': [
      {'name': 'Crunches', 'sets': 3, 'reps': 20, 'target': 'Abs', 'image': 'assets/images/crunches.jpg'},
      {'name': 'Plank', 'sets': 3, 'reps': 1, 'duration': '30 sec', 'target': 'Abs', 'image': 'assets/images/plank.jpg'},
      {'name': 'Leg Raises', 'sets': 3, 'reps': 15, 'target': 'Abs', 'image': 'assets/images/leg_raises.jpg'},
    ],
  };

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _opacityAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
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
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      maxChildSize: 0.95,
      minChildSize: 0.6,
      expand: false,
      builder: (_, controller) {
        return FadeTransition(
          opacity: _opacityAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                controller: controller,
                child: _buildFormContent(),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFormContent() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 50,
              height: 5,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Workout Name',
              border: OutlineInputBorder(),
            ),
            validator: (value) =>
            value == null || value.isEmpty ? 'Enter a name' : null,
          ),
          const SizedBox(height: 20),
          const Text('Select Target Areas:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8.0,
            children: _targetAreas.map((area) {
              return FilterChip(
                label: Text(area),
                selected: _selectedTargetAreas.contains(area),
                onSelected: (selected) {
                  setState(() {
                    selected
                        ? _selectedTargetAreas.add(area)
                        : _selectedTargetAreas.remove(area);
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          if (_selectedTargetAreas.isNotEmpty) ...[
            const Text('Tap to Add Exercises:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ..._selectedTargetAreas.expand((area) {
              return _exerciseDatabase[area]!.map((exercise) {
                return ListTile(
                  dense: true,
                  leading: const Icon(Icons.add_circle_outline),
                  title: Text(exercise['name']),
                  subtitle: Text('${exercise['sets']} sets x ${exercise['reps'] ?? exercise['duration']}'),
                  onTap: () => _addExercise(exercise),
                );
              });
            }),
          ],
          if (_exercises.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Divider(),
            const Text('Selected Exercises:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ..._exercises.asMap().entries.map((entry) {
              final index = entry.key;
              final exercise = entry.value;
              return ListTile(
                dense: true,
                leading: IconButton(
                  icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                  onPressed: () => _removeExercise(index),
                ),
                title: Text(exercise['name']),
                subtitle: Text('${exercise['sets']} sets x ${exercise['reps'] ?? exercise['duration']}'),
              );
            }),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.check),
              label: const Text('Create Workout'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                if (_formKey.currentState!.validate() &&
                    _selectedTargetAreas.isNotEmpty &&
                    _exercises.isNotEmpty) {
                  final newWorkout = {
                    'id': DateTime.now().microsecondsSinceEpoch,
                    'name': _nameController.text.trim(),
                    'targetAreas': _selectedTargetAreas,
                    'exercises': _exercises,
                    'createdAt': DateTime.now().toIso8601String(),
                  };
                  widget.onSave(newWorkout); // Trigger the callback to update the home page
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please complete all fields and add exercises.'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
