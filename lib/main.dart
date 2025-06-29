import 'package:currency_converter/auth/auth_provider.dart';
import 'package:currency_converter/screen/login.dart';
import 'package:currency_converter/screen/register.dart';
import 'package:currency_converter/screen/profile_completion_screen.dart';
import 'package:currency_converter/screen/admin/admin_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'screen/splash.dart';
import 'screen/mainscreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Firebase initialization
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully');
  } catch (e) {
    print('Firebase initialization error: $e');
  }

  // System UI settings
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const CurrencyConverterApp());
}

class CurrencyConverterApp extends StatelessWidget {
  const CurrencyConverterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: MaterialApp(
        title: 'Currency Converter',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: const Color.fromARGB(255, 10, 108, 236),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 10, 108, 236),
            secondary: const Color(0xFF44A08D),
            brightness: Brightness.dark,
          ),
          fontFamily: 'Roboto',
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFF0A0A1A),
        ),
        home: const AppInitializer(),
        // Remove all route-related properties to fix the error
      ),
    );
  }
}

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  void _initializeApp() async {
    // Show splash screen for 3 seconds
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      setState(() {
        _showSplash = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return const UniqueSplashScreen();
    }

    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Show loading screen while checking auth state
        if (authProvider.isLoading) {
          return const Scaffold(
            backgroundColor: Color(0xFF0A0A1A),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Color.fromARGB(255, 10, 108, 236),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Loading...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Navigate based on auth state and role
        if (authProvider.isAuthenticated) {
          print('User is authenticated: ${authProvider.user?.uid}');
          // Check if user is admin
          if (authProvider.isAdmin) {
            print('User is admin, showing admin dashboard');
            return const AdminDashboard();
          } else {
            print('User is regular user, showing main screen');
            // Regular user - show main currency converter app
            return const Mainscreen();
          }
        } else {
          print('User is not authenticated, showing login screen');
          // User is not logged in - show login screen
          return const LoginScreen();
        }
      },
    );
  }
}