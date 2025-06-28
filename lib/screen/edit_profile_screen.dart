import 'package:currency_converter/auth/auth_provider.dart';
import 'package:currency_converter/screen/Stats.dart';
import 'package:currency_converter/model/currency.dart';
import 'package:currency_converter/screen/mainscreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _passwordController = TextEditingController();
  
  DateTime? _selectedDate;
  bool _isLoading = false;
  bool _hasChanges = false;
  bool _isPasswordVisible = false;
  File? _selectedImage;
  Uint8List? _webImage;
  String? _profileImageBase64;
  
  bool _isEditingName = false;
  bool _isEditingPhone = false;
  bool _isEditingAddress = false;
  bool _isEditingPassword = false;

  // Bottom navigation
  int _currentIndex = 2; // Profile is selected by default

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Fixed: Load fresh data from Firestore instead of cached data
  Future<void> _loadUserData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.user?.uid;
    
    if (userId != null) {
      try {
        // Load fresh data from Firestore
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();
        
        if (doc.exists) {
          final userData = doc.data()!;
          
          if (mounted) {
            setState(() {
              _nameController.text = userData['name'] ?? '';
              _phoneController.text = userData['phone'] ?? '';
              _addressController.text = userData['address'] ?? '';
              _profileImageBase64 = userData['profileImageBase64'];
              
              if (userData['dateOfBirth'] != null) {
                _selectedDate = (userData['dateOfBirth'] as Timestamp).toDate();
              }
            });
          }
        }
      } catch (e) {
        print('Error loading user data: $e');
        // Fallback to cached data
        final userData = authProvider.userData;
        if (userData != null && mounted) {
          setState(() {
            _nameController.text = userData['name'] ?? '';
            _phoneController.text = userData['phone'] ?? '';
            _addressController.text = userData['address'] ?? '';
            _profileImageBase64 = userData['profileImageBase64'];
            
            if (userData['dateOfBirth'] != null) {
              _selectedDate = (userData['dateOfBirth'] as Timestamp).toDate();
            }
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0A1A), // Dark theme background
        body: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F0F23), // Dark card background
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF1A1A2E)), // Dark border
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: _buildProfileForm(),
                        ),
                      ),
                      if (_hasChanges) _buildSaveButton(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomNavigation(),
      ),
    );
  }

  // Handle back button press
  Future<bool> _onWillPop() async {
    if (_hasChanges) {
      final shouldPop = await _showUnsavedChangesDialog();
      return shouldPop ?? false;
    }
    return true;
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            onPressed: () async {
              if (_hasChanges) {
                final shouldPop = await _showUnsavedChangesDialog();
                if (shouldPop == true && mounted) {
                   Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => Mainscreen(),
                  ),
                );
                }
              } else {
                // i want to push method
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => Mainscreen(),
                  ),
                );
              
              }
            },
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          ),
          const Expanded(
            child: Text(
              'Edit Profile',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildProfileForm() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Form(
          key: _formKey,
          child: Column(
            children: [
              _buildProfilePicture(),
              const SizedBox(height: 32),
              _buildEditableField(
                label: 'Username',
                controller: _nameController,
                isEditing: _isEditingName,
                onTap: () => _toggleFieldEdit('name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              _buildProfileField(
                label: 'Email',
                value: authProvider.userData?['email'] ?? '',
                enabled: false,
              ),
              _buildEditableField(
                label: 'Phone',
                controller: _phoneController,
                isEditing: _isEditingPhone,
                onTap: () => _toggleFieldEdit('phone'),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    if (!RegExp(r'^\+?[\d\s-()]+$').hasMatch(value)) {
                      return 'Please enter a valid phone number';
                    }
                  }
                  return null;
                },
              ),
              _buildPasswordField(),
              _buildDateField(),
              _buildEditableField(
                label: 'Address',
                controller: _addressController,
                isEditing: _isEditingAddress,
                onTap: () => _toggleFieldEdit('address'),
                maxLines: 2,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfilePicture() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return GestureDetector(
          onTap: _pickImage,
          child: Stack(
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4ECDC4).withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: _buildImageWidget(authProvider),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4ECDC4),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF0F0F23), width: 3),
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImageWidget(AuthProvider authProvider) {
    // Priority: Local selected image > Stored base64 > Default avatar
    if (kIsWeb && _webImage != null) {
      return Image.memory(
        _webImage!,
        width: 120,
        height: 120,
        fit: BoxFit.cover,
      );
    } else if (!kIsWeb && _selectedImage != null) {
      return Image.file(
        _selectedImage!,
        width: 120,
        height: 120,
        fit: BoxFit.cover,
      );
    }
    
    if (_profileImageBase64 != null && _profileImageBase64!.isNotEmpty) {
      try {
        final bytes = base64Decode(_profileImageBase64!);
        return Image.memory(
          bytes,
          width: 120,
          height: 120,
          fit: BoxFit.cover,
        );
      } catch (e) {
        print('Error decoding base64 image: $e');
      }
    }
    
    return _buildDefaultAvatar(authProvider);
  }

  Widget _buildDefaultAvatar(AuthProvider authProvider) {
    return Container(
      width: 120,
      height: 120,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          authProvider.userData?['name'] != null
              ? authProvider.userData!['name'][0].toUpperCase()
              : 'U',
          style: const TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildEditableField({
    required String label,
    required TextEditingController controller,
    required bool isEditing,
    required VoidCallback onTap,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF8A94A6),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: isEditing ? null : onTap,
            child: TextFormField(
              controller: controller,
              enabled: isEditing,
              keyboardType: keyboardType,
              maxLines: maxLines,
              validator: validator,
              onChanged: (value) => _markAsChanged(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isEditing ? Colors.white : const Color(0xFF8A94A6),
              ),
              decoration: InputDecoration(
                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: const Color(0xFF1A1A2E)),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: const Color(0xFF1A1A2E)),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF4ECDC4), width: 2),
                ),
                disabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: const Color(0xFF1A1A2E).withOpacity(0.5)),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                suffixIcon: isEditing
                    ? IconButton(
                        icon: const Icon(Icons.check, color: Color(0xFF4ECDC4)),
                        onPressed: () => _toggleFieldEdit(label.toLowerCase()),
                      )
                    : const Icon(Icons.edit, color: Color(0xFF8A94A6), size: 20),
                errorStyle: const TextStyle(color: Color(0xFFEF4444)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField() {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Password',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF8A94A6),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _isEditingPassword ? null : () => _toggleFieldEdit('password'),
            child: TextFormField(
              controller: _passwordController,
              enabled: _isEditingPassword,
              obscureText: !_isPasswordVisible,
              onChanged: (value) => _markAsChanged(),
              validator: (value) {
                if (_isEditingPassword && value != null && value.isNotEmpty) {
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                }
                return null;
              },
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: _isEditingPassword ? Colors.white : const Color(0xFF8A94A6),
              ),
              decoration: InputDecoration(
                hintText: _isEditingPassword ? 'Enter new password' : '••••••••',
                hintStyle: const TextStyle(color: Color(0xFF8A94A6)),
                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: const Color(0xFF1A1A2E)),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: const Color(0xFF1A1A2E)),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF4ECDC4), width: 2),
                ),
                disabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: const Color(0xFF1A1A2E).withOpacity(0.5)),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                suffixIcon: _isEditingPassword
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                              color: const Color(0xFF8A94A6),
                            ),
                            onPressed: () {
                              if (mounted) {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.check, color: Color(0xFF4ECDC4)),
                            onPressed: () => _toggleFieldEdit('password'),
                          ),
                        ],
                      )
                    : const Icon(Icons.edit, color: Color(0xFF8A94A6), size: 20),
                errorStyle: const TextStyle(color: Color(0xFFEF4444)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileField({
    required String label,
    String? value,
    bool enabled = true,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF8A94A6),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: const Color(0xFF1A1A2E).withOpacity(0.5)),
              ),
            ),
            child: Text(
              value ?? '',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF8A94A6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField() {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Date of birth',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF8A94A6),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: _selectDate,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: const Color(0xFF1A1A2E)),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _selectedDate != null
                        ? '${_selectedDate!.day.toString().padLeft(2, '0')}/${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.year}'
                        : 'Select date',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: _selectedDate != null ? Colors.white : const Color(0xFF8A94A6),
                    ),
                  ),
                  const Icon(
                    Icons.calendar_today,
                    color: Color(0xFF4ECDC4),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(24),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4ECDC4),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'Save Changes',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  // FIXED: Improved bottom navigation
  Widget _buildBottomNavigation() {
    return BottomNavigationBar(
      backgroundColor: const Color(0xFF0A0A1A),
      selectedItemColor: const Color(0xFF4ECDC4),
      unselectedItemColor: const Color(0xFF8A94A6),
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.wallet), label: 'Wallet'),
        BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: 'Stats'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
      currentIndex: _currentIndex,
      onTap: (index) {
        if (index == _currentIndex) return;
        
        _handleNavigation(index);
      },
    );
  }

  // FIXED: Proper navigation handling
  void _handleNavigation(int index) async {
    // Check for unsaved changes before navigating
    if (_hasChanges) {
      final shouldNavigate = await _showUnsavedChangesDialog();
      if (shouldNavigate != true) return;
    }

    if (!mounted) return;

    switch (index) {
      case 0:
        // Navigate back to wallet screen (main screen)
        Navigator.of(context).pop();
        break;
      case 1:
        // Navigate to stats screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => StatsScreen(currencies: _getMockCurrencies()),
          ),
        );
        break;
      case 2:
        // Already on profile screen
        break;
    }
  }

  // Mock currencies for stats screen
  List<Currency> _getMockCurrencies() {
    return [
      Currency(
        code: 'USD',
        name: 'US Dollar',
        rate: 1.0,
        amount: 1.0,
        percentChange: 0.0,
        ratePerUsd: 1.0,
        color: Colors.green,
      ),
      Currency(
        code: 'EUR',
        name: 'Euro',
        rate: 0.85,
        amount: 0.85,
        percentChange: 1.2,
        ratePerUsd: 0.85,
        color: Colors.blue,
      ),
    ];
  }

  // FIXED: Show unsaved changes dialog
  Future<bool?> _showUnsavedChangesDialog() async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0F0F23),
          title: const Text(
            'Unsaved Changes',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'You have unsaved changes. Do you want to save them before leaving?',
            style: TextStyle(color: Color(0xFF8A94A6)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(true), // Discard changes
              child: const Text(
                'Discard',
                style: TextStyle(color: Color(0xFFEF4444)),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // Cancel
              child: const Text(
                'Cancel',
                style: TextStyle(color: Color(0xFF8A94A6)),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(false); // Close dialog first
                await _saveProfile(); // Save changes
                if (mounted && !_hasChanges) {
                  Navigator.of(context).pop(true); // Navigate after saving
                }
              },
              child: const Text(
                'Save',
                style: TextStyle(color: Color(0xFF4ECDC4)),
              ),
            ),
          ],
        );
      },
    );
  }

  void _toggleFieldEdit(String field) {
    if (mounted) {
      setState(() {
        switch (field.toLowerCase()) {
          case 'name':
          case 'username':
            _isEditingName = !_isEditingName;
            break;
          case 'phone':
            _isEditingPhone = !_isEditingPhone;
            break;
          case 'address':
            _isEditingAddress = !_isEditingAddress;
            break;
          case 'password':
            _isEditingPassword = !_isEditingPassword;
            if (!_isEditingPassword) {
              _passwordController.clear();
              _isPasswordVisible = false;
            }
            break;
        }
      });
    }
  }

  void _markAsChanged() {
    if (!_hasChanges && mounted) {
      setState(() {
        _hasChanges = true;
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 50,
      );

      if (image != null && mounted) {
        if (kIsWeb) {
          final bytes = await image.readAsBytes();
          if (bytes.length > 900 * 1024) {
            throw Exception('Image too large (max 900KB)');
          }
          setState(() {
            _webImage = bytes;
            _selectedImage = null;
            _hasChanges = true;
          });
        } else {
          final file = File(image.path);
          final bytes = await file.readAsBytes();
          if (bytes.length > 900 * 1024) {
            throw Exception('Image too large (max 900KB)');
          }
          setState(() {
            _selectedImage = file;
            _webImage = null;
            _hasChanges = true;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  String? _convertImageToBase64() {
    try {
      if (kIsWeb) {
        if (_webImage != null) {
          return base64Encode(_webImage!);
        }
      } else {
        if (_selectedImage != null) {
          final bytes = _selectedImage!.readAsBytesSync();
          return base64Encode(bytes);
        }
      }
      return null;
    } catch (e) {
      print('Error converting image to base64: $e');
      return null;
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now().subtract(const Duration(days: 365 * 25)),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF4ECDC4),
              onPrimary: Colors.white,
              surface: Color(0xFF0F0F23),
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: const Color(0xFF0F0F23),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate && mounted) {
      setState(() {
        _selectedDate = picked;
        _hasChanges = true;
      });
    }
  }

  // FIXED: Improved save profile method
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.user?.uid;

      if (userId == null) throw Exception('User not authenticated');

      Map<String, dynamic> updateData = {
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (_selectedDate != null) {
        updateData['dateOfBirth'] = Timestamp.fromDate(_selectedDate!);
      }

      // Handle image conversion to base64
      if (_selectedImage != null || _webImage != null) {
        final base64Image = _convertImageToBase64();
        if (base64Image != null) {
          updateData['profileImageBase64'] = base64Image;
          _profileImageBase64 = base64Image;
        }
      }

      // Update password if changed
      if (_passwordController.text.isNotEmpty) {
        await authProvider.user?.updatePassword(_passwordController.text.trim());
        _passwordController.clear();
      }

      // Save to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update(updateData);

      // Update auth display name
      await authProvider.user?.updateDisplayName(_nameController.text.trim());
      
      // Force reload user data from Firestore
      await authProvider.reloadUserData();

      if (mounted) {
        setState(() {
          _hasChanges = false;
          _isEditingName = false;
          _isEditingPhone = false;
          _isEditingAddress = false;
          _isEditingPassword = false;
          _selectedImage = null;
          _webImage = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Color(0xFF4ECDC4),
          ),
        );
      }
    } catch (e) {
      print('Error saving profile: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}