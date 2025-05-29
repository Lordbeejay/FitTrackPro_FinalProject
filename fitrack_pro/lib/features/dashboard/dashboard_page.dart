import 'package:flutter/material.dart';
import 'package:fitrack_pro/features/workout/homepage/workout_home_page.dart';
import 'package:fitrack_pro/features/workout/goals/goals_page.dart';
import 'package:fitrack_pro/features/workout/planner/routine_planner_page.dart';
import 'package:fitrack_pro/features/profile/profile_page.dart';
import 'package:fitrack_pro/features/auth/login/login_page.dart';
import 'package:fitrack_pro/core/services/auth_service.dart';
import 'package:fitrack_pro/core/services/xp_service.dart';
import 'package:fitrack_pro/features/workout/roulette/workout_roulette_page.dart';

class DashboardPage extends StatefulWidget {
  final String username;
  final AuthService authService;
  final XPService xpService;

  const DashboardPage({
    required this.username,
    required this.authService,
    required this.xpService,
    super.key,
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;
  late final XPService _xpService;

  @override
  void initState() {
    super.initState();
    _xpService = XPService(username: widget.username);
  }

  void _onItemTapped(int index) {
    if (index != _selectedIndex) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  Future<void> _confirmLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout == true && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => LoginPage(authService: widget.authService),
        ),
      );
    }
  }

  Widget _getSelectedPage() {
    switch (_selectedIndex) {
      case 0:
        return WorkoutHomePage(
          username: widget.username,
          authService: widget.authService,
          xpService: _xpService,
        );
      case 1:
        return GoalsPage();
      case 2:
        return WorkoutRoulettePage();
      case 3:
        return RoutinePlannerPage();
      case 4:
        return ProfilePage(
          username: widget.username,
          onLogout: _confirmLogout,
          lastWorkoutName: 'None yet', // can be updated dynamically later
          totalExercises: 0,
          totalWorkouts: 0,
        );
      default:
        return const Center(child: Text('Unknown Page'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getSelectedPage(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.flag), label: 'Goals'),
          BottomNavigationBarItem(icon: Icon(Icons.casino), label: 'Roulette'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today), label: 'Planner'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
