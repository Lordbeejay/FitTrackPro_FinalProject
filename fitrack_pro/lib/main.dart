import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitrack_pro/core/services/auth_service.dart';
import 'package:fitrack_pro/core/services/goal_service.dart';
import 'package:fitrack_pro/core/services/xp_service.dart';
import 'package:fitrack_pro/features/dashboard/dashboard_page.dart';
import 'package:fitrack_pro/features/workout/planner/routine_service.dart';
import 'package:fitrack_pro/features/auth/login/login_page.dart';
import 'package:fitrack_pro/features/workout/timer/notification_helper.dart';
import 'package:fitrack_pro/features/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase only for mobile platforms
  if (defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.macOS) {
    await Firebase.initializeApp();
  }

  await NotificationHelper.initialize();

  runApp(const WorkoutApp());
}

class WorkoutApp extends StatefulWidget {
  const WorkoutApp({super.key});

  @override
  State<WorkoutApp> createState() => _WorkoutAppState();
}

class _WorkoutAppState extends State<WorkoutApp> {
  bool _showSplash = true;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => RoutineService()),
        ChangeNotifierProvider(create: (_) => XPService(username: '')),
      ],
      child: Consumer<AuthService>(
        builder: (context, authService, _) {
          final username = authService.currentUser;

          if (_showSplash) {
            return MaterialApp(
              home: SplashScreen(
                onGetStarted: () {
                  setState(() {
                    _showSplash = false;
                  });
                },
              ),
            );
          }

          if (username == null) {
            return MaterialApp(
              title: 'FitTrack Pro',
              theme: ThemeData(primarySwatch: Colors.blue),
              home: LoginPage(authService: authService),
            );
          }

          // Only provide GoalService when user is logged in
          return ChangeNotifierProvider(
            create: (_) => GoalService(userId: username),
            child: MaterialApp(
              title: 'FitTrack Pro',
              theme: ThemeData(primarySwatch: Colors.blue),
              home: DashboardPage(
                username: username,
                authService: authService,
                xpService: Provider.of<XPService>(context, listen: false),
              ),
            ),
          );
        },
      ),
    );
  }
}