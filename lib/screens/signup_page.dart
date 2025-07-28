import 'package:flutter/material.dart';
// Removed: import 'package:firebase_auth/firebase_auth.dart';
// Removed: import 'package:debbie_project/services/auth_service.dart';
import 'package:debbie_project/widgets/social_login_button.dart'; // Assuming this widget is defined

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  // Removed: final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  String? _uiErrorMessage; // For displaying UI-related validation or placeholder errors

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signupWithEmail() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save(); // Good practice, though controllers hold the values
      setState(() {
        _isLoading = true;
        _uiErrorMessage = null;
      });

      print('Attempting Email Signup (Placeholder)...');
      print('Username: ${_usernameController.text.trim()}');
      print('Email: ${_emailController.text.trim()}');
      print('Password: ${_passwordController.text.trim()}');

      // TODO: Implement real signup logic here using your AuthService or direct Firebase calls.
      // Example:
      // try {
      //   final authService = AuthService(); // Get instance
      //   final user = await authService.signUpWithEmailAndPassword(
      //     _emailController.text.trim(),
      //     _passwordController.text.trim(),
      //     displayName: _usernameController.text.trim(),
      //   );
      //   if (user != null) {
      //     if (mounted) Navigator.pushReplacementNamed(context, '/home');
      //   } else {
      //      if (mounted) setState(() => _uiErrorMessage = "Signup failed. Please try again.");
      //   }
      // } on FirebaseAuthException catch (e) {
      //    if (mounted) setState(() => _uiErrorMessage = "Error: ${e.message}"); // Or use e.code for specific messages
      // } catch (e) {
      //    if (mounted) setState(() => _uiErrorMessage = "An unexpected error occurred.");
      // }

      // --- Placeholder Logic ---
      await Future.delayed(const Duration(seconds: 2)); // Simulate network request
      if (mounted) {
        // Simulate success for now
        Navigator.pushReplacementNamed(context, '/home');
      }
      // --- End Placeholder Logic ---

      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _signupWithSocial(String provider) async {
    setState(() {
      _isLoading = true;
      _uiErrorMessage = null;
    });

    print('Attempting $provider Signup (Placeholder)...');

    // TODO: Implement real $provider signup logic here using your AuthService or direct Firebase calls.
    // Example for Google:
    // try {
    //   final authService = AuthService(); // Get instance
    //   final user = await authService.signInWithGoogle(); // Or a specific signUpWithGoogle
    //   if (user != null) {
    //      if (mounted) Navigator.pushReplacementNamed(context, '/home');
    //   } else {
    //      if (mounted) setState(() => _uiErrorMessage = "$provider signup cancelled or failed.");
    //   }
    // } catch (e) {
    //   if (mounted) setState(() => _uiErrorMessage = "Error with $provider: ${e.toString()}");
    // }


    // --- Placeholder Logic ---
    await Future.delayed(const Duration(seconds: 1)); // Simulate network request
    if (mounted) {
      // Simulate success for now
      Navigator.pushReplacementNamed(context, '/home');
    }
    // --- End Placeholder Logic ---

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: AbsorbPointer(
            absorbing: _isLoading,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.person_add_alt_1_outlined, size: 60, color: colorScheme.primary),
                const SizedBox(height: 20),
                Text('Create Your Account', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 20),

                if (_uiErrorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15.0),
                    child: Text(
                      _uiErrorMessage!,
                      style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),

                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          labelText: 'Username',
                          prefixIcon: Icon(Icons.person_outline),
                          hintText: 'e.g., CoolUser123',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Please enter a username';
                          if (value.length < 3) return 'Username must be at least 3 characters';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email Address',
                          prefixIcon: Icon(Icons.email_outlined),
                          hintText: 'you@example.com',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Please enter your email';
                          if (!RegExp(r"^[\w\-\.]+@([\w-]+\.)+[\w-]{2,4}$").hasMatch(value)) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: _passwordController,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock_outline),
                          border: OutlineInputBorder(),
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Please enter a password';
                          if (value.length < 6) return 'Password must be at least 6 characters';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: _confirmPasswordController,
                        decoration: const InputDecoration(
                          labelText: 'Confirm Password',
                          prefixIcon: Icon(Icons.lock_reset_outlined),
                          border: OutlineInputBorder(),
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Please confirm your password';
                          if (value != _passwordController.text) return 'Passwords do not match';
                          return null;
                        },
                      ),
                      const SizedBox(height: 24.0),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: _isLoading ? null : _signupWithEmail,
                        child: (_isLoading && (_emailController.text.isNotEmpty || _usernameController.text.isNotEmpty)) // Basic check for email signup attempt
                            ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                            : const Text('Sign Up with Email', style: TextStyle(fontSize: 16)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24.0),
                Row(
                  children: <Widget>[
                    Expanded(child: Divider(color: Colors.grey[400])),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Text("Or sign up with", style: TextStyle(color: Colors.grey[600])),
                    ),
                    Expanded(child: Divider(color: Colors.grey[400])),
                  ],
                ),
                const SizedBox(height: 24.0),

                // General loader for social logins, if email/username fields are empty during loading
                if (_isLoading && _emailController.text.isEmpty && _usernameController.text.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 16.0),
                    child: CircularProgressIndicator(),
                  ),

                SocialLoginButton( // Ensure this widget is defined in debbie_project/widgets/social_login_button.dart
                  text: 'Sign up with Google',
                  icon: const Icon(Icons.g_mobiledata_outlined, color: Colors.redAccent, size: 28),
                  onPressed: _isLoading ? (){} : () => _signupWithSocial('Google'),
                  backgroundColor: Colors.white,
                  textColor: Colors.black87,
                ),
                const SizedBox(height: 12.0),
                SocialLoginButton(
                  text: 'Sign up with Facebook',
                  icon: const Icon(Icons.facebook, color: Colors.white, size: 24),
                  onPressed: _isLoading ? (){} : () => _signupWithSocial('Facebook'),
                  backgroundColor: const Color(0xFF1877F2),
                  textColor: Colors.white,
                ),
                const SizedBox(height: 12.0),
                SocialLoginButton(
                  text: 'Sign up with Twitter',
                  icon: const Icon(Icons.flutter_dash, color: Colors.white, size: 24),
                  onPressed: _isLoading ? (){} : () => _signupWithSocial('Twitter'),
                  backgroundColor: const Color(0xFF1DA1F2),
                  textColor: Colors.white,
                ),
                const SizedBox(height: 24.0),
                TextButton(
                  onPressed: _isLoading ? null : () => Navigator.pushReplacementNamed(context, '/login'),
                  child: const Text('Already have an account? Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
