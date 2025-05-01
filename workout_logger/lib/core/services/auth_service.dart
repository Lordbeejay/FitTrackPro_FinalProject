import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';

class AuthService with ChangeNotifier {
  late File _userFile;
  Map<String, dynamic> _users = {};
  String? _currentUser;

  AuthService() {
    _init();
  }

  Future<void> _init() async {
    final dir = await getApplicationDocumentsDirectory();
    _userFile = File('${dir.path}/users.json');

    try {
      if (await _userFile.exists()) {
        final content = await _userFile.readAsString();
        _users = json.decode(content);
      } else {
        // Initialize with default user
        final defaultUser = {
          'josaiah': {
            'password': 'borres',
            'createdAt': DateTime.now().toIso8601String()
          }
        };
        await _userFile.writeAsString(json.encode(defaultUser));
        _users = defaultUser;
      }
    } catch (e) {
      throw Exception('Error initializing user data: $e');
    }
  }

  String? get currentUser => _currentUser;

  Future<bool> login(String username, String password) async {
    if (_users.containsKey(username) &&
        _users[username]['password'] == password) {
      _currentUser = username;
      notifyListeners();
      return true;
    }
    return false;
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  Future<bool> signup({
    required String username,
    required String password,
    required String firstName,
    required String lastName,
    required String email,
    required String gender,
    required String dateOfBirth,
    required String weight,
    required String height,
  }) async {
    if (_users.containsKey(username)) {
      return false;
    }

    _users[username] = {
      'password': password,
      'createdAt': DateTime.now().toIso8601String(),
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'gender': gender,
      'dateOfBirth': dateOfBirth,
      'weight': weight,
      'height': height,
    };

    await _saveUsers();
    return true;
  }

  Future<void> _saveUsers() async {
    try {
      await _userFile.writeAsString(json.encode(_users));
    } catch (e) {
      throw Exception('Error saving users: $e');
    }
  }
}