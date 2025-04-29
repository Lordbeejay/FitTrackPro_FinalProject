import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_logger/features/workout/timer/rest_controller.dart';

class WorkoutInProgressScreen extends StatefulWidget {
  final List<Map<String, dynamic>> exercises;
  final VoidCallback onWorkoutComplete;
  final VoidCallback onBack;

  const WorkoutInProgressScreen({
    super.key,
    required this.exercises,
    required this.onWorkoutComplete,
    required this.onBack,
  });

  @override
  State<WorkoutInProgressScreen> createState() => _WorkoutInProgressScreenState();
}

class _WorkoutInProgressScreenState extends State<WorkoutInProgressScreen> {
  int _currentIndex = 0;
  bool _showRestAfterThis = false;

  @override
  void initState() {
    super.initState();
    _showRestAfterThis = false;
  }

  void _moveToNext() {
    final restController = context.read<RestTimerController>();

    if (_currentIndex < widget.exercises.length - 1) {
      // If we just finished an exercise, show rest
      if (!_showRestAfterThis) {
        restController.startRest();
        setState(() => _showRestAfterThis = true);
      } else {
        // After rest, go to next exercise
        setState(() {
          _currentIndex++;
          _showRestAfterThis = false;
        });
      }
    } else {
      widget.onWorkoutComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RestTimerController>(
        builder: (context, restController, _) {
          final exercise = widget.exercises[_currentIndex];
          final isResting = restController.isResting;

          return Scaffold(
            appBar: AppBar(
              title: const Text('Workout In Progress'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: widget.onBack,
              ),
              centerTitle: true,
            ),
            body: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isResting
                        ? 'Resting...'
                        : 'Exercise ${_currentIndex + 1} of ${widget.exercises.length}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: (_currentIndex + 1) / widget.exercises.length,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isResting ? Colors.orange : Colors.green,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Center(
                    child: Column(
                      children: [
                        if (exercise['image'] != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: exercise['image'].toString().startsWith('http')
                                ? Image.network(
                              exercise['image'],
                              height: 200,
                              fit: BoxFit.cover,
                            )
                                : Image.asset(
                              exercise['image'],
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                          )
                        else
                          Icon(
                            isResting ? Icons.hourglass_bottom : Icons.fitness_center,
                            size: 80,
                            color: isResting ? Colors.orange : Colors.green,
                          ),
                        const SizedBox(height: 16),
                        Text(
                          exercise['name'],
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          exercise['description'] ?? 'No description provided.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Center(
                    child: isResting
                        ? Column(
                      children: [
                        Text(
                          'Rest Time: ${restController.secondsRemaining} sec',
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton.icon(
                          onPressed: () {
                            restController.skipRest();
                            _moveToNext();
                          },
                          icon: const Icon(Icons.skip_next),
                          label: const Text('Skip Rest'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    )
                        : ElevatedButton.icon(
                      onPressed: _moveToNext,
                      icon: const Icon(Icons.navigate_next),
                      label: Text(_currentIndex == widget.exercises.length - 1
                          ? 'Finish Workout'
                          : 'Next Exercise'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          );
        },
      );
  }
}