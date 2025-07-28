import 'package:flutter/material.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF20C997), // Nkwa-style green
      body: Column(
        children: [
          Expanded(
            flex: 4, // Adjust flex to control space for images
            child: Stack(
              children: [
                Positioned(
                  top: MediaQuery.of(context).padding.top + 20, // Consider status bar height
                  left: 20,
                  child: _floatingImage('assets/images/image1.jpg', 100, 130), // Provide your image
                ),
                Positioned(
                  top: MediaQuery.of(context).padding.top + 50, // Consider status bar height
                  right: 20,
                  child: _floatingImage('assets/images/image2.jpg', 100, 130), // Provide your image
                ),
              ],
            ),
          ),
          Expanded(
            flex: 6, // Adjust flex for text and button area
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(flex: 1),
                  const Text(
                    'Welcome to\nDebbyTrack 💚',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'DebbyTrack helps you track your expenses,\nset budgets, and save for what matters most.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                      height: 1.4,
                    ),
                  ),
                  const Spacer(flex: 2),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pushNamed(context, '/signup'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF1A936F), // Darker green
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text('Create an account'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pushNamed(context, '/login'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white, width: 1.5),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          child: const Text('Login'),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(flex: 1),
                  const SizedBox(height: 30), // Bottom padding
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _floatingImage(String path, double width, double height) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.asset(
        path,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          // Placeholder if image fails to load
          return Container(width: width, height: height, color: Colors.grey.shade300, child: const Icon(Icons.broken_image, color: Colors.grey));
        },
      ),
    );
  }
}
