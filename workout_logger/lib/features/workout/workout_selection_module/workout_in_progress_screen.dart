import 'package:flutter/material.dart';

class WorkoutInProgressScreen extends StatelessWidget {
  final Map<String, dynamic> currentExercise;
  final List<Map<String, dynamic>> exercises;
  final bool isResting;
  final int restSeconds;
  final VoidCallback onRestPeriodEnd;
  final VoidCallback onSkipRest;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const WorkoutInProgressScreen({
    Key? key,
    required this.currentExercise,
    required this.exercises,
    required this.isResting,
    required this.restSeconds,
    required this.onRestPeriodEnd,
    required this.onSkipRest,
    required this.onNext,
    required this.onBack,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final index = exercises.indexOf(currentExercise);
    final total = exercises.length;
    final isLast = index == total - 1;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout In Progress'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onBack,
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isResting ? 'Resting...' : 'Exercise ${index + 1} of $total',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: (index + 1) / total,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                isResting ? Colors.orange : Colors.green,
              ),
            ),
            const SizedBox(height: 32),
            Center(
              child: Column(
                children: [
                  if (currentExercise['image'] != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: currentExercise['image'].toString().startsWith('http')
                          ? Image.network(
                              currentExercise['image'],
                              height: 200,
                              fit: BoxFit.cover,
                            )
                          : Image.asset(
                              currentExercise['image'],
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
                    currentExercise['name'],
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    currentExercise['description'] ?? 'No description provided.',
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
                          'Rest Time: $restSeconds sec',
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton.icon(
                          onPressed: onSkipRest,
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
                      onPressed: onNext,
                      icon: const Icon(Icons.navigate_next),
                      label: Text(isLast ? 'Finish Workout' : 'Next Exercise'),
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
  }
}
