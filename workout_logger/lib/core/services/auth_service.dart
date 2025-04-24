import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class AuthService {
  late File _userFile;
  Map<String, dynamic> _users = {};

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

  Future<bool> login(String username, String password) async {
    if (_users.containsKey(username) &&
        _users[username]['password'] == password) {
      return true;
    }
    return false;
  }

  Future<bool> signup(String username, String password) async {
    if (_users.containsKey(username)) {
      return false;
    }

    _users[username] = {
      'password': password,
      'createdAt': DateTime.now().toIso8601String(),
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