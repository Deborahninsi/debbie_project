import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

// Providers
import 'providers/auth_provider.dart';
import 'providers/budget_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/expense_provider.dart';
import 'providers/refresh_provider.dart';

// Screens
import 'screens/welcome_page.dart';
import 'screens/login_page.dart';
import 'screens/signup_page.dart';
import 'screens/dashboard_screen.dart';
import 'screens/setting_page.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/change_password_screen.dart';
import 'screens/add_expense_screen.dart';
import 'screens/transactions_screen.dart';
import 'screens/set_budget_screen.dart';
import 'screens/savings_feature_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const XTrackrApp());
}

class XTrackrApp extends StatelessWidget {
  const XTrackrApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => BudgetProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ExpenseProvider()),
        ChangeNotifierProvider(create: (_) => RefreshProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return MaterialApp(
                title: 'XTrackr',
                debugShowCheckedModeBanner: false,
                theme: themeProvider.themeData,
                home: AuthWrapper(),
                routes: {
                  '/welcome': (context) => const WelcomePage(),
                  '/login': (context) => const LoginPage(),
                  '/signup': (context) => const SignupPage(),
                  '/dashboard': (context) => const DashboardScreen(),
                  '/settings': (context) => const SettingsScreen(),
                  '/edit-profile': (context) => const EditProfileScreen(),
                  '/change-password': (context) => const ChangePasswordScreen(),
                  '/add-expense': (context) => const AddExpenseScreen(),
                  '/transactions': (context) => const TransactionsScreen(),
                  '/set-budget': (context) => const SetBudgetScreen(),
                  '/savings': (context) => const SavingsFeatureScreen(),
                },
              );
            },
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.isAuthenticated) {
          return const DashboardScreen();
        } else {
          return const WelcomePage();
        }
      },
    );
  }
}
