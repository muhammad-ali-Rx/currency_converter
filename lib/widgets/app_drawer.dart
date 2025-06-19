import 'package:currency_converter/auth/auth_provider.dart';
import 'package:currency_converter/screen/edit_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'dart:typed_data';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return DrawerHeader(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF3C4858), Color(0xFF2D3A4B)],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileAvatar(authProvider, 30),
                    const SizedBox(height: 10),
                    Text(
                      authProvider.userData?['name'] ?? 'User',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      authProvider.userData?['email'] ?? '',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.home, color: Color(0xFF3C4858)),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.account_balance_wallet, color: Color(0xFF3C4858)),
            title: const Text('Portfolio'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications, color: Color(0xFF3C4858)),
            title: const Text('Alerts'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings, color: Color(0xFF3C4858)),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditProfileScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.person, color: Color(0xFF3C4858)),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context);
              _showProfileDialog(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () {
              Navigator.pop(context);
              _showLogoutDialog(context);
            },
          ),
        ],
      ),
    );
  }

  // New method to build profile avatar with image support
  Widget _buildProfileAvatar(AuthProvider authProvider, double radius) {
    final profileImageBase64 = authProvider.userData?['profileImageBase64'];
    
    if (profileImageBase64 != null && profileImageBase64.isNotEmpty) {
      try {
        final bytes = base64Decode(profileImageBase64);
        return CircleAvatar(
          radius: radius,
          backgroundColor: Colors.white,
          child: ClipOval(
            child: Image.memory(
              bytes,
              width: radius * 2,
              height: radius * 2,
              fit: BoxFit.cover,
            ),
          ),
        );
      } catch (e) {
        print('Error decoding profile image in drawer: $e');
        // Fallback to default avatar
      }
    }
    
    // Default avatar with initials
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.white,
      child: authProvider.userData?['name'] != null
          ? Text(
              authProvider.userData!['name'][0].toUpperCase(),
              style: TextStyle(
                fontSize: radius * 0.8,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF3C4858),
              ),
            )
          : Icon(
              Icons.person, 
              size: radius * 1.2, 
              color: const Color(0xFF3C4858)
            ),
    );
  }

  void _showProfileDialog(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Row(
          children: [
            _buildProfileAvatar(authProvider, 20),
            const SizedBox(width: 12),
            const Text(
              'User Profile',
              style: TextStyle(
                color: Color(0xFF3C4858),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile image section
            Center(
              child: Container(
                margin: const EdgeInsets.only(bottom: 20),
                child: _buildProfileAvatar(authProvider, 40),
              ),
            ),
            _buildProfileRow('Name', authProvider.userData?['name'] ?? 'N/A'),
            const SizedBox(height: 12),
            _buildProfileRow('Email', authProvider.userData?['email'] ?? 'N/A'),
            const SizedBox(height: 12),
            _buildProfileRow('Phone', authProvider.userData?['phone'] ?? 'Not set'),
            const SizedBox(height: 12),
            _buildProfileRow('Address', authProvider.userData?['address'] ?? 'Not set'),
            const SizedBox(height: 12),
            _buildProfileRow(
              'Member Since',
              authProvider.userData?['createdAt'] != null
                  ? authProvider.userData!['createdAt'].toDate().toString().split(' ')[0]
                  : 'N/A',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Close',
              style: TextStyle(color: Color(0xFF3C4858)),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditProfileScreen(),
                ),
              );
            },
            child: const Text(
              'Edit Profile',
              style: TextStyle(color: Color(0xFF3C4858)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Color(0xFF3C4858),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.logout,
                color: Colors.red,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Logout',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to logout from your account?',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 16,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return ElevatedButton(
                onPressed: authProvider.isLoading
                    ? null
                    : () async {
                        Navigator.pop(context);
                        await authProvider.logoutUser();
                        
                        // Show success message
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Logged out successfully!'),
                              backgroundColor: Colors.green,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: authProvider.isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Logout'),
              );
            },
          ),
        ],
      ),
    );
  }
}