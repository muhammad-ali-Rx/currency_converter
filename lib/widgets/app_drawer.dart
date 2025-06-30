import 'package:currency_converter/auth/auth_provider.dart';
import 'package:currency_converter/screen/CurrencyNewsScreen.dart';
import 'package:currency_converter/screen/Portfolio_Screen.dart';
import 'package:currency_converter/screen/addarticlescreen.dart';
import 'package:currency_converter/screen/admin/components/admin_add_article.dart';
import 'package:currency_converter/screen/debug-notification-screen.dart';
import 'package:currency_converter/screen/edit_profile_screen.dart';
import 'package:currency_converter/screen/feedback_screen.dart';
import 'package:currency_converter/screen/help_support.dart';
import 'package:currency_converter/screen/news_screen.dart';
import 'package:currency_converter/screen/rate-alerts-list-screen.dart';
import 'package:currency_converter/screen/admin/admin_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:convert';

class FixedOverflowDrawer extends StatelessWidget {
  const FixedOverflowDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;
    
    return Drawer(
      backgroundColor: const Color(0xFF0F0F23),
      width: MediaQuery.of(context).size.width * 0.75,
      child: Column(
        children: [
          _buildCompactHeader(context, isSmallScreen),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  // Main Navigation
                  _buildCompactSection('Main', [
                    _buildCompactTile(
                      context,
                      Icons.home_rounded,
                      'Home',
                      () => Navigator.pop(context),
                      Colors.blue,
                    ),
                    _buildCompactTile(
                      context,
                      Icons.account_balance_wallet_rounded,
                      'Portfolio',
                      () => _navigateToScreen(context, 'Portfolio'),
                      Colors.green,
                    ),
                    _buildCompactTile(
                      context,
                      Icons.trending_up_rounded,
                      'Rate Alerts',
                      () => _navigateToScreen(context, 'RateAlerts'),
                      Colors.orange,
                    ),
                  ]),
                  
                  // News & Content Section
                  _buildCompactSection('News & Content', [
                    _buildCompactTile(
                      context,
                      Icons.newspaper_rounded,
                      'Currency News',
                      () => _navigateToScreen(context, 'CurrencyNews'),
                      Colors.purple,
                    ),
                    // Admin-only news management options
                    if (_isUserAdmin(Provider.of<AuthProvider>(context, listen: false))) ...[
                      _buildCompactTile(
                        context,
                        Icons.add_circle_outline_rounded,
                        'Add Article',
                        () => _navigateToScreen(context, 'AddArticle'),
                        Colors.indigo,
                      ),
                    ],
                  ]),
                  
                 
                  
                  // Account & Settings
                  _buildCompactSection('Account', [
                    _buildCompactTile(
                      context,
                      Icons.person_rounded,
                      'Profile',
                      () => _showProfileDialog(context),
                      Colors.blue,
                    ),
                    _buildAdminPanelButton(context),
                    _buildCompactTile(
                      context,
                      Icons.settings_rounded,
                      'Settings',
                      () => _navigateToScreen(context, 'Settings'),
                      Colors.grey,
                    ),
                  ]),
                  
                  // Debug Section (Always visible for testing)
                  _buildCompactSection('Debug & Testing', [
                    _buildCompactTile(
                      context,
                      Icons.bug_report_rounded,
                      'Debug Notifications',
                      () => _navigateToScreen(context, 'DebugNotifications'),
                      Colors.red,
                    ),
                  ]),
                  
                  if (!isSmallScreen)
                    _buildCompactSection('Support', [
                      _buildCompactTile(
                        context,
                        Icons.help_outline_rounded,
                        'Help & Support',
                        () => _navigateToScreen(context, 'Help'),
                        Colors.cyan,
                      ),
                      _buildCompactTile(
                        context,
                        Icons.feedback_rounded,
                        'Send Feedback',
                        () => _navigateToScreen(context, 'Feedback'),
                        Colors.amber,
                      ),
                    ]),
                  
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
          _buildCompactFooter(context, isSmallScreen),
        ],
      ),
    );
  }

  Widget _buildAdminPanelButton(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final userData = authProvider.userData;
        final isAdmin = userData != null && 
                       (userData['isAdmin'] == true || 
                        userData['role'] == 'admin' || 
                        userData['userType'] == 'admin');
        
        if (!isAdmin) {
          return const SizedBox.shrink();
        }
        
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.red.withOpacity(0.05),
            border: Border.all(
              color: Colors.red.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: ListTile(
            dense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
            leading: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.admin_panel_settings_rounded, 
                color: Colors.red, 
                size: 18
              ),
            ),
            title: const Text(
              'Admin Panel',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: const Text(
              'Admin Access',
              style: TextStyle(
                color: Colors.red,
                fontSize: 9,
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              color: Colors.red.withOpacity(0.7),
              size: 12,
            ),
            onTap: () {
              HapticFeedback.lightImpact();
              _navigateToScreen(context, 'AdminPanel');
            },
          ),
        );
      },
    );
  }

  Widget _buildCompactHeader(BuildContext context, bool isSmallScreen) {
    final headerHeight = isSmallScreen ? 120.0 : 140.0;
    
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Container(
          height: headerHeight,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.fromARGB(255, 10, 108, 236),
                Color(0xFF44A08D),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      _buildProfileAvatar(authProvider, isSmallScreen ? 20 : 25),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    authProvider.userData?['name'] ?? 'User',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: isSmallScreen ? 16 : 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (_isUserAdmin(authProvider))
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.8),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'ADMIN',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 8,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                authProvider.userData?['email'] ?? 'No email',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isSmallScreen ? 9 : 10,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  bool _isUserAdmin(AuthProvider authProvider) {
    final userData = authProvider.userData;
    return userData != null && 
           (userData['isAdmin'] == true || 
            userData['role'] == 'admin' || 
            userData['userType'] == 'admin');
  }

  Widget _buildCompactSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(
            children: [
              Container(
                width: 3,
                height: 12,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 10, 108, 236),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF8A94A6),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        ...children,
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildCompactTile(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: color.withOpacity(0.05),
      ),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        leading: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: color.withOpacity(0.5),
          size: 12,
        ),
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
      ),
    );
  }

 
  Widget _buildCompactFooter(BuildContext context, bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        border: Border(
          top: BorderSide(
            color: const Color.fromARGB(255, 10, 108, 236).withOpacity(0.3),
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: ListTile(
              dense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              leading: const Icon(Icons.logout_rounded, color: Colors.red, size: 18),
              title: Text(
                'Logout',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                  fontSize: isSmallScreen ? 12 : 13,
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.red, size: 12),
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.pop(context);
                _showLogoutDialog(context);
              },
            ),
          ),
          
          if (!isSmallScreen) ...[
            const SizedBox(height: 8),
            const Text(
              'v2.1.0',
              style: TextStyle(color: Color(0xFF8A94A6), fontSize: 10),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProfileAvatar(AuthProvider authProvider, double radius) {
    final profileImageBase64 = authProvider.userData?['profileImageBase64'];
    if (profileImageBase64 != null && profileImageBase64.isNotEmpty) {
      try {
        final bytes = base64Decode(profileImageBase64);
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: CircleAvatar(
            radius: radius,
            backgroundColor: Colors.white,
            child: ClipOval(
              child: Image.memory(
                bytes,
                width: radius * 2,
                height: radius * 2,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.person,
                    size: radius * 1.2,
                    color: const Color.fromARGB(255, 10, 108, 236),
                  );
                },
              ),
            ),
          ),
        );
      } catch (e) {
        print('Error decoding profile image: $e');
      }
    }

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: CircleAvatar(
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
      ),
    );
  }

  void _navigateToScreen(BuildContext context, String screenName) {
    Navigator.pop(context);
    
    try {
      Widget? screen;
      
      switch (screenName) {
        case 'Portfolio':
          screen = const PortfolioScreen();
          break;
        case 'RateAlerts':
          screen = const SimpleAlertsListScreen();
          break;
        case 'CurrencyNews':
          screen = const CurrencyNewsScreen();
          break;
        case 'AddArticle':
          final authProvider = Provider.of<AuthProvider>(context, listen: false);
          if (_isUserAdminStatic(authProvider)) {
            screen = const userArticleScreen();
          } else {
            _showMessage(context, 'Access Denied: Admin privileges required');
            return;
          }
          break;
        case 'Settings':
          screen = const EditProfileScreen();
          break;
        case 'Help':
          screen = const HelpSupportScreen();
          break;
        case 'Feedback':
          screen = const UserFeedbackScreen();
          break;
        case 'AdminPanel':
          final authProvider = Provider.of<AuthProvider>(context, listen: false);
          if (_isUserAdminStatic(authProvider)) {
            screen = const AdminDashboard();
          } else {
            _showMessage(context, 'Access Denied: Admin privileges required');
            return;
          }
          break;
        case 'DebugNotifications': // Add this case
          screen = const DebugNotificationScreen();
          break;
        default:
          _showMessage(context, 'Screen not found: $screenName');
          return;
      }
      
      if (screen != null) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen!),
        );
      }
    } catch (e) {
      print('Navigation error: $e');
      _showMessage(context, 'Error opening $screenName');
    }
  }

  bool _isUserAdminStatic(AuthProvider authProvider) {
    final userData = authProvider.userData;
    return userData != null && 
           (userData['isAdmin'] == true || 
            userData['role'] == 'admin' || 
            userData['userType'] == 'admin');
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showProfileDialog(BuildContext context) {
    Navigator.pop(context);
    _navigateToScreen(context, 'Settings');
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0F0F23),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: Colors.red, size: 20),
            SizedBox(width: 8),
            Text(
              'Logout',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: Color(0xFF8A94A6), fontSize: 14),
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
                        try {
                          await authProvider.logoutUser();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Logged out successfully!'),
                                backgroundColor: Color.fromARGB(255, 10, 108, 236),
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Logout failed: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: authProvider.isLoading
                    ? const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('Logout', style: TextStyle(color: Colors.white, fontSize: 12)),
              );
            },
          ),
        ],
      ),
    );
  }
}
