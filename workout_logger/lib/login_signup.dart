import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'workout_tracker.dart'; // Import workout tracker page

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  late File _userFile;
  Map<String, dynamic> _users = {};

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final dir = await getApplicationDocumentsDirectory();
    _userFile = File('${dir.path}/users.json');

    try {
      if (await _userFile.exists()) {
        final content = await _userFile.readAsString();
        setState(() {
          _users = json.decode(content);
        });
      } else {
        Map<String, dynamic> defaultUser = {
          'josaiah': {
            'password': 'borres',
            'createdAt': DateTime.now().toIso8601String()
          }
        };
        await _userFile.writeAsString(json.encode(defaultUser));
        setState(() {
          _users = defaultUser;
        });
      }
    } catch (e) {
      debugPrint("Error loading/creating users.json: $e");
      _showMessage('Error loading user data');
    }
  }

  Future<void> _saveUsers() async {
    try {
      await _userFile.writeAsString(json.encode(_users));
      debugPrint('Users saved successfully');
    } catch (e) {
      debugPrint('Error saving users: $e');
      throw e;
    }
  }

  void _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    await Future.delayed(const Duration(milliseconds: 500));

    try {
      if (_users.containsKey(username) &&
          _users[username]['password'] == password) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => WorkoutHomePage(username: username),
          ),
        );
      } else {
        _showMessage('Invalid username or password');
      }
    } catch (e) {
      _showMessage('Error during login: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _signup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    await Future.delayed(const Duration(milliseconds: 500));

    try {
      if (_users.containsKey(username)) {
        _showMessage('Username already exists');
      } else if (username.isEmpty || password.isEmpty) {
        _showMessage('Please enter both username and password');
      } else {
        _users[username] = {
          'password': password,
          'createdAt': DateTime.now().toIso8601String(),
        };
        await _saveUsers();
        _showMessage('Account created successfully!');
        _usernameController.clear();
        _passwordController.clear();
        await _loadUsers();
      }
    } catch (e) {
      _showMessage('Error creating account: $e');
      debugPrint('Signup error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.fitness_center,
                      size: 60,
                      color: Color(0xFF2575FC),
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'FitTrack Pro',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Track your fitness journey',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _usernameController,
                              decoration: InputDecoration(
                                labelText: 'Username',
                                prefixIcon: const Icon(Icons.person),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter username';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 15),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: true,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                prefixIcon: const Icon(Icons.lock),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter password';
                                }
                                if (value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _login,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 15),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: _isLoading
                                    ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                                    : const Text(
                                  'Login',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextButton(
                              onPressed: _isLoading ? null : _signup,
                              child: const Text(
                                'Create new account',
                                style: TextStyle(
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
