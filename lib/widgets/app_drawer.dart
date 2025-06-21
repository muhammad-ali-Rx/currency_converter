import 'package:currency_converter/auth/auth_provider.dart';
import 'package:currency_converter/screen/edit_profile_screen.dart';
import 'package:currency_converter/screen/help_support.dart';
import 'package:currency_converter/screen/notic_setting.dart';
import 'package:currency_converter/screen/rate_alert.dart';
import 'package:currency_converter/screen/notifications_inbox_screen.dart';
import 'package:currency_converter/services/Enhanced_Notification.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF0F0F23),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return DrawerHeader(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.fromARGB(255, 10, 108, 236),
                      Color(0xFF44A08D),
                    ],
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
            leading: const Icon(
              Icons.home,
              color: Color.fromARGB(255, 10, 108, 236),
            ),
            title: const Text(
              'Home',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.account_balance_wallet,
              color: Color.fromARGB(255, 10, 108, 236),
            ),
            title: const Text(
              'Portfolio',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.trending_up,
              color: Color.fromARGB(255, 10, 108, 236),
            ),
            title: const Text('Rate Alerts', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RateAlertsScreen(),
                ),
              );
            },
          ),
          // Notifications Inbox with Badge
          StreamBuilder<List<dynamic>>(
            stream: EnhancedNotificationService().notificationStream,
            builder: (context, snapshot) {
              final notifications = snapshot.data ?? [];
              final unreadCount = notifications.where((n) => !n.isRead).length;
              
              return ListTile(
                leading: Stack(
                  children: [
                    const Icon(
                      Icons.notifications,
                      color: Color.fromARGB(255, 10, 108, 236),
                    ),
                    if (unreadCount > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            unreadCount > 99 ? '99+' : unreadCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
                title: Row(
                  children: [
                    const Text('Notifications', style: TextStyle(color: Colors.white)),
                    if (unreadCount > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          unreadCount > 99 ? '99+' : unreadCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                onTap: () async {
                  Navigator.pop(context);
                  await Future.delayed(const Duration(milliseconds: 100));
                  if (context.mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NotificationsInboxScreen(),
                      ),
                    );
                  }
                },
              );
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.notifications_active,
              color: Color.fromARGB(255, 10, 108, 236),
            ),
            title: const Text(
              'Notification Settings',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () async {
              Navigator.pop(context);
              await Future.delayed(const Duration(milliseconds: 100));
              if (context.mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationSettingsScreen(),
                  ),
                );
              }
            },
          ),
          const Divider(
            color: Color(0xFF2A2A3E),
            thickness: 1,
            indent: 16,
            endIndent: 16,
          ),
          ListTile(
            leading: const Icon(
              Icons.settings,
              color: Color.fromARGB(255, 10, 108, 236),
            ),
            title: const Text(
              'Settings',
              style: TextStyle(color: Colors.white),
            ),
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
            leading: const Icon(
              Icons.person,
              color: Color.fromARGB(255, 10, 108, 236),
            ),
            title: const Text('Profile', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              _showProfileDialog(context);
            },
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Quick Actions',
              style: TextStyle(
                color: Color(0xFF8A94A6),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(
              Icons.help_outline,
              color: Color.fromARGB(255, 10, 108, 236),
            ),
            title: const Text('Help & Support', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HelpSupportScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.info_outline,
              color: Color.fromARGB(255, 10, 108, 236),
            ),
            title: const Text('About', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              _showAboutDialog(context);
            },
          ),
          const Divider(
            color: Color(0xFF2A2A3E),
            thickness: 1,
            indent: 16,
            endIndent: 16,
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              _showLogoutDialog(context);
            },
          ),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Currency Converter v2.1.0',
              style: TextStyle(
                color: Color(0xFF8A94A6),
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

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
      }
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.white,
      child: authProvider.userData?['name'] != null
          ? Text(
              authProvider.userData!['name'][0].toUpperCase(),
              style: TextStyle(
                fontSize: radius * 0.8,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 10, 108, 236),
              ),
            )
          : Icon(
              Icons.person,
              size: radius * 1.2,
              color: const Color.fromARGB(255, 10, 108, 236),
            ),
    );
  }

  void _showProfileDialog(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0F0F23),
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
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                  ? authProvider.userData!['createdAt']
                      .toDate()
                      .toString()
                      .split(' ')[0]
                  : 'N/A',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Close',
              style: TextStyle(color: Color(0xFF8A94A6)),
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
              style: TextStyle(color: Color.fromARGB(255, 10, 108, 236)),
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
              color: Color(0xFF8A94A6),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0F0F23),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Row(
          children: [
            Icon(Icons.info_outline, color: Color.fromARGB(255, 10, 108, 236)),
            SizedBox(width: 12),
            Text(
              'About',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Currency Converter',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Version 2.1.0',
              style: TextStyle(color: Color(0xFF8A94A6), fontSize: 14),
            ),
            SizedBox(height: 16),
            Text(
              'A comprehensive currency conversion app with real-time rates, '
              'smart notifications, and portfolio tracking.',
              style: TextStyle(color: Color(0xFF8A94A6), fontSize: 14),
            ),
            SizedBox(height: 16),
            Text(
              'Features:\n'
              '• Real-time currency rates\n'
              '• Smart rate alerts\n'
              '• Push notifications\n'
              '• Portfolio tracking\n'
              '• Dark theme support',
              style: TextStyle(color: Color(0xFF8A94A6), fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Color(0xFF8A94A6))),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0F0F23),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.logout, color: Colors.red, size: 24),
            ),
            const SizedBox(width: 12),
            const Text(
              'Logout',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to logout from your account?',
          style: TextStyle(color: Color(0xFF8A94A6), fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF8A94A6))),
          ),
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return ElevatedButton(
                onPressed: authProvider.isLoading
                    ? null
                    : () async {
                        Navigator.pop(context);
                        await authProvider.logoutUser();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Logged out successfully!'),
                              backgroundColor: Color.fromARGB(255, 10, 108, 236),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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