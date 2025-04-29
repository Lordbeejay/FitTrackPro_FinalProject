import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_logger/core/models/goal.dart';
import 'package:workout_logger/core/services/goal_service.dart';
import 'package:workout_logger/features/workout/goals/goal_card.dart';
import 'package:workout_logger/features/workout/goals/goals_page.dart';
import 'package:workout_logger/features/workout/planner/routine_model.dart';
import 'package:workout_logger/features/workout/planner/routine_service.dart';

class RoutinePlannerPage extends StatelessWidget {
  const RoutinePlannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final routineService = Provider.of<RoutineService>(context);
    final goalService = Provider.of<GoalService>(context);

    final routines = routineService.getRoutines();
    final goals = goalService.getGoals();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Routine Planner'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: routines.length,
              itemBuilder: (context, index) {
                final routine = routines[index];
                return RoutineCard(routine: routine);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Open RoutineFormPage when FAB is pressed
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RoutineFormPage(goals: goals),
            ),
          );
        },
        tooltip: 'Create New Routine',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class RoutineCard extends StatelessWidget {
  final Routine routine;

  const RoutineCard({super.key, required this.routine});

  @override
  Widget build(BuildContext context) {
    final goal = routine.associatedGoal;

    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(routine.name, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('Days: ${routine.daysOfWeek.join(", ")}'),
            Text('Exercises: ${routine.exercises.join(", ")}'),
            const SizedBox(height: 12),
            GoalCard(goal: goal),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GoalsPage(), // <-- fix parameter
                  ),
                );
              },
              child: const Text('Edit Goal'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                final routineService = Provider.of<RoutineService>(context, listen: false);
                routineService.deleteRoutine(routine.id);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Routine Deleted: ${routine.name}')),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete Routine'),
            ),
          ],
        ),
      ),
    );
  }
}

class RoutineFormPage extends StatefulWidget {
  final List<Goal> goals;

  const RoutineFormPage({super.key, required this.goals});

  @override
  RoutineFormPageState createState() => RoutineFormPageState(); // <-- no underscore
}

class RoutineFormPageState extends State<RoutineFormPage> {
  final _nameController = TextEditingController();
  final _daysController = TextEditingController();
  final _exercisesController = TextEditingController();
  Goal? _selectedGoal;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Routine'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Routine Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _daysController,
              decoration: const InputDecoration(labelText: 'Days (comma separated)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _exercisesController,
              decoration: const InputDecoration(labelText: 'Exercises (comma separated)'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<Goal>(
              value: _selectedGoal,
              hint: const Text('Select Goal'),
              items: widget.goals.map((goal) {
                return DropdownMenuItem<Goal>(
                  value: goal,
                  child: Text(goal.title),
                );
              }).toList(),
              onChanged: (goal) {
                setState(() {
                  _selectedGoal = goal;
                });
              },
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                final routineService = Provider.of<RoutineService>(context, listen: false);
                final goalService = Provider.of<GoalService>(context, listen: false);

                final routine = routineService.createRoutine(
                  _nameController.text,
                  _daysController.text.split(","),
                  _exercisesController.text.split(","),
                  60, // Hardcoded duration for now
                  _selectedGoal ?? goalService.createGoal(
                    'Fitness Goal',
                    'A new fitness goal',
                    10.0,
                  ),
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Routine Created: ${routine.name}')),
                );
                Navigator.pop(context);
              },
              child: const Text('Save Routine'),
            ),
          ],
        ),
      ),
    );
  }
}