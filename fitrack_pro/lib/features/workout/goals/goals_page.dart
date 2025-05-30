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
              child: const Icon(Icons.flag, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            const Text(
              'FitTrack Pro',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Gradient header card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFB299E5), Color(0xFF9DCEFF)],
              ),
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
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.flag, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Your Goals',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          // Add Goal button - outlined style
          Center(
            child: SizedBox(
              width: 200, // Adjust this value as needed for your preferred width
              child: OutlinedButton.icon(
                icon: const Icon(Icons.add_circle_outline, color: Color(0xFF6A11CB)),
                label: const Text(
                  'Add New Goal',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6A11CB),
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFB299E5), width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                ),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => GoalForm(goalService: goalService),
                  );
                },
              ),
            ),
          ),
          // Goals list or empty state
          Expanded(
            child: goals.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.flag_outlined, size: 64, color: Color(0xFFB299E5)),
                        const SizedBox(height: 16),
                        const Text(
                          'No goals yet',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF6A1B9A),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap "Add New Goal" to get started!',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF8E2DE2).withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: goals.length,
                    itemBuilder: (context, index) => GoalCard(goal: goals[index]),
                  ),
          ),
        ],
      ),
    );
  }
}