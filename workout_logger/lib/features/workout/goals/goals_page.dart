import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'goal_form.dart';
import 'goal_card.dart';
import 'package:workout_logger/core/services/goal_service.dart';

class GoalsPage extends StatelessWidget {
  const GoalsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final goalService = Provider.of<GoalService>(context);
    final goals = goalService.getGoals();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Goals'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: goals.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: GoalCard(goal: goals[index]), // Use GoalCard here
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Open GoalForm when FAB is pressed
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const GoalForm()),
          );
        },
        tooltip: 'Create New Goal',
        child: const Icon(Icons.add),
      ),
    );
  }
}