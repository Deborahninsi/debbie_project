import 'package:flutter/material.dart';
import '../widgets/social_login_button.dart'; // Import the button

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loginWithEmail() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() => _isLoading = true);
      print('Attempting Email Login...');
      print('Email: ${_emailController.text}');
      print('Password: ${_passwordController.text}');
      await Future.delayed(const Duration(seconds: 2)); // Simulate network

      // TODO: Replace with actual authentication
      if (mounted) Navigator.pushReplacementNamed(context, '/dashboard');

      setState(() => _isLoading = false);
    }
  }

  Future<void> _loginWithGoogle() async {
    setState(() => _isLoading = true);
    print('Attempting Google Login...');
    await Future.delayed(const Duration(seconds: 1)); // Simulate
    if (mounted) Navigator.pushReplacementNamed(context, '/dashboard');
    setState(() => _isLoading = false);
  }

  Future<void> _loginWithFacebook() async {
    setState(() => _isLoading = true);
    print('Attempting Facebook Login...');
    await Future.delayed(const Duration(seconds: 1)); // Simulate
    if (mounted) Navigator.pushReplacementNamed(context, '/dashboard');
    setState(() => _isLoading = false);
  }

  Future<void> _loginWithTwitter() async {
    setState(() => _isLoading = true);
    print('Attempting Twitter Login...');
    await Future.delayed(const Duration(seconds: 1)); // Simulate
    if (mounted) Navigator.pushReplacementNamed(context, '/dashboard');
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login to XTrackr'),
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
                Icon(
                  Icons.track_changes_rounded,
                  size: 60,
                  color: colorScheme.primary,
                ),
                const SizedBox(height: 20),
                Text('Welcome Back!', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 20),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email Address',
                          prefixIcon: Icon(Icons.email_outlined),
                          hintText: 'you@example.com',
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Please enter your email';
                          if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value)) {
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
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Please enter your password';
                          if (value.length < 6) return 'Password must be at least 6 characters';
                          return null;
                        },
                      ),
                      const SizedBox(height: 24.0),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                        onPressed: _isLoading ? null : _loginWithEmail,
                        child: _isLoading && (_emailController.text.isNotEmpty || _passwordController.text.isNotEmpty)
                            ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                            : const Text('Login with Email'),
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
                      child: Text("Or continue with", style: TextStyle(color: Colors.grey[600])),
                    ),
                    Expanded(child: Divider(color: Colors.grey[400])),
                  ],
                ),
                const SizedBox(height: 24.0),
                if (_isLoading && _emailController.text.isEmpty && _passwordController.text.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 16.0),
                    child: CircularProgressIndicator(),
                  ),
                SocialLoginButton(
                  text: 'Sign in with Google',
                  icon: const Icon(Icons.g_mobiledata, color: Colors.redAccent, size: 28),
                  onPressed: _isLoading ? () {} : _loginWithGoogle,
                  backgroundColor: Colors.white,
                  textColor: Colors.black87,
                ),
                const SizedBox(height: 12.0),
                SocialLoginButton(
                  text: 'Sign in with Facebook',
                  icon: const Icon(Icons.facebook, color: Colors.white, size: 24),
                  onPressed: _isLoading ? () {} : _loginWithFacebook,
                  backgroundColor: const Color(0xFF1877F2),
                  textColor: Colors.white,
                ),
                const SizedBox(height: 12.0),
                SocialLoginButton(
                  text: 'Sign in with Twitter',
                  icon: const Icon(Icons.flutter_dash, color: Colors.white, size: 24),
                  onPressed: _isLoading ? () {} : _loginWithTwitter,
                  backgroundColor: const Color(0xFF1DA1F2),
                  textColor: Colors.white,
                ),
                const SizedBox(height: 24.0),
                TextButton(
                  onPressed: _isLoading ? null : () => Navigator.pushReplacementNamed(context, '/signup'),
                  child: const Text('Don\'t have an account? Sign Up'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
