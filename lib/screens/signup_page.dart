import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/social_login_button.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String? _errorMessage;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

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
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      final error = await authProvider.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        username: _usernameController.text.trim(),
      );

      if (error != null) {
        setState(() => _errorMessage = error);
      } else {
        // Show success message and navigate to login
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Account created successfully! Please login.'),
              ],
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  }

  Future<void> _signupWithGoogle() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    final error = await authProvider.signInWithGoogle();
    if (error != null) {
      setState(() => _errorMessage = error);
    } else {
      // Navigation will be handled automatically by AuthWrapper
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/dashboard', (route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        actions: [
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return IconButton(
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return RotationTransition(
                      turns: animation,
                      child: child,
                    );
                  },
                  child: Icon(
                    themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                    key: ValueKey<bool>(themeProvider.isDarkMode),
                  ),
                ),
                onPressed: () => themeProvider.toggleTheme(),
                tooltip: themeProvider.isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
              );
            },
          ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: AbsorbPointer(
                absorbing: authProvider.isLoading,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.person_add_alt_1_outlined,
                        size: 60,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Create Your Account', 
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Join XTrackr and start managing your finances',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    if (_errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: colorScheme.onErrorContainer,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: TextStyle(color: colorScheme.onErrorContainer),
                              ),
                            ),
                          ],
                        ),
                      ),

                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _usernameController,
                            decoration: InputDecoration(
                              labelText: 'Username',
                              prefixIcon: const Icon(Icons.person_outline),
                              hintText: 'e.g., CoolUser123',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
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
                            decoration: InputDecoration(
                              labelText: 'Email Address',
                              prefixIcon: const Icon(Icons.email_outlined),
                              hintText: 'you@example.com',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
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
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            obscureText: _obscurePassword,
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Please enter a password';
                              if (value.length < 6) return 'Password must be at least 6 characters';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16.0),
                          TextFormField(
                            controller: _confirmPasswordController,
                            decoration: InputDecoration(
                              labelText: 'Confirm Password',
                              prefixIcon: const Icon(Icons.lock_reset_outlined),
                              suffixIcon: IconButton(
                                icon: Icon(_obscureConfirmPassword ? Icons.visibility : Icons.visibility_off),
                                onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            obscureText: _obscureConfirmPassword,
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
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: authProvider.isLoading ? null : _signupWithEmail,
                            child: authProvider.isLoading
                                ? const SizedBox(
                                    height: 24, 
                                    width: 24, 
                                    child: CircularProgressIndicator(
                                      color: Colors.white, 
                                      strokeWidth: 3,
                                    ),
                                  )
                                : const Text(
                                    'Sign Up', 
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
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
                          child: Text(
                            "Or sign up with", 
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ),
                        Expanded(child: Divider(color: Colors.grey[400])),
                      ],
                    ),
                    const SizedBox(height: 24.0),
                    SocialLoginButton(
                      text: 'Sign up with Google',
                      icon: const Icon(Icons.g_mobiledata_outlined, color: Colors.redAccent, size: 28),
                      onPressed: authProvider.isLoading ? (){} : _signupWithGoogle,
                      backgroundColor: colorScheme.surface,
                      textColor: colorScheme.onSurface,
                    ),
                    const SizedBox(height: 24.0),
                    TextButton(
                      onPressed: authProvider.isLoading ? null : () => Navigator.pushReplacementNamed(context, '/login'),
                      child: RichText(
                        text: TextSpan(
                          text: "Already have an account? ",
                          style: TextStyle(color: colorScheme.onSurface.withOpacity(0.7)),
                          children: [
                            TextSpan(
                              text: 'Login',
                              style: TextStyle(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
