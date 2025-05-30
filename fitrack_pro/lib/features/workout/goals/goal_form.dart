import 'package:flutter/material.dart';
import 'package:fitrack_pro/core/services/goal_service.dart';

class GoalForm extends StatefulWidget {
  final GoalService goalService;
  const GoalForm({super.key, required this.goalService});

  @override
  State<GoalForm> createState() => _GoalFormState();
}

class _GoalFormState extends State<GoalForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _targetController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Add New Goal',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6A11CB),
                ),
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Goal Title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Color(0xFF6A11CB), width: 2),
                  ),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Enter a title' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _descController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Color(0xFF2575FC), width: 2),
                  ),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Enter a description' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _targetController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Target Weight (kg)',
                  suffixText: 'kg',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Color(0xFF6A11CB), width: 2),
                  ),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Enter a target weight' : null,
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF6A11CB),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      widget.goalService.createGoal(
                        _titleController.text.trim(),
                        _descController.text.trim(),
                        double.tryParse(_targetController.text.trim()) ?? 0,
                      );
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text(
                    'Save Goal',
                    style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}