import 'package:flutter/material.dart';
import 'package:workout_logger/core/models/user_stats.dart';

class EditableProfileDetails extends StatefulWidget {
  final UserStats stats;
  final void Function(UserStats) onDetailsUpdated;

  const EditableProfileDetails({
    super.key,
    required this.stats,
    required this.onDetailsUpdated,
  });

  @override
  State<EditableProfileDetails> createState() => _EditableProfileDetailsState();
}

class _EditableProfileDetailsState extends State<EditableProfileDetails> {
  late final TextEditingController firstNameController;
  late final TextEditingController lastNameController;
  late final TextEditingController emailController;
  late final TextEditingController genderController;
  late final TextEditingController dobController;
  late final TextEditingController weightController;
  late final TextEditingController heightController;

  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    firstNameController = TextEditingController(text: widget.stats.firstName);
    lastNameController = TextEditingController(text: widget.stats.lastName);
    emailController = TextEditingController(text: widget.stats.email);
    genderController = TextEditingController(text: widget.stats.gender);
    dobController = TextEditingController(text: widget.stats.dateOfBirth);
    weightController = TextEditingController(text: widget.stats.weight);
    heightController = TextEditingController(text: widget.stats.height);
  }

  void _saveDetails() {
    final updated = widget.stats.copyWith(
      firstName: firstNameController.text,
      lastName: lastNameController.text,
      email: emailController.text,
      gender: genderController.text,
      dateOfBirth: dobController.text,
      weight: weightController.text,
      height: heightController.text,
    );
    widget.onDetailsUpdated(updated);
    setState(() => isEditing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildRow("First Name", firstNameController),
        _buildRow("Last Name", lastNameController),
        _buildRow("Email", emailController),
        _buildRow("Gender", genderController),
        _buildRow("Date of Birth", dobController),
        _buildRow("Weight", weightController),
        _buildRow("Height", heightController),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: isEditing ? _saveDetails : () => setState(() => isEditing = true),
          child: Text(isEditing ? 'Save Changes' : 'Edit Profile Info'),
        ),
      ],
    );
  }

  Widget _buildRow(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 120, child: Text(label)),
          Expanded(
            child: TextField(
              controller: controller,
              readOnly: !isEditing,
              decoration: const InputDecoration(isDense: true),
            ),
          ),
        ],
      ),
    );
  }
}