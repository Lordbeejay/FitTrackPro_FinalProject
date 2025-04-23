import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

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
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      home: const LoginPage(),
    );
  }
}

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
        // Create file if it doesn't exist
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
      rethrow;
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

class WorkoutHomePage extends StatefulWidget {
  final String username;

  const WorkoutHomePage({super.key, required this.username});

  @override
  State<WorkoutHomePage> createState() => _WorkoutHomePageState();
}

class _WorkoutHomePageState extends State<WorkoutHomePage> {
  List<Map<String, dynamic>> _workouts = [];
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadWorkouts();
  }

  Future<File> get _workoutFile async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/workouts_${widget.username}.json');
  }

  Future<void> _loadWorkouts() async {
    try {
      final file = await _workoutFile;
      if (await file.exists()) {
        final content = await file.readAsString();
        setState(() {
          _workouts = List<Map<String, dynamic>>.from(json.decode(content));
        });
      }
    } catch (e) {
      debugPrint("Error loading workouts: $e");
    }
  }

  Future<void> _saveWorkouts() async {
    final file = await _workoutFile;
    await file.writeAsString(json.encode(_workouts));
  }

  void _addWorkout() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => WorkoutDialog(),
    );

    if (result != null) {
      setState(() {
        _workouts.insert(0, result);
      });
      await _saveWorkouts();
    }
  }

  void _deleteWorkout(int index) async {
    setState(() {
      _workouts.removeAt(index);
    });
    await _saveWorkouts();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FitTrack Pro'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
          ),
        ],
      ),
      body: _selectedIndex == 0 ? _buildHomeScreen() : _buildProfileScreen(),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
        onPressed: _addWorkout,
        tooltip: 'Add Workout',
        child: const Icon(Icons.add),
      )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildHomeScreen() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: const Text(
            'Recent Workouts',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: _workouts.isEmpty
              ? const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.fitness_center, size: 100, color: Colors.grey),
                SizedBox(height: 20),
                Text(
                  'No workouts recorded yet',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 10),
                Text(
                  'Tap the + button to add your first workout!',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          )
              : ListView.builder(
            itemCount: _workouts.length,
            itemBuilder: (context, index) {
              final workout = _workouts[index];
              return Dismissible(
                key: Key(workout['id'].toString()),
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (direction) => _deleteWorkout(index),
                child: Card(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: _getWorkoutIcon(workout['type']),
                    title: Text(
                      workout['type'],
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(workout['description']),
                        const SizedBox(height: 5),
                        Text(
                          workout['date'],
                          style: const TextStyle(color: Colors.grey),
                        ),
                        if (workout['duration'] != null)
                          Text(
                            'Duration: ${workout['duration']} mins',
                            style: const TextStyle(color: Colors.blue),
                          ),
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (workout['calories'] != null)
                          Text(
                            '${workout['calories']} cal',
                            style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatCard(
                title: 'Workouts this week',
                value: _workouts
                    .where((w) => DateTime.parse(w['date'])
                    .isAfter(DateTime.now().subtract(const Duration(days: 7))))
                    .length
                    .toString(),
              ),
              _buildStatCard(
                title: 'Total Calories',
                value: _workouts
                    .fold<double>(0, (sum, item) => sum + (item['calories'] ?? 0))
                    .toStringAsFixed(0),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircleAvatar(
            radius: 50,
            child: Icon(Icons.person, size: 50),
          ),
          const SizedBox(height: 20),
          Text(
            'Welcome, ${widget.username}',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            'Total Workouts: ${_workouts.length}',
            style: const TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({required String title, required String value}) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Icon _getWorkoutIcon(String type) {
    switch (type.toLowerCase()) {
      case 'running':
        return const Icon(Icons.directions_run, size: 40);
      case 'weightlifting':
        return const Icon(Icons.fitness_center, size: 40);
      case 'yoga':
        return const Icon(Icons.self_improvement, size: 40);
      case 'swimming':
        return const Icon(Icons.pool, size: 40);
      case 'cycling':
        return const Icon(Icons.directions_bike, size: 40);
      default:
        return const Icon(Icons.fitness_center, size: 40);
    }
  }
}

class WorkoutDialog extends StatefulWidget {
  const WorkoutDialog({super.key});

  @override
  _WorkoutDialogState createState() => _WorkoutDialogState();
}

class _WorkoutDialogState extends State<WorkoutDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _caloriesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _dateController.text = DateTime.now().toString().split(' ')[0];
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Workout'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _typeController,
                decoration: const InputDecoration(
                  labelText: 'Type',
                  hintText: 'e.g., Running, Weightlifting',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter workout type';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'e.g., 5km run in the park',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dateController,
                decoration: const InputDecoration(
                  labelText: 'Date',
                  hintText: 'YYYY-MM-DD',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter workout date';
                  }
                  try {
                    DateTime.parse(value);
                    return null;
                  } catch (e) {
                    return 'Invalid date format';
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _durationController,
                decoration: const InputDecoration(
                  labelText: 'Duration (minutes)',
                  hintText: 'e.g., 30',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _caloriesController,
                decoration: const InputDecoration(
                  labelText: 'Calories Burned',
                  hintText: 'e.g., 250',
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final workout = {
                'id': DateTime.now().millisecondsSinceEpoch,
                'type': _typeController.text,
                'description': _descriptionController.text,
                'date': _dateController.text,
                'duration': _durationController.text.isNotEmpty
                    ? int.parse(_durationController.text)
                    : null,
                'calories': _caloriesController.text.isNotEmpty
                    ? double.parse(_caloriesController.text)
                    : null,
              };
              Navigator.of(context).pop(workout);
            }
          },
          child: const Text('Add Workout'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _typeController.dispose();
    _descriptionController.dispose();
    _dateController.dispose();
    _durationController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }
}