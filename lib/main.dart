import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nova_clock/screens/main_screen.dart';
import 'package:nova_clock/screens/welcome_screen.dart';
import 'package:nova_clock/services/auth_service.dart';
import 'package:nova_clock/services/notification_service.dart';
import 'package:nova_clock/services/settings_service.dart';
import 'package:nova_clock/utils/theme.dart';

final notificationServiceProvider = Provider((ref) => NotificationService());

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ProviderContainer().read(notificationServiceProvider).init();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch auth state
    final authState = ref.watch(authProvider);
    
    // Watch settings state for theme changes
    final settingsState = ref.watch(settingsProvider);
    
    return MaterialApp(
      title: 'Nova Clock',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.buildLightTheme(accentColorIndex: settingsState.accentColorIndex),
      darkTheme: AppTheme.buildDarkTheme(accentColorIndex: settingsState.accentColorIndex),
      themeMode: settingsState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: authState.isAuthenticated 
          ? const MainScreen() 
          : const WelcomeScreen(),
    );
  }
}