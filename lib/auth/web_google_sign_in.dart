import 'dart:html' as html;
import 'dart:js' as js;
import 'package:flutter/foundation.dart';

class WebGoogleSignIn {
  static bool get isGoogleInitialized {
    if (!kIsWeb) return false;
    
    try {
      return js.context['googleSignInInitialized'] == true;
    } catch (e) {
      return false;
    }
  }

  static Future<void> waitForGoogleInit() async {
    if (!kIsWeb) return;
    
    int attempts = 0;
    const maxAttempts = 30; // 15 seconds max wait
    
    while (!isGoogleInitialized && attempts < maxAttempts) {
      await Future.delayed(const Duration(milliseconds: 500));
      attempts++;
      print('Waiting for Google Sign-In initialization... Attempt $attempts');
    }
    
    if (!isGoogleInitialized) {
      throw Exception('Google Sign-In failed to initialize after ${maxAttempts * 500}ms');
    }
    
    print('Google Sign-In is ready!');
  }

  static void forceInitialize() {
    if (!kIsWeb) return;
    
    try {
      js.context.callMethod('initializeGoogleSignIn');
    } catch (e) {
      print('Error forcing Google Sign-In initialization: $e');
    }
  }
}
