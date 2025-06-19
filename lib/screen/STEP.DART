import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:currency_converter/auth/auth_provider.dart';

class ProfileCompletionScreen extends StatefulWidget {
  const ProfileCompletionScreen({Key? key}) : super(key: key);

  @override
  State<ProfileCompletionScreen> createState() => _ProfileCompletionScreenState();
}

class _ProfileCompletionScreenState extends State<ProfileCompletionScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _ageController = TextEditingController();
  
  File? _selectedImage;
  Uint8List? _webImage;
  bool _isLoading = false;
  DateTime? _selectedDate; // Added for date of birth
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: _buildContent(),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildWelcomeHeader(),
            const SizedBox(height: 40),
            _buildProfileImageSection(),
            const SizedBox(height: 32),
            _buildFormFields(),
            const SizedBox(height: 40),
            _buildCompleteButton(),
            const SizedBox(height: 20),
            _buildSkipButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(50),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4ECDC4).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.person_add,
                size: 40,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Welcome ${authProvider.userData?['name'] ?? 'User'}! 👋',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'Let\'s complete your profile to get started with the best experience',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF718096),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        );
      },
    );
  }

  Widget _buildProfileImageSection() {
    return Column(
      children: [
        const Text(
          'Add Your Photo',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: _hasImage() 
                  ? null 
                  : const LinearGradient(
                      colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4ECDC4).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: _hasImage() 
                ? ClipOval(child: _buildImageWidget())
                : const Icon(
                    Icons.camera_alt,
                    size: 50,
                    color: Colors.white,
                  ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _hasImage() ? 'Tap to change photo' : 'Tap to add photo',
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF718096),
          ),
        ),
      ],
    );
  }

  Widget _buildImageWidget() {
    if (kIsWeb && _webImage != null) {
      return Image.memory(
        _webImage!,
        width: 140,
        height: 140,
        fit: BoxFit.cover,
      );
    } else if (!kIsWeb && _selectedImage != null) {
      return Image.file(
        _selectedImage!,
        width: 140,
        height: 140,
        fit: BoxFit.cover,
      );
    }
    return const SizedBox();
  }

  bool _hasImage() {
    return (kIsWeb && _webImage != null) || (!kIsWeb && _selectedImage != null);
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        _buildInputField(
          controller: _phoneController,
          label: 'Phone Number',
          icon: Icons.phone,
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your phone number';
            }
            if (!RegExp(r'^\+?[\d\s-()]+$').hasMatch(value)) {
              return 'Please enter a valid phone number';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        
        // NEW: Date of Birth Field
        _buildDateField(),
        const SizedBox(height: 20),
        
        _buildInputField(
          controller: _ageController,
          label: 'Age',
          icon: Icons.cake,
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your age';
            }
            final age = int.tryParse(value);
            if (age == null || age < 13 || age > 120) {
              return 'Please enter a valid age (13-120)';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        _buildInputField(
          controller: _addressController,
          label: 'Address',
          icon: Icons.location_on,
          maxLines: 2,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your address';
            }
            return null;
          },
        ),
      ],
    );
  }

  // NEW: Date of Birth Field Widget
  Widget _buildDateField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: InkWell(
        onTap: _selectDate,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today,
                color: const Color(0xFF4ECDC4),
                size: 22,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Date of Birth',
                      style: TextStyle(
                        color: const Color(0xFF718096),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _selectedDate != null
                          ? _formatDate(_selectedDate!)
                          : 'Select your birth date',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: _selectedDate != null 
                            ? const Color(0xFF2D3748)
                            : const Color(0xFF718096),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_drop_down,
                color: const Color(0xFF718096),
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Color(0xFF2D3748),
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            color: Color(0xFF718096),
            fontSize: 14,
          ),
          prefixIcon: Icon(
            icon,
            color: const Color(0xFF4ECDC4),
            size: 22,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Color(0xFF4ECDC4),
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Colors.red,
              width: 1,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Colors.red,
              width: 2,
            ),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildCompleteButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4ECDC4).withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _completeProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'Complete Profile',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Widget _buildSkipButton() {
    return TextButton(
      onPressed: _isLoading ? null : _skipForNow,
      child: const Text(
        'Skip for now',
        style: TextStyle(
          fontSize: 16,
          color: Color(0xFF718096),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // NEW: Date Selection Method
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now().subtract(const Duration(days: 365 * 25)),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF4ECDC4),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF2D3748),
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate && mounted) {
      setState(() {
        _selectedDate = picked;
        // Auto-calculate age from birth date
        final age = DateTime.now().year - picked.year;
        _ageController.text = age.toString();
      });
    }
  }

  // NEW: Date Formatting Method
  String _formatDate(DateTime date) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 70,
      );

      if (image != null && mounted) {
        if (kIsWeb) {
          final bytes = await image.readAsBytes();
          if (bytes.length > 1024 * 1024) { // 1MB limit
            throw Exception('Image too large (max 1MB)');
          }
          setState(() {
            _webImage = bytes;
            _selectedImage = null;
          });
        } else {
          final file = File(image.path);
          final bytes = await file.readAsBytes();
          if (bytes.length > 1024 * 1024) { // 1MB limit
            throw Exception('Image too large (max 1MB)');
          }
          setState(() {
            _selectedImage = file;
            _webImage = null;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  String? _convertImageToBase64() {
    try {
      if (kIsWeb && _webImage != null) {
        return base64Encode(_webImage!);
      } else if (!kIsWeb && _selectedImage != null) {
        final bytes = _selectedImage!.readAsBytesSync();
        return base64Encode(bytes);
      }
      return null;
    } catch (e) {
      print('Error converting image to base64: $e');
      return null;
    }
  }

  Future<void> _completeProfile() async {
    // Validate date selection
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select your date of birth'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.user?.uid;

      if (userId == null) throw Exception('User not authenticated');

      Map<String, dynamic> updateData = {
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'age': int.parse(_ageController.text.trim()),
        'dateOfBirth': Timestamp.fromDate(_selectedDate!), // NEW: Save date of birth
        'profileCompleted': true,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Add image if selected
      if (_hasImage()) {
        final base64Image = _convertImageToBase64();
        if (base64Image != null) {
          updateData['profileImageBase64'] = base64Image;
        }
      }

      // Update Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update(updateData);

      // Reload user data
      await authProvider.reloadUserData();

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Profile completed successfully! 🎉'),
            backgroundColor: const Color(0xFF4ECDC4),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );

        // Navigate to main screen using named route
        _navigateToMainScreen();
      }
    } catch (e) {
      print('Error completing profile: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _skipForNow() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.user?.uid;

      if (userId != null) {
        // Mark as skipped but not completed
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({
          'profileCompleted': false,
          'profileSkipped': true,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        await authProvider.reloadUserData();
      }

      if (mounted) {
        _navigateToMainScreen();
      }
    } catch (e) {
      print('Error skipping profile: $e');
      if (mounted) {
        _navigateToMainScreen();
      }
    }
  }

  // Helper method for navigation
  void _navigateToMainScreen() {
    // Option 1: Using named routes (recommended)
    try {
      Navigator.pushReplacementNamed(context, '/main');
    } catch (e) {
      // Option 2: Fallback - just pop back to previous screen
      print('Named route not found, using fallback navigation');
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }
}