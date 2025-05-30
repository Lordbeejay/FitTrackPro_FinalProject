import 'dart:math';
import 'package:flutter/material.dart';
import 'roulette_controller.dart';

class WorkoutRoulettePage extends StatefulWidget {
  const WorkoutRoulettePage({super.key});

  @override
  State<WorkoutRoulettePage> createState() => _WorkoutRoulettePageState();
}

class _WorkoutRoulettePageState extends State<WorkoutRoulettePage> {
  final RouletteController _controller = RouletteController();
  double _angle = 0;
  bool _spinning = false;

  void _spinRoulette() {
    if (_spinning) return;
    setState(() {
      _spinning = true;
      _angle = _controller.spin();
    });

    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _controller.selectWorkout();
        _spinning = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = 300.0;
    final workouts = _controller.workouts;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: _angle),
                duration: const Duration(seconds: 2),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      // Wheel
                      CustomPaint(
                        size: Size(size, size),
                        painter: _WheelPainter(
                          workouts: workouts,
                          angle: value,
                        ),
                      ),
                      // Arrow pointer
                      Positioned(
                        top: -55,
                        left: (size / 2) - 60,
                        child: const Icon(
                          Icons.arrow_drop_down,
                          size: 120,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: 200,
                height: 60,
                child: ElevatedButton.icon(
                  onPressed: _spinning ? null : _spinRoulette,
                  icon: const Icon(Icons.casino, size: 32, color: Colors.white),
                  label: const Text(
                    'Spin',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    backgroundColor: const Color(0xFF2575FC),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: Text(
                  _controller.selectedWorkout != null
                      ? 'Workout:\n${_controller.selectedWorkout}'
                      : 'Spin to get a workout!',
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                  key: ValueKey(_controller.selectedWorkout),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WheelPainter extends CustomPainter {
  final List workouts;
  final double angle;
  _WheelPainter({required this.workouts, required this.angle});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final anglePer = 2 * pi / workouts.length;

    final colors = [
      const Color(0xFF6A11CB),
      const Color(0xFF2575FC),
      const Color(0xFFDB4437),
      const Color(0xFFF4B400),
      const Color(0xFF0F9D58),
      const Color(0xFF9C27B0),
      const Color(0xFFFF5722),
      const Color(0xFF795548),
      const Color(0xFF607D8B),
      const Color(0xFFE91E63),
      const Color(0xFF009688),
      const Color(0xFF3F51B5),
    ];

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle - pi / 2);

    // Draw wheel slices
    for (int i = 0; i < workouts.length; i++) {
      final segmentColor = colors[i % colors.length];
      final paint = Paint()
        ..color = segmentColor
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: Offset(0, 0), radius: radius),
        i * anglePer,
        anglePer,
        true,
        paint,
      );
    }

    // Draw center circle
    final centerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(0, 0), 25, centerPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}