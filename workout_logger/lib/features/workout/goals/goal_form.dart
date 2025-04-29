import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_logger/core/services/goal_service.dart';
import 'package:workout_logger/core/models/goal.dart';

class GoalForm extends StatefulWidget {
  final Goal? goal; // If null → creating new, else → editing

  const GoalForm({super.key, this.goal});

  @override
  State<GoalForm> createState() => _GoalFormState();
}

class _GoalFormState extends State<GoalForm> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _targetValueController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.goal != null) {
      // If editing an existing goal, pre-populate the form fields
      _titleController.text = widget.goal!.title;
      _descriptionController.text = widget.goal!.description;
      _targetValueController.text = widget.goal!.targetValue.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.goal == null ? 'Create Goal' : 'Edit Goal'),
        actions: [
          // Back button to go back to the dashboard
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.pop(context); // Go back to the dashboard (or previous screen)
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Goal Title'),
            ),
            SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Goal Description'),
            ),
            SizedBox(height: 12),
            TextField(
              controller: _targetValueController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Target Value'),
            ),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                final goalService = Provider.of<GoalService>(context, listen: false);

                if (widget.goal == null) {
                  // Create a new goal
                  goalService.createGoal(
                    _titleController.text,
                    _descriptionController.text,
                    double.parse(_targetValueController.text),
                  );
                } else {
                  // Update an existing goal
                  goalService.updateGoal(
                    widget.goal!.id,
                    _titleController.text,
                    _descriptionController.text,
                    double.parse(_targetValueController.text),
                  );
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(widget.goal == null ? 'Goal Created' : 'Goal Updated')),
                );
                Navigator.pop(context); // Close the form and return to the previous screen
              },
              child: Text(widget.goal == null ? 'Save Goal' : 'Update Goal'),
            )
          ],
        ),
      ),
    );
  }
}