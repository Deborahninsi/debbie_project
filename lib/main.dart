import 'package:debbie_project/screens/dashboard_screen.dart';
import 'package:debbie_project/screens/login_page.dart';
import 'package:debbie_project/screens/signup_page.dart';
import 'package:debbie_project/screens/welcome_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Providers
import 'package:debbie_project/providers/budget_provider.dart';

// Screens
import 'package:debbie_project/screens/auth/welcome_page.dart';
import 'package:debbie_project/screens/auth/login_page.dart';
import 'package:debbie_project/screens/auth/signup_page.dart';
import 'package:debbie_project/screens/dashboard/dashboard_screen.dart';
import 'package:debbie_project/screens/edit_profile_screen.dart';
import 'package:debbie_project/screens/change_password_screen.dart';
import 'package:debbie_project/screens/setting_page.dart';
import 'package:debbie_project/screens/add_expense_screen.dart';
import 'package:debbie_project/screens/set_budget_screen.dart';
import 'package:debbie_project/screens/withdraw_screen.dart';
import 'package:debbie_project/screens/transactions_screen.dart';

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
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        useMaterial3: true,
      ),
      initialRoute: '/welcome',
      routes: {
        '/welcome': (context) => const WelcomePage(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
        '/dashboard': (context) => const DashboardScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/edit-profile': (context) => const EditProfileScreen(),
        '/change-password': (context) => const ChangePasswordScreen(),


      },
    );
  }
}
