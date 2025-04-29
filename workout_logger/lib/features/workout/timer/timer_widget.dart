import 'package:flutter/material.dart';

class TimerWidget extends StatelessWidget {
  final int secondsRemaining;
  final bool isRunning;

  const TimerWidget({
    super.key,
    required this.secondsRemaining,
    required this.isRunning,
  });

  @override
  Widget build(BuildContext context) {
    final minutes = (secondsRemaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (secondsRemaining % 60).toString().padLeft(2, '0');

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '$minutes:$seconds',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
            color: isRunning ? Colors.green : Colors.red,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          isRunning ? 'Resting...' : 'Paused',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }
}
