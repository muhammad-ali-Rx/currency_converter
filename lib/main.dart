import 'package:currency_converter/auth/auth_provider.dart';
import 'package:currency_converter/screen/login.dart';
import 'package:currency_converter/screen/admin/admin_dashboard.dart';
import 'package:currency_converter/services/alert-service.dart';
import 'package:currency_converter/services/simple-background-service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'screen/splash.dart';
import 'screen/mainscreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('🚀 Starting app initialization...');
  
  // Firebase initialization
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized successfully');
  } catch (e) {
    print('❌ Firebase initialization error: $e');
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

  // Initialize Alert Services with proper error handling
  try {
    print('🔄 Initializing alert services...');
    
    final alertService = SimpleAlertService();
    
    // Initialize notifications with timeout
    final notificationsInitialized = await Future.any([
      alertService.initNotifications(),
      Future.delayed(const Duration(seconds: 10), () => false), // 10 second timeout
    ]);
    
    if (notificationsInitialized) {
      print('✅ Notifications initialized successfully');
      
      // Test notification after a delay
      Future.delayed(const Duration(seconds: 2), () async {
        try {
          final testResult = await alertService.testNotification();
          print('🧪 Test notification result: $testResult');
        } catch (e) {
          print('⚠️ Test notification failed: $e');
        }
      });
      
    } else {
      print('⚠️ Notifications initialization failed or timed out');
    }
    
    // Initialize background service
    try {
      SimpleBackgroundService.initialize();
      SimpleBackgroundService.startChecking();
      print('✅ Background service initialized');
    } catch (e) {
      print('⚠️ Background service initialization failed: $e');
    }
    
    print('✅ Alert services setup completed');
  } catch (e) {
    print('❌ Alert service initialization error: $e');
    // Continue anyway - app should work without notifications
  }

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
  void dispose() {
    // Clean up background service when app is disposed
    try {
      SimpleBackgroundService.stopChecking();
    } catch (e) {
      print('Error stopping background service: $e');
    }
    super.dispose();
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
          print('✅ User is authenticated: ${authProvider.user?.uid}');
          // Check if user is admin
          if (authProvider.isAdmin) {
            print('👑 User is admin, showing admin dashboard');
            return const AdminDashboard();
          } else {
            print('👤 User is regular user, showing main screen');
            // Regular user - show main currency converter app
            return const Mainscreen();
          }
        } else {
          print('🔐 User is not authenticated, showing login screen');
          // User is not logged in - show login screen
          return const LoginScreen();
        }
      },
    );
  }
}
