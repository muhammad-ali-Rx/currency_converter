import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  User? _user;
  bool _isLoading = true;
  String _errorMessage = '';
  Map<String, dynamic>? _userData;

  // Getters
  User? get user => _user;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  Map<String, dynamic>? get userData => _userData;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _initializeAuth();
  }

  // Initialize auth state
  void _initializeAuth() {
    _auth.authStateChanges().listen((User? user) async {
      _user = user;
      if (user != null) {
        await _loadUserData();
      } else {
        _userData = null;
      }
      _isLoading = false;
      notifyListeners();
    });
  }

  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Set error message
  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  // Load user data from Firestore
  Future<void> _loadUserData() async {
    if (_user != null) {
      try {
        DocumentSnapshot doc = await _firestore.collection('users').doc(_user!.uid).get();
        if (doc.exists) {
          _userData = doc.data() as Map<String, dynamic>;
          print('✅ User data loaded: $_userData'); // Debug log
        } else {
          print('❌ User document does not exist');
        }
      } catch (e) {
        print('❌ Error loading user data: $e');
      }
    }
  }

  // Reload user data (call this after profile updates)
  Future<void> reloadUserData() async {
    if (_user != null) {
      await _loadUserData();
      notifyListeners();
    }
  }

  // Register user
  Future<bool> registerUser({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      clearError();

      print('Attempting to register user: $email'); // Debug log

      // Create user with email and password
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      print('User created successfully: ${userCredential.user?.uid}'); // Debug log

      // Update display name
      await userCredential.user?.updateDisplayName(name);

      // Save user data to Firestore
      await _firestore.collection('users').doc(userCredential.user?.uid).set({
        'uid': userCredential.user?.uid,
        'name': name.trim(),
        'email': email.trim(),
        'phone': '',
        'address': '',
        'profileImageUrl': '',
        'profileImageBase64': '',
        'dateOfBirth': null,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
      });

      print('User data saved to Firestore'); // Debug log

      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      print('Firebase Auth Error: ${e.code} - ${e.message}'); // Debug log
      
      switch (e.code) {
        case 'weak-password':
          _setError('Password is too weak. Please use at least 6 characters.');
          break;
        case 'email-already-in-use':
          _setError('An account already exists with this email address.');
          break;
        case 'invalid-email':
          _setError('Please enter a valid email address.');
          break;
        case 'operation-not-allowed':
          _setError('Email/password accounts are not enabled. Please contact support.');
          break;
        default:
          _setError('Registration failed: ${e.message ?? 'Unknown error'}');
      }
      return false;
    } catch (e) {
      _setLoading(false);
      print('General Error: $e'); // Debug log
      _setError('An unexpected error occurred. Please try again.');
      return false;
    }
  }

  // Login user
  Future<bool> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      clearError();

      print('Attempting to login user: $email'); // Debug log

      // Validate inputs
      if (email.trim().isEmpty || password.trim().isEmpty) {
        _setError('Please enter both email and password.');
        _setLoading(false);
        return false;
      }

      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      print('User logged in successfully: ${userCredential.user?.uid}'); // Debug log

      // Update last login time
      if (userCredential.user != null) {
        await _firestore.collection('users').doc(userCredential.user!.uid).update({
          'lastLogin': FieldValue.serverTimestamp(),
        });
      }

      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      print('Firebase Auth Error: ${e.code} - ${e.message}'); // Debug log
      
      switch (e.code) {
        case 'user-not-found':
          _setError('No account found with this email address. Please sign up first.');
          break;
        case 'wrong-password':
          _setError('Incorrect password. Please try again.');
          break;
        case 'invalid-email':
          _setError('Please enter a valid email address.');
          break;
        case 'user-disabled':
          _setError('This account has been disabled. Please contact support.');
          break;
        case 'too-many-requests':
          _setError('Too many failed attempts. Please try again later.');
          break;
        case 'invalid-credential':
          _setError('Invalid email or password. Please check your credentials.');
          break;
        case 'network-request-failed':
          _setError('Network error. Please check your internet connection.');
          break;
        default:
          _setError('Login failed: ${e.message ?? 'Please check your email and password'}');
      }
      return false;
    } catch (e) {
      _setLoading(false);
      print('General Error: $e'); // Debug log
      _setError('An unexpected error occurred. Please try again.');
      return false;
    }
  }

  // Logout user
  Future<void> logoutUser() async {
    try {
      await _auth.signOut();
      _userData = null;
      clearError();
      print('User logged out successfully'); // Debug log
    } catch (e) {
      print('Logout Error: $e'); // Debug log
      _setError('Logout failed. Please try again.');
    }
  }

  // Reset password
  Future<bool> resetPassword({required String email}) async {
    try {
      _setLoading(true);
      clearError();

      if (email.trim().isEmpty) {
        _setError('Please enter your email address.');
        _setLoading(false);
        return false;
      }

      await _auth.sendPasswordResetEmail(email: email.trim());
      
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      print('Password Reset Error: ${e.code} - ${e.message}'); // Debug log
      
      switch (e.code) {
        case 'user-not-found':
          _setError('No account found with this email address.');
          break;
        case 'invalid-email':
          _setError('Please enter a valid email address.');
          break;
        default:
          _setError('Failed to send reset email: ${e.message ?? 'Unknown error'}');
      }
      return false;
    } catch (e) {
      _setLoading(false);
      print('General Error: $e'); // Debug log
      _setError('An unexpected error occurred. Please try again.');
      return false;
    }
  }

  // Test Firebase connection
  Future<bool> testFirebaseConnection() async {
    try {
      // Try to access Firestore
      await _firestore.collection('test').limit(1).get();
      print('Firebase connection successful'); // Debug log
      return true;
    } catch (e) {
      print('Firebase connection failed: $e'); // Debug log
      return false;
    }
  }
}
