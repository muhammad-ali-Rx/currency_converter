import 'dart:async';

import 'package:currency_converter/auth/auth_provider.dart';
import 'package:currency_converter/screen/login.dart';
import 'package:currency_converter/screen/admin/admin_dashboard.dart';
import 'package:currency_converter/services/alert-service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'screen/mainscreen.dart';
import 'services/customer_care_service.dart';
// Import your splash screen
import 'screen/splash.dart';

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

  // Initialize Customer Care Collections
  try {
    print('🔄 Initializing Customer Care system...');
    await CustomerCareService.initializeCollections();
    print('✅ Customer Care system initialized');
  } catch (e) {
    print('❌ Customer Care initialization error: $e');
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
    
    // Initialize notifications with timeout - FIXED
    final List<Future<bool>> futures = [
      alertService.initNotifications(),
      Future.delayed(const Duration(seconds: 10), () => false), // 10 second timeout
    ];
    
    final notificationsInitialized = await Future.any(futures);
    
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
    
    // Initialize background checking
    try {
      BackgroundAlertChecker.initialize(alertService);
      BackgroundAlertChecker.startChecking();
      print('✅ Background alert checking initialized');
    } catch (e) {
      print('⚠️ Background checking initialization failed: $e');
    }
    
    print('✅ Alert services setup completed');
  } catch (e) {
    print('❌ Alert service initialization error: $e');
    // Continue anyway - app should work without notifications
  }

  // Initialize Feedback Service
  try {
    print('🔄 Initializing feedback service...');
    // The feedback service will auto-initialize when first used
    print('✅ Feedback service ready');
  } catch (e) {
    print('❌ Feedback service initialization error: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AuthProvider(),
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
          scaffoldBackgroundColor: const Color(0xFF0F0F23),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF0F0F23),
            elevation: 0,
            iconTheme: IconThemeData(color: Colors.white),
            titleTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: Colors.white),
            bodyMedium: TextStyle(color: Colors.white),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: const Color(0xFF1A1A2E),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            hintStyle: const TextStyle(color: Color(0xFF8A94A6)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 10, 108, 236),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: const Color.fromARGB(255, 10, 108, 236),
            ),
          ),
        ),
        // Start with AppInitializer instead of UniqueSplashScreen
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
    // Show splash for 5 seconds, then hide it
    Timer(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _showSplash = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Show splash screen first
    if (_showSplash) {
      return const UniqueSplashScreen();
    }

    // After splash, show appropriate screen based on auth state
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        print('🔍 AppInitializer - Auth State Check:');
        print('   Is Authenticated: ${authProvider.isAuthenticated}');
        print('   User: ${authProvider.user?.email}');
        print('   Is Admin: ${authProvider.isAdmin}');

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

// Background Alert Checker Class
class BackgroundAlertChecker {
  static SimpleAlertService? _alertService;
  static bool _isRunning = false;

  static void initialize(SimpleAlertService alertService) {
    _alertService = alertService;
    print('✅ BackgroundAlertChecker initialized');
  }

  static void startChecking() {
    if (_alertService == null) {
      print('❌ Alert service not initialized');
      return;
    }

    if (_isRunning) {
      print('⚠️ Background checking already running');
      return;
    }

    _isRunning = true;
    print('🔄 Starting background alert checking...');
    
    // Check alerts every 5 minutes
    _scheduleNextCheck();
  }

  static void _scheduleNextCheck() {
    if (!_isRunning || _alertService == null) return;

    Future.delayed(const Duration(minutes: 5), () async {
      if (_isRunning && _alertService != null) {
        try {
          print('🔍 Running scheduled alert check...');
          await _alertService!.checkAlerts();
          print('✅ Scheduled alert check completed');
        } catch (e) {
          print('❌ Error in scheduled alert check: $e');
        }
        
        // Schedule next check
        _scheduleNextCheck();
      }
    });
  }

  static void stopChecking() {
    _isRunning = false;
    print('🛑 Background alert checking stopped');
  }

  static bool get isRunning => _isRunning;
}
