import 'package:currency_converter/auth/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'register.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1A), // Dark theme background
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Stack(
                  children: [
                    Positioned(
                      top: -80,
                      right: -40,
                      child: _buildDecorativeElements(),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 60),
                        _buildHeader(),
                        const SizedBox(height: 40),
                        _buildLoginForm(),
                        const SizedBox(height: 24),
                        _buildSocialButtons(),
                        const SizedBox(height: 24),
                        _buildSignUpLink(),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDecorativeElements() {
    return SizedBox(
      width: 160,
      height: 160,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color.fromARGB(255, 10, 108, 236), Color(0xFF44A08D)], // Updated gradient
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            transform: Matrix4.rotationZ(0.2),
          ),
          Positioned(
            top: 8,
            left: 8,
            right: 8,
            bottom: 8,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF44A08D), Color.fromARGB(255, 10, 108, 236)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              transform: Matrix4.rotationZ(-0.1),
            ),
          ),
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            bottom: 16,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color.fromARGB(255, 10, 108, 236), Color(0xFF44A08D)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              transform: Matrix4.rotationZ(0.05),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        const Text(
          'Currency Converter',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Login to access your personalized\ncurrency conversion experience.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF8A94A6), // Updated text color
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Column(
          children: [
            // Error Message
            if (authProvider.errorMessage.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFEF4444)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        authProvider.errorMessage,
                        style: const TextStyle(
                          color: Color(0xFFEF4444),
                          fontSize: 14,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => authProvider.clearError(),
                      icon: const Icon(Icons.close, color: Color(0xFFEF4444), size: 16),
                    ),
                  ],
                ),
              ),

            // Email Field
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0F0F23), // Dark card background
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF1A1A2E)), // Dark border
              ),
              child: TextFormField(
                controller: _emailController,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  hintText: 'Enter Email',
                  hintStyle: TextStyle(color: Color(0xFF8A94A6)),
                  prefixIcon: Icon(Icons.mail_outline, color: Color(0xFF8A94A6)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  errorStyle: TextStyle(color: Color(0xFFEF4444)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Password Field
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0F0F23),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF1A1A2E)),
              ),
              child: TextFormField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                style: const TextStyle(color: Colors.white),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: 'Password',
                  hintStyle: const TextStyle(color: Color(0xFF8A94A6)),
                  prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF8A94A6)),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                      color: const Color(0xFF8A94A6),
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  errorStyle: const TextStyle(color: Color(0xFFEF4444)),
                ),
              ),
            ),
            const SizedBox(height: 8),
            
            // Forgot Password
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => _showForgotPasswordDialog(context),
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(
                    color: Color(0xFF8A94A6),
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Login Button
            Container(
              width: double.infinity,
              height: 48,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color.fromARGB(255, 10, 108, 236), Color(0xFF44A08D)], // Updated gradient
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(255, 10, 108, 236).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: authProvider.isLoading ? null : _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: authProvider.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Login',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSocialButtons() {
    return Column(
      children: [
        const Text(
          'Or continue with',
          style: TextStyle(
            color: Color(0xFF8A94A6),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF0F0F23),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF1A1A2E)),
                ),
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Google sign-in coming soon!'),
                        backgroundColor: Color.fromARGB(255, 10, 108, 236),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.g_mobiledata, color: Colors.white, size: 24),
                  label: const Text(
                    'Google',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF0F0F23),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF1A1A2E)),
                ),
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Facebook sign-in coming soon!'),
                        backgroundColor: Color.fromARGB(255, 10, 108, 236),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.facebook, color: Colors.white),
                  label: const Text(
                    'Facebook',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSignUpLink() {
    return TextButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const RegisterScreen()),
        );
      },
      child: RichText(
        text: const TextSpan(
          text: 'Don\'t have an account? ',
          style: TextStyle(color: Color(0xFF8A94A6)),
          children: [
            TextSpan(
              text: 'Sign Up',
              style: TextStyle(
                color: Color.fromARGB(255, 10, 108, 236),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      bool success = await authProvider.loginUser(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login successful! Welcome to Currency Converter!'),
            backgroundColor: Color.fromARGB(255, 10, 108, 236),
          ),
        );
      }
    }
  }

  void _showForgotPasswordDialog(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0F0F23),
        title: const Text(
          'Reset Password',
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: emailController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Enter your email',
            hintStyle: TextStyle(color: Color(0xFF8A94A6)),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF1A1A2E)),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color.fromARGB(255, 10, 108, 236)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF8A94A6)),
            ),
          ),
          TextButton(
            onPressed: () async {
              if (emailController.text.isNotEmpty) {
                Navigator.pop(context);
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                bool success = await authProvider.resetPassword(email: emailController.text.trim());
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success ? 'Password reset email sent!' : authProvider.errorMessage),
                      backgroundColor: success ? const Color.fromARGB(255, 10, 108, 236) : const Color(0xFFEF4444),
                    ),
                  );
                }
              }
            },
            child: const Text(
              'Send',
              style: TextStyle(color: Color.fromARGB(255, 10, 108, 236)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
