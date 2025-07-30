// landing_page.dart
import 'package:flutter/material.dart';
import 'login_page.dart';
import 'signup_page.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2DC2A4),
      body: SafeArea(
        child: Column(
          children: [
            // Top image gallery (placeholder for now)
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset('assets/images/welcome_collage.png'), // Create a collage image
              ),
            ),

            // Welcome text and description
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  const Text(
                    "Welcome to",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const Text(
                    "Nkwa 💚",
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      "Nkwa is a digital wooden bank that lets you plan and set aside money for things that matter to you",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(radius: 5, backgroundColor: Colors.white),
                      SizedBox(width: 5),
                      CircleAvatar(radius: 5, backgroundColor: Colors.white54),
                      SizedBox(width: 5),
                      CircleAvatar(radius: 5, backgroundColor: Colors.white54),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      children: [
                        ElevatedButton(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignupPage())),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          child: const Text("Create an account", style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 10),
                        OutlinedButton(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginPage())),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white),
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          child: const Text("Login"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
