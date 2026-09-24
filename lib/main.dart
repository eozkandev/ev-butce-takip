import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'providers/auth_provider.dart';
import 'providers/budget_provider.dart';
import 'theme/app_theme.dart';
import 'screens/auth_screen.dart';
import 'screens/main_navigation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('tr_TR', null);

  final authProvider = AuthProvider();
  final budgetProvider = BudgetProvider();

  await authProvider.init();
  await budgetProvider.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider.value(value: budgetProvider),
      ],
      child: const EvButceApp(),
    ),
  );
}

class EvButceApp extends StatelessWidget {
  const EvButceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ev Bütçe Takip',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark, // Default to sleek modern dark mode
      home: const RootGateScreen(),
    );
  }
}

class RootGateScreen extends StatelessWidget {
  const RootGateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (!auth.isInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (auth.isLocked) {
      return AuthScreen(
        isInitialSetup: !auth.hasPin,
        onUnlocked: () {
          auth.unlock();
        },
      );
    }

    return const MainNavigationScreen();
  }
}
