import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitrack_pro/core/models/goal.dart';
import 'package:fitrack_pro/core/services/goal_service.dart';

class GoalCard extends StatelessWidget {
  final Goal goal;

  const GoalCard({super.key, required this.goal});

  @override
  Widget build(BuildContext context) {
    final goalService = Provider.of<GoalService>(context, listen: false);

    return Card(
      elevation: 8,
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      color: Colors.white.withValues(),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title & Delete Icon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  goal.title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurpleAccent,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Delete Goal'),
                          content: const Text('Are you sure you want to delete this goal?'),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                            ),
                            TextButton(
                              onPressed: () {
                                goalService.deleteGoal(goal.id);
                                Navigator.of(context).pop();
                              },
                              child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Description
            Text(
              goal.description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 16),
            ),

            const SizedBox(height: 16),

            // Progress Bar with Animated Effect
            Container(
              height: 12,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: const LinearGradient(
                  colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                ),
              ),
              child: Stack(
                children: [
                  Container(
                    width: (goal.currentValue / goal.targetValue) * MediaQuery.of(context).size.width * 0.7,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white.withValues(),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Goal Completion Status
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${goal.currentValue} / ${goal.targetValue} completed',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.deepPurpleAccent),
              ),
            ),
          ],
        ),
      ),
    );
  }
}