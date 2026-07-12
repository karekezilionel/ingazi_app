import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/themes/app_theme.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/home/home_screen.dart';
import 'presentation/screens/startup/startup_dashboard_screen.dart';
import 'presentation/screens/admin/admin_panel_screen.dart';
import 'providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    print('🔍 MyApp build - isAuthenticated: ${authState.isAuthenticated}');
    print('🔍 MyApp build - isAdmin: ${authState.isAdmin}');
    print('🔍 MyApp build - isStartup: ${authState.isStartup}');

    Widget screen;
    if (authState.isLoading) {
      screen = const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
          ),
        ),
      );
    } else if (authState.isAuthenticated) {
      if (authState.isAdmin) {
        print('👑 Navigating to Admin Panel');
        screen = const AdminPanelScreen();
      } else if (authState.isStartup) {
        print('🚀 Navigating to Startup Dashboard');
        screen = const StartupDashboardScreen();
      } else {
        print('📚 Navigating to Home Screen');
        screen = const HomeScreen();
      }
    } else {
      print('❌ Not authenticated, showing Login Screen');
      screen = const LoginScreen();
    }

    return MaterialApp(
      title: 'Ingazi',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: screen,
    );
  }
}