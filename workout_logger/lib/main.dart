import 'package:flutter/material.dart';
import 'package:workout_logger/core/services/auth_service.dart';
import 'package:workout_logger/features/auth/login/login_page.dart';

void main() {
  runApp(const WorkoutApp());
}

class WorkoutApp extends StatelessWidget {
  const WorkoutApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitTrack Pro',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(authService: AuthService()),
    );
  }
}