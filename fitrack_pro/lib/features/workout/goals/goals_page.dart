import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'goal_form.dart';
import 'goal_card.dart';
import 'package:fitrack_pro/core/services/goal_service.dart';

class GoalsPage extends StatelessWidget {
  const GoalsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final goalService = Provider.of<GoalService>(context);
    final goals = goalService.getGoals();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: goals.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: GoalCard(goal: goals[index]), // Modernized goal card
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'addGoal',
        backgroundColor: const Color(0xFF2575FC),
        elevation: 8,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const GoalForm()),
          );
        },
        tooltip: 'Create New Goal',
        child: const Icon(Icons.add, size: 30, color: Colors.white),
      ),
    );
  }
}