import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_logger/core/services/auth_service.dart';
import 'package:workout_logger/core/services/goal_service.dart';
import 'package:workout_logger/core/services/xp_service.dart';
import 'package:workout_logger/features/workout/planner/routine_service.dart';
import 'package:workout_logger/features/auth/login/login_page.dart';
import 'package:workout_logger/features/workout/timer/notification_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationHelper.initialize(); // Initialize notifications

  runApp(const WorkoutApp());
}

class WorkoutApp extends StatelessWidget {
  const WorkoutApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => GoalService()),
        ChangeNotifierProvider(create: (_) => RoutineService()),
        Provider<XPService>(
          create: (_) => XPService(username: ""),
        )
      ],
      child: MaterialApp(
        title: 'FitTrack Pro',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: LoginPage(authService: AuthService()), // Start with login page
      ),
    );
  }
}
