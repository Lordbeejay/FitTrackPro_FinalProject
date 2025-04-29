import 'package:flutter/material.dart';

class XPProgressBar extends StatelessWidget {
  final int currentXP;
  final int level;

  const XPProgressBar({super.key, required this.currentXP, required this.level});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Level $level', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        LinearProgressIndicator(
          value: currentXP / 100,
          minHeight: 10,
          backgroundColor: Colors.grey.shade300,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
        ),
        const SizedBox(height: 4),
        Text('$currentXP / 100 XP'),
      ],
    );
  }
}