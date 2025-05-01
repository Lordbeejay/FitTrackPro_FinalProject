import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditableProfileHeader extends StatefulWidget {
  final String username;
  final String initialName;
  final void Function(String) onNameChanged;

  const EditableProfileHeader({
    super.key,
    required this.username,
    required this.initialName,
    required this.onNameChanged,
  });

  @override
  State<EditableProfileHeader> createState() => _EditableProfileHeaderState();
}

class _EditableProfileHeaderState extends State<EditableProfileHeader> {
  bool isEditing = false;
  late TextEditingController _controller;
  File? _image;

  late String nameKey;
  late String imageKey;

  @override
  void initState() {
    super.initState();
    nameKey = '${widget.username}_name';
    imageKey = '${widget.username}_image';
    _controller = TextEditingController();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final savedName = prefs.getString(nameKey) ?? widget.initialName;
    final savedImagePath = prefs.getString(imageKey);

    setState(() {
      _controller.text = savedName;
      if (savedImagePath != null && File(savedImagePath).existsSync()) {
        _image = File(savedImagePath);
      }
    });

    widget.onNameChanged(savedName);
  }

  Future<void> _saveUserData({String? name, String? imagePath}) async {
    final prefs = await SharedPreferences.getInstance();
    if (name != null) await prefs.setString(nameKey, name);
    if (imagePath != null) await prefs.setString(imageKey, imagePath);
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _image = File(picked.path));
      await _saveUserData(imagePath: picked.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        GestureDetector(
          onTap: _pickImage,
          child: CircleAvatar(
            radius: 50,
            backgroundImage: _image != null ? FileImage(_image!) : null,
            child: _image == null
                ? Icon(Icons.person, size: 50, color: theme.colorScheme.onSurface)
                : null,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isEditing)
              SizedBox(
                width: 200,
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: 'Enter name',
                    isDense: true,
                    border: UnderlineInputBorder(),
                  ),
                  onSubmitted: (value) async {
                    await _saveUserData(name: value);
                    widget.onNameChanged(value);
                    setState(() => isEditing = false);
                  },
                  autofocus: true,
                ),
              )
            else
              Text(
                _controller.text,
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
            IconButton(
              icon: Icon(isEditing ? Icons.check : Icons.edit),
              onPressed: () async {
                if (isEditing) {
                  await _saveUserData(name: _controller.text);
                  widget.onNameChanged(_controller.text);
                }
                setState(() => isEditing = !isEditing);
              },
            ),
          ],
        ),
      ],
    );
  }
}