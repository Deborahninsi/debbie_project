import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:debbie_project/providers/budget_provider.dart';
import 'package:debbie_project/screens/login_page.dart';
import 'package:debbie_project/screens/signup_page.dart';
import 'package:debbie_project/screens/home_page.dart';
import 'package:debbie_project/screens/welcome_page.dart'; // ✅ Import WelcomePage

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => BudgetProvider(),
      child: const XTrackrApp(),
    ),
  );
}

class XTrackrApp extends StatelessWidget {
  const XTrackrApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'XTrackr',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/welcome', // ✅ Set WelcomePage as the initial route
      routes: {
        '/welcome': (context) => WelcomePage(), // ✅ Add welcome route
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}
