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
    final progress = (goal.currentValue / goal.targetValue).clamp(0.0, 1.0);
    final isLosing = goal.currentValue > goal.targetValue;
    final isReached = goal.currentValue == goal.targetValue;
    final isGain = goal.currentValue < goal.targetValue;
    final diff = (goal.currentValue - goal.targetValue).abs();

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 8), // Reduced horizontal margin
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: const Color(0xFFB299E5).withOpacity(0.4),
          width: 1.3,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title & Edit Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    goal.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Color(0xFF6A11CB),
                    ),
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Color(0xFF6A11CB)),
                      tooltip: 'Edit Goal',
                      onPressed: () async {
                        final nameController = TextEditingController(text: goal.title);
                        final descController = TextEditingController(text: goal.description);
                        final currentController = TextEditingController(text: goal.currentValue.toString());
                        final targetController = TextEditingController(text: goal.targetValue.toString());
                        final result = await showDialog<Map<String, dynamic>>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Edit Goal'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextFormField(
                                  controller: nameController,
                                  decoration: const InputDecoration(
                                    labelText: 'Goal Name',
                                  ),
                                ),
                                TextFormField(
                                  controller: descController,
                                  decoration: const InputDecoration(
                                    labelText: 'Description',
                                  ),
                                ),
                                TextFormField(
                                  controller: currentController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'Current Weight (kg)',
                                    suffixText: 'kg',
                                  ),
                                ),
                                TextFormField(
                                  controller: targetController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'Target Value (kg)',
                                    suffixText: 'kg',
                                  ),
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  final name = nameController.text.trim();
                                  final desc = descController.text.trim();
                                  final current = double.tryParse(currentController.text.trim());
                                  final target = double.tryParse(targetController.text.trim());
                                  if (name.isNotEmpty && desc.isNotEmpty && current != null && target != null) {
                                    Navigator.pop(context, {
                                      'name': name,
                                      'desc': desc,
                                      'current': current,
                                      'target': target,
                                    });
                                  }
                                },
                                child: const Text('Save'),
                              ),
                            ],
                          ),
                        );
                        if (result != null) {
                          goalService.updateGoal(
                            goal.id,
                            result['name'],
                            result['desc'],
                            result['target'],
                          );
                          goalService.updateCurrentValue(goal.id, result['current']);
                          goalService.notifyListeners();
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                      tooltip: 'Delete Goal',
                      onPressed: () {
                        goalService.deleteGoal(goal.id);
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Description
            Text(
              goal.description,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 18),
            // Progress Bar
            Stack(
              children: [
                Container(
                  height: 14,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: const Color(0xFFE0E0E0),
                  ),
                ),
                Container(
                  height: 14,
                  width: MediaQuery.of(context).size.width * 0.6 *
                      (isLosing
                          ? ((goal.currentValue - goal.targetValue).abs() /
                              (goal.currentValue - goal.targetValue > 0
                                  ? goal.currentValue
                                  : goal.targetValue))
                          : progress),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Goal Completion Status
            Align(
              alignment: Alignment.centerRight,
              child: !isReached
                  ? RichText(
                      text: TextSpan(
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        children: [
                          TextSpan(
                            text: 'Current: ',
                            style: const TextStyle(color: Color(0xFF6A11CB)),
                          ),
                          TextSpan(
                            text: '${goal.currentValue} kg ',
                            style: TextStyle(
                              color: isGain ? Colors.orange : Colors.blue,
                            ),
                          ),
                          WidgetSpan(
                            child: Icon(
                              isGain ? Icons.arrow_upward : Icons.arrow_downward,
                              color: isGain ? Colors.orange : Colors.blue,
                              size: 18,
                            ),
                          ),
                          TextSpan(
                            text: '  Target: ',
                            style: const TextStyle(color: Color(0xFF2575FC)),
                          ),
                          TextSpan(
                            text: '${goal.targetValue} kg',
                            style: const TextStyle(color: Color(0xFF2575FC)),
                          ),
                          TextSpan(
                            text: '   (${isGain ? '+' : '-'}${diff.toStringAsFixed(1)} kg)',
                            style: TextStyle(
                              color: isGain ? Colors.orange : Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            // Target Reached Badge
            if (isReached)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6EBF4D), Color(0xFF3D8B2A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Goal Reached!',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}