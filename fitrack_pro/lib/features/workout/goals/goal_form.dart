import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitrack_pro/core/services/goal_service.dart';
import 'package:fitrack_pro/core/models/goal.dart';

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
      _titleController.text = widget.goal!.title;
      _descriptionController.text = widget.goal!.description;
      _targetValueController.text = widget.goal!.targetValue.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.goal == null ? 'Create Goal' : 'Edit Goal',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF6A11CB), // Purplish tone
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: SingleChildScrollView(
              child: Card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildTextField(_titleController, 'Goal Title', Icons.title),
                      const SizedBox(height: 16),
                      _buildTextField(_descriptionController, 'Goal Description', Icons.description),
                      const SizedBox(height: 16),
                      _buildTextField(_targetValueController, 'Target Value', Icons.bar_chart, keyboardType: TextInputType.number),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _saveGoal,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            backgroundColor: const Color(0xFF2575FC),
                          ),
                          child: const Text('Save Goal', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _saveGoal() {
    final goalService = Provider.of<GoalService>(context, listen: false);

    if (widget.goal == null) {
      goalService.createGoal(
        _titleController.text,
        _descriptionController.text,
        double.parse(_targetValueController.text),
      );
    } else {
      goalService.updateGoal(
        widget.goal!.id,
        _titleController.text,
        _descriptionController.text,
        double.parse(_targetValueController.text),
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(widget.goal == null ? 'Goal Created 🎯' : 'Goal Updated ✅'),
        duration: const Duration(seconds: 2),
      ),
    );
    Navigator.pop(context);
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.deepPurpleAccent),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.white.withValues(),
      ),
    );
  }
}