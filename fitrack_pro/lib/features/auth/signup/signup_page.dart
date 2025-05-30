import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fitrack_pro/core/services/auth_service.dart';
import 'package:fitrack_pro/features/auth/login/login_page.dart';

class SignupPage extends StatelessWidget {
  final AuthService authService;

  const SignupPage({super.key, required this.authService});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFB299E5), Color(0xFF9DCEFF)], // purple left, blue right
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/ftp-logo-white.png',
                    width: 180,
                    height: 180,
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.1,
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
                      child: SignupForm(authService: authService),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LoginPage(authService: authService),
                        ),
                      );
                    },
                    child: const Text(
                      'Already have an account? Login',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
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

class SignupForm extends StatefulWidget {
  final AuthService authService;

  const SignupForm({super.key, required this.authService});

  @override
  State<SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  final _formKey = GlobalKey<FormState>();

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();

  String _selectedGender = 'Prefer not to say';
  DateTime? _selectedDate;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your date of birth')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final success = await widget.authService.signup(
        username: _usernameController.text.trim(),
        password: _passwordController.text.trim(),
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        gender: _selectedGender,
        dateOfBirth: _selectedDate!.toIso8601String(),
        weight: _weightController.text.trim(),
        height: _heightController.text.trim(),
      );

      if (success) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created successfully!')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => LoginPage(authService: widget.authService),
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Username already exists')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating account: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateText = _selectedDate == null
        ? 'Select Date of Birth'
        : DateFormat.yMMMMd().format(_selectedDate!);

    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildTextField(_firstNameController, 'First Name', Icons.person),
          const SizedBox(height: 10),
          _buildTextField(_lastNameController, 'Last Name', Icons.person_outline),
          const SizedBox(height: 10),
          _buildTextField(_emailController, 'Email', Icons.email),
          const SizedBox(height: 10),
          _buildTextField(_usernameController, 'Username', Icons.account_circle),
          const SizedBox(height: 10),
          _buildTextField(_passwordController, 'Password', Icons.lock, obscure: true),
          const SizedBox(height: 10),
          _buildTextField(_confirmPasswordController, 'Confirm Password', Icons.lock_outline, obscure: true),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: _selectedGender,
            items: const [
              DropdownMenuItem(value: 'Male', child: Text('Male')),
              DropdownMenuItem(value: 'Female', child: Text('Female')),
              DropdownMenuItem(value: 'Prefer not to say', child: Text('Prefer not to say')),
            ],
            decoration: InputDecoration(
              labelText: 'Gender',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFF7F53AC), width: 2),
              ),
              prefixIcon: const Icon(Icons.transgender, color: Color(0xFF7F53AC)),
            ),
            onChanged: (value) {
              setState(() {
                _selectedGender = value!;
              });
            },
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => _selectDate(context),
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: 'Date of Birth',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFF7F53AC), width: 2),
                ),
                prefixIcon: const Icon(Icons.cake, color: Color(0xFF7F53AC)),
              ),
              child: Text(dateText),
            ),
          ),
          const SizedBox(height: 10),
          _buildTextField(_weightController, 'Weight (kg)', Icons.monitor_weight),
          const SizedBox(height: 10),
          _buildTextField(_heightController, 'Height (cm)', Icons.height),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: GestureDetector(
              onTap: _isLoading ? null : _signup,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: _isLoading ? 0.7 : 1.0,
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF9DCEFF), Color(0xFFB299E5)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.person_add_alt_1_rounded, color: Colors.white, size: 24),
                              const SizedBox(width: 10),
                              const Text(
                                'Sign Up',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  letterSpacing: 1.1,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool obscure = false}) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF7F53AC), width: 2),
        ),
        prefixIcon: Icon(icon, color: const Color(0xFF7F53AC)),
      ),
      validator: (value) => (value == null || value.isEmpty) ? 'Please enter $label' : null,
    );
  }
}