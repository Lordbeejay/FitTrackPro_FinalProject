import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_logger/core/models/goal.dart';
import 'package:workout_logger/core/services/goal_service.dart';

class GoalCard extends StatelessWidget {
  final Goal goal;

  const GoalCard({super.key, required this.goal});

  @override
  Widget build(BuildContext context) {
    final goalService = Provider.of<GoalService>(context, listen: false);

    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  goal.title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    // Confirm goal deletion
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Delete Goal'),
                          content: const Text('Are you sure you want to delete this goal?'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(); // Close the dialog
                              },
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                goalService.deleteGoal(goal.id);
                                Navigator.of(context).pop(); // Close the dialog
                              },
                              child: const Text('Delete'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
            Text(goal.description),
            SizedBox(height: 12),
            LinearProgressIndicator(
              value: goal.currentValue / goal.targetValue,
              backgroundColor: Colors.grey[300],
              color: Colors.green,
            ),
            SizedBox(height: 8),
            Text(
              '${goal.currentValue} / ${goal.targetValue} completed',
              style: TextStyle(color: Colors.green),
            ),
          ],
        ),
      ),
    );
  }
}