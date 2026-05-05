import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/theme.dart';
import 'screens/login_screen.dart';
import 'screens/map_screen.dart';
import 'screens/alerts_screen.dart';
import 'screens/report_screen.dart';
import 'screens/search_screen.dart';
import 'services/firebase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const SafeCityApp());
}

class SafeCityApp extends StatelessWidget {
  const SafeCityApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SafeCity',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: StreamBuilder(
        stream: FirebaseService.authStateChanges,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(color: AppTheme.accent),
              ),
            );
          }
          return snapshot.hasData
              ? const MapScreen()
              : const LoginScreen();
        },
      ),
      routes: {
        '/home':   (_) => const MapScreen(),
        '/alerts': (_) => const AlertsScreen(),
        '/report': (_) => const ReportScreen(),
        '/search': (_) => const SearchScreen(),
        '/login':  (_) => const LoginScreen(),
      },
    );
  }
}
