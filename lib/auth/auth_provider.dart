import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:js' as js;

class AuthProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool _isLoggedIn = false;
  bool _isAdmin = false;
  String _errorMessage = '';
  Map<String, dynamic>? _userData;
  User? _user;

  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Getters
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isLoggedIn;
  bool get isLoggedIn => _isLoggedIn;
  bool get isAdmin => _isAdmin;
  String get errorMessage => _errorMessage;
  Map<String, dynamic>? get userData => _userData;
  User? get user => _user;

  // Google Sign In instance
  late GoogleSignIn _googleSignIn;

  // Constructor
  AuthProvider() {
    _initializeGoogleSignIn();
    _checkAuthState();
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  // Initialize Google Sign In
  void _initializeGoogleSignIn() {
    if (kIsWeb) {
      _googleSignIn = GoogleSignIn(
        clientId: '947979021795-l82ch0gmiosdpbob2166o3sfpq3keuuj.apps.googleusercontent.com',
        scopes: ['email', 'profile'],
      );
    } else {
      _googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
      );
    }
  }

  // Check if Google Sign-In is ready (Web only)
  bool _isGoogleSignInReady() {
    if (!kIsWeb) return true;
    
    try {
      return js.context['googleSignInInitialized'] == true;
    } catch (e) {
      return false;
    }
  }

  // Handle Firebase auth state changes
  void _onAuthStateChanged(User? user) async {
    print('Auth state changed: ${user?.uid}');
    _user = user;
    if (user != null) {
      _isLoggedIn = true;
      await _loadUserDataFromFirestore();
      await _checkAdminRole();
    } else {
      _isLoggedIn = false;
      _isAdmin = false;
      _userData = null;
    }
    notifyListeners();
  }

  // Check admin role
  Future<void> _checkAdminRole() async {
    if (_user == null) {
      _isAdmin = false;
      return;
    }

    try {
      final doc = await _firestore.collection('users').doc(_user!.uid).get();
      if (doc.exists) {
        final data = doc.data();
        _isAdmin = data?['role'] == 'admin';
      } else {
        _isAdmin = false;
      }
    } catch (e) {
      print('Error checking admin role: $e');
      _isAdmin = false;
    }
  }

  // Check authentication state on app start
  Future<void> _checkAuthState() async {
    try {
      setLoading(true);
      _user = _auth.currentUser;
      
      if (_user != null) {
        _isLoggedIn = true;
        await _loadUserDataFromFirestore();
        await _checkAdminRole();
      }
      
      setLoading(false);
    } catch (e) {
      print('Error checking auth state: $e');
      setLoading(false);
    }
  }

  // Load user data from Firestore
  Future<void> _loadUserDataFromFirestore() async {
    if (_user == null) return;
    
    try {
      final doc = await _firestore.collection('users').doc(_user!.uid).get();
      if (doc.exists) {
        _userData = doc.data();
        _userData!['uid'] = _user!.uid;
        _userData!['email'] = _user!.email;
        _userData!['name'] = _userData!['name'] ?? _user!.displayName ?? 'User';
      } else {
        await _createUserDocument();
      }
    } catch (e) {
      print('Error loading user data from Firestore: $e');
    }
  }

  // Create user document in Firestore
  Future<void> _createUserDocument() async {
    if (_user == null) return;
    
    try {
      final userData = {
        'uid': _user!.uid,
        'name': _user!.displayName ?? 'User',
        'email': _user!.email ?? '',
        'phone': '',
        'address': '',
        'profileImageBase64': null,
        'authProvider': 'email',
        'platform': kIsWeb ? 'web' : 'mobile',
        'role': 'user', // Default role
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      await _firestore.collection('users').doc(_user!.uid).set(userData);
      _userData = userData;
    } catch (e) {
      print('Error creating user document: $e');
    }
  }

  // Get all users (Admin only)
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    if (!_isAdmin) return [];
    
    try {
      final querySnapshot = await _firestore.collection('users').get();
      return querySnapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data(),
      }).toList();
    } catch (e) {
      print('Error getting users: $e');
      return [];
    }
  }

  // Delete user (Admin only)
  Future<bool> deleteUser(String userId) async {
    if (!_isAdmin) return false;
    
    try {
      await _firestore.collection('users').doc(userId).delete();
      return true;
    } catch (e) {
      print('Error deleting user: $e');
      setError('Failed to delete user: ${e.toString()}');
      return false;
    }
  }

  // Update user role (Admin only)
  Future<bool> updateUserRole(String userId, String role) async {
    if (!_isAdmin) return false;
    
    try {
      await _firestore.collection('users').doc(userId).update({
        'role': role,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error updating user role: $e');
      setError('Failed to update user role: ${e.toString()}');
      return false;
    }
  }

  // Reload user data from Firestore
  Future<void> reloadUserData() async {
    if (_user == null) return;
    
    try {
      await _user!.reload();
      _user = _auth.currentUser;
      await _loadUserDataFromFirestore();
      await _checkAdminRole();
      notifyListeners();
    } catch (e) {
      print('Error reloading user data: $e');
    }
  }

  // Set loading state
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Set error message
  void setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  // Clear error message
  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  // Regular email/password registration
  Future<bool> registerUser({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      setLoading(true);
      clearError();

      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user != null) {
        _user = result.user;
        await _user!.updateDisplayName(name);
        await _createUserDocument();
        _isLoggedIn = true;
        await _checkAdminRole();
        setLoading(false);
        notifyListeners();
        return true;
      }

      setLoading(false);
      return false;
    } catch (e) {
      setError('Registration failed: ${e.toString()}');
      setLoading(false);
      return false;
    }
  }

  // Regular email/password login
 Future<bool> loginUser({
  required String email,
  required String password,
}) async {
  try {
    setLoading(true);
    clearError();

    final UserCredential result = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (result.user != null) {
      _user = result.user;
      await _loadUserDataFromFirestore();
      await _checkAdminRole();
      _isLoggedIn = true;
      setLoading(false);
      notifyListeners(); // This is crucial
      return true;
    }

    setLoading(false);
    return false;
  } catch (e) {
    setError('Login failed: ${e.toString()}');
    setLoading(false);
    return false;
  }
}

  // Google Sign In
  Future<bool> signInWithGoogle() async {
    try {
      setLoading(true);
      clearError();

      // For web, check if Google Sign-In is ready
      if (kIsWeb && !_isGoogleSignInReady()) {
        setError('Google Sign-In not ready. Please refresh the page and try again.');
        setLoading(false);
        return false;
      }

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        setLoading(false);
        return false;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        setError('Failed to get Google authentication tokens');
        setLoading(false);
        return false;
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken!,
        idToken: googleAuth.idToken!,
      );

      final UserCredential result = await _auth.signInWithCredential(credential);
      
      if (result.user != null) {
        _user = result.user;
        
        final userData = {
          'uid': _user!.uid,
          'name': _user!.displayName ?? 'User',
          'email': _user!.email ?? '',
          'phone': '',
          'address': '',
          'profileImageBase64': null,
          'authProvider': 'google',
          'platform': kIsWeb ? 'web' : 'mobile',
          'role': 'user', // Default role
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        };
        
        await _firestore.collection('users').doc(_user!.uid).set(userData, SetOptions(merge: true));
        await _loadUserDataFromFirestore();
        await _checkAdminRole();
        
        _isLoggedIn = true;
        setLoading(false);
        notifyListeners();
        return true;
      }

      setLoading(false);
      return false;
    } catch (e) {
      setError('Google sign-in failed: ${e.toString()}');
      setLoading(false);
      return false;
    }
  }

  // Facebook Sign In
  Future<bool> signInWithFacebook() async {
    try {
      setLoading(true);
      clearError();

      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
      );

      if (result.status == LoginStatus.success && result.accessToken != null) {
        final credential = FacebookAuthProvider.credential(result.accessToken!.tokenString);
        final UserCredential userCredential = await _auth.signInWithCredential(credential);
        
        if (userCredential.user != null) {
          _user = userCredential.user;
          
          final userData = await FacebookAuth.instance.getUserData();
          
          final firestoreUserData = {
            'uid': _user!.uid,
            'name': userData['name'] ?? _user!.displayName ?? 'User',
            'email': userData['email'] ?? _user!.email ?? '',
            'phone': '',
            'address': '',
            'profileImageBase64': null,
            'authProvider': 'facebook',
            'platform': kIsWeb ? 'web' : 'mobile',
            'role': 'user', // Default role
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          };
          
          await _firestore.collection('users').doc(_user!.uid).set(firestoreUserData, SetOptions(merge: true));
          await _loadUserDataFromFirestore();
          await _checkAdminRole();
          
          _isLoggedIn = true;
          setLoading(false);
          notifyListeners();
          return true;
        }
      } else {
        setError('Facebook sign-in failed: ${result.message ?? 'Unknown error'}');
      }

      setLoading(false);
      return false;
    } catch (e) {
      setError('Facebook sign-in failed: ${e.toString()}');
      setLoading(false);
      return false;
    }
  }

  // Reset Password
  Future<bool> resetPassword({required String email}) async {
    try {
      setLoading(true);
      clearError();
      await _auth.sendPasswordResetEmail(email: email);
      setLoading(false);
      return true;
    } catch (e) {
      setError('Password reset failed: ${e.toString()}');
      setLoading(false);
      return false;
    }
  }

  // Sign out from social providers
  Future<void> _signOutFromSocialProviders() async {
    try {
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }
      await FacebookAuth.instance.logOut();
    } catch (e) {
      print('Error signing out from social providers: $e');
    }
  }

  // Logout user
  Future<bool> logoutUser() async {
    try {
      setLoading(true);
      await _signOutFromSocialProviders();
      await _auth.signOut();
      
      _userData = null;
      _user = null;
      _isLoggedIn = false;
      _isAdmin = false;
      
      setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      setError('Logout failed: ${e.toString()}');
      setLoading(false);
      return false;
    }
  }

  // Update user profile
  Future<bool> updateUserProfile({
    String? name,
    String? profileImageBase64,
  }) async {
    try {
      setLoading(true);
      clearError();

      if (_user != null) {
        Map<String, dynamic> updateData = {};
        
        if (name != null) {
          updateData['name'] = name;
          await _user!.updateDisplayName(name);
        }
        
        if (profileImageBase64 != null) {
          updateData['profileImageBase64'] = profileImageBase64;
        }
        
        updateData['updatedAt'] = FieldValue.serverTimestamp();
        await _firestore.collection('users').doc(_user!.uid).update(updateData);
        await reloadUserData();
      }

      setLoading(false);
      return true;
    } catch (e) {
      setError('Profile update failed: ${e.toString()}');
      setLoading(false);
      return false;
    }
  }
}