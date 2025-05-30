import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class LocalDatabaseService {
  final String fileName = 'users.json';

  // Get local file reference
  Future<File> _getLocalFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$fileName');
  }

  // Load data from file
  Future<Map<String, dynamic>> _readData() async {
    final file = await _getLocalFile();
    if (await file.exists()) {
      final content = await file.readAsString();
      return jsonDecode(content);
    } else {
      return {'users': [], 'workouts': []};
    }
  }

  // Save data to file
  Future<void> _writeData(Map<String, dynamic> data) async {
    final file = await _getLocalFile();
    await file.writeAsString(jsonEncode(data), flush: true);
  }

  // Add a new user if not already present
  Future<void> addUser(String username) async {
    final data = await _readData();
    final users = (data['users'] as List?) ?? [];
    data['users'] = users;

    final userExists = users.any((u) => u['username'] == username);
    if (!userExists) {
      users.add({
        'username': username,
        'joined_at': DateTime.now().toIso8601String(),
        'stats': {
          'totalWorkouts': 0,
          'workoutsPerformed': 0,
          'totalExercises': 0,
          'lastWorkoutName': null,
          'lastWorkoutDate': null,
        }
      });
      await _writeData(data);
      print("Added new user: $username");  // Debugging statement
    }
  }

  Future<void> addWorkout(String username) async {
    print("Adding workout for $username...");
    final data = await _readData();
    final workouts = (data['workouts'] as List?) ?? [];
    data['workouts'] = workouts;

    workouts.add({
      'username': username,
      'completed_at': DateTime.now().toIso8601String(),
    });

    await _writeData(data);
    print("Workout added for $username. Total workouts: ${workouts.length}");
  }

  // Get user stats
  Future<Map<String, dynamic>> getUserStats(String username) async {
    final data = await _readData();
    final users = (data['users'] as List?) ?? [];
    final user = users.cast<Map<String, dynamic>>().firstWhere(
          (u) => u['username'] == username,
      orElse: () => {},
    );


    return user['stats'] ?? {
      'totalWorkouts': 0,
      'workoutsPerformed': 0,
      'totalExercises': 0,
      'lastWorkoutName': null,
      'lastWorkoutDate': null,
    };
  }

  // Get all workouts
  Future<List<dynamic>> getAllWorkouts() async {
    final data = await _readData();
    return (data['workouts'] as List?) ?? [];
  }

  // Ensures the user exists in the database and loads their stats
  Future<Map<String, dynamic>> ensureUserExistsAndLoadStats(String username) async {
    final data = await _readData();
    final users = (data['users'] as List?) ?? [];
    data['users'] = users;

    var user = users.firstWhere(
          (u) => u['username'] == username,
      orElse: () => null,
    );

    if (user != null) {
      final stats = Map<String, dynamic>.from(user['stats'] ?? {});
      print("Stats loaded: $stats");
      return stats;
    }

    // User not found: add and reload
    await addUser(username);
    final updatedData = await _readData();
    final updatedUsers = (updatedData['users'] as List?) ?? [];

    user = updatedUsers.firstWhere((u) => u['username'] == username);
    final stats = Map<String, dynamic>.from(user['stats'] ?? {});
    print("Stats loaded after add: $stats");
    return stats;
  }

  // Sets or updates user stats
  Future<void> setUserStats(String username, Map<String, dynamic> stats) async {
    final data = await _readData();
    final users = (data['users'] as List?) ?? [];
    data['users'] = users;

    final userIndex = users.indexWhere((u) => u['username'] == username);
    if (userIndex != -1) {
      users[userIndex]['stats'] = stats;
      await _writeData(data);
    }
  }
  // Reset user stats to default values
  Future<void> resetUserStats(String username) async {
    final data = await _readData();
    final users = (data['users'] as List?) ?? [];
    data['users'] = users;

    final userIndex = users.indexWhere((u) => u['username'] == username);
    if (userIndex != -1) {
      users[userIndex]['stats'] = {
        'totalWorkouts': 0,
        'workoutsPerformed': 0,
        'totalExercises': 0,
        'lastWorkoutName': null,
        'lastWorkoutDate': null,
      };
      await _writeData(data);
      print("Stats reset for user: $username");  // Debugging statement
    }
  }
}