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
                home: const AuthWrapper(),
                onGenerateRoute: (settings) {
                  // Route guard - check authentication for protected routes
                  final protectedRoutes = [
                    '/dashboard',
                    '/settings',
                    '/edit-profile',
                    '/change-password',
                    '/add-expense',
                    '/transactions',
                    '/set-budget',
                    '/savings',
                  ];

                  if (protectedRoutes.contains(settings.name) && !authProvider.isAuthenticated) {
                    return MaterialPageRoute(builder: (_) => const WelcomePage());
                  }

                  // Handle routes normally
                  switch (settings.name) {
                    case '/welcome':
                      return MaterialPageRoute(builder: (_) => const WelcomePage());
                    case '/login':
                      return MaterialPageRoute(builder: (_) => const LoginPage());
                    case '/signup':
                      return MaterialPageRoute(builder: (_) => const SignupPage());
                    case '/dashboard':
                      return MaterialPageRoute(builder: (_) => const DashboardScreen());
                    case '/settings':
                      return MaterialPageRoute(builder: (_) => const SettingsScreen());
                    case '/edit-profile':
                      return MaterialPageRoute(builder: (_) => const EditProfileScreen());
                    case '/change-password':
                      return MaterialPageRoute(builder: (_) => const ChangePasswordScreen());
                    case '/add-expense':
                      return MaterialPageRoute(builder: (_) => const AddExpenseScreen());
                    case '/transactions':
                      return MaterialPageRoute(builder: (_) => const TransactionsScreen());
                    case '/set-budget':
                      return MaterialPageRoute(builder: (_) => const SetBudgetScreen());
                    case '/savings':
                      return MaterialPageRoute(builder: (_) => const SavingsFeatureScreen());
                    default:
                      return MaterialPageRoute(builder: (_) => const WelcomePage());
                  }
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
        // Show loading indicator while checking auth state
        if (authProvider.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        // If user is authenticated, show dashboard
        if (authProvider.isAuthenticated && authProvider.user != null) {
          return const DashboardScreen();
        } 
        
        // If not authenticated, show welcome page
        return const WelcomePage();
      },
    );
  }
}
