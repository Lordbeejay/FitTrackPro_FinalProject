import 'dart:math';
import 'package:flutter/material.dart';
import 'roulette_controller.dart';

void _drawSegmentText(Canvas canvas, String text, double startAngle,
    double sweepAngle, double radius) {
  canvas.save();

  final textStyle = TextStyle(
    color: Colors.white,
    fontSize: 13,
    fontWeight: FontWeight.bold,
    shadows: [
      Shadow(
        blurRadius: 2,
        color: Colors.black54,
        offset: Offset(1, 1),
      ),
    ],
  );

  final textPainter = TextPainter(
    text: TextSpan(text: text, style: textStyle),
    textDirection: TextDirection.ltr,
  );
  textPainter.layout();

  final textWidth = textPainter.width;
  final textHeight = textPainter.height;
  final centerAngle = startAngle + sweepAngle / 2;
  final textRadius = radius * 0.6;
  final x = cos(centerAngle) * textRadius;
  final y = sin(centerAngle) * textRadius;

  canvas.translate(x, y);
  canvas.rotate(centerAngle);

  if (centerAngle > pi / 2 && centerAngle < 3 * pi / 2) {
    canvas.rotate(pi);
  }

  textPainter.paint(canvas, Offset(-textWidth / 2, -textHeight / 2));

  canvas.restore();
}

class WorkoutRoulettePage extends StatefulWidget {
  const WorkoutRoulettePage({Key? key}) : super(key: key);

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
      appBar: AppBar(
        title: const Text('Workout Roulette'),
      ),
      body: Center(
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
                    // wheel
                    CustomPaint(
                      size: Size(size, size),
                      painter: _WheelPainter(
                        workouts: workouts,
                        angle: value,
                      ),
                    ),
                    // arrow pointer
                    Positioned(
                      top: -55,
                      left: (size / 2) - 60,
                      child: Icon(
                        Icons.arrow_drop_down,
                        size: 120,
                        color: Colors.black,
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
                icon: Icon(Icons.casino, size: 32),
                label: const Text(
                  'Spin',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _controller.selectedWorkout != null
                  ? 'Workout:\n${_controller.selectedWorkout}'
                  : 'Spin to get a workout!',
              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
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
      Color(0xFF4285F4),
      Color(0xFFDB4437),
      Color(0xFFF4B400),
      Color(0xFF0F9D58),
      Color(0xFF9C27B0),
      Color(0xFFFF5722),
      Color(0xFF795548),
      Color(0xFF607D8B),
      Color(0xFFE91E63),
      Color(0xFF009688),
      Color(0xFF3F51B5),
      Color(0xFFFF9800),
    ];

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle - pi / 2);

    // slices
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

      // slices border
      final borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;

      canvas.drawArc(
        Rect.fromCircle(center: Offset(0, 0), radius: radius),
        i * anglePer,
        anglePer,
        true,
        borderPaint,
      );
    }

    // text on each slices
    for (int i = 0; i < workouts.length; i++) {
      _drawSegmentText(
        canvas,
        workouts[i].name,
        i * anglePer,
        anglePer,
        radius,
      );
    }

    // center circle
    final centerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(0, 0), 25, centerPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
