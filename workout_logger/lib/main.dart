import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_logger/core/services/auth_service.dart';
import 'package:workout_logger/core/services/goal_service.dart';
import 'package:workout_logger/core/services/xp_service.dart';
import 'package:workout_logger/features/dashboard/dashboard_page.dart';
import 'package:workout_logger/features/workout/planner/routine_service.dart';
import 'package:workout_logger/features/auth/login/login_page.dart';
import 'package:workout_logger/features/workout/timer/notification_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationHelper.initialize();

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
        ChangeNotifierProvider(create: (_) => XPService(username: '')),
      ],
      child: Consumer<AuthService>(
        builder: (context, authService, _) {
          final username = authService.currentUser;

          return MaterialApp(
            title: 'FitTrack Pro',
            theme: ThemeData(primarySwatch: Colors.blue),
            home: username == null
                ? LoginPage(authService: authService)
                : DashboardPage(
              username: username,
              authService: authService,
              xpService: Provider.of<XPService>(context, listen: false),
            ),
          );
        },
      ),
    );
  }
}