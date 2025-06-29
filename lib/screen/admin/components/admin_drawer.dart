import 'package:currency_converter/screen/admin/components/All_Transactions.dart';
import 'package:currency_converter/screen/admin/components/add_analysis_screen.dart';
import 'package:currency_converter/screen/admin/components/add_article.dart';
import 'package:currency_converter/screen/admin/components/add_chart_screen.dart';
import 'package:currency_converter/screen/admin/components/add_trend_screen.dart';
import 'package:currency_converter/screen/admin/components/manage_articles_screen.dart';
import 'package:currency_converter/screen/admin/components/manage_transaction.dart';
import 'package:currency_converter/screen/mainscreen.dart';
import 'package:currency_converter/auth/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utils/modern_constants.dart' as modern_constants;
import 'dart:convert';

class AdminDrawer extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;
  final bool isMobile;

  const AdminDrawer({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    this.isMobile = false,
  });

  @override
  State<AdminDrawer> createState() => _AdminDrawerState();
}

class _AdminDrawerState extends State<AdminDrawer> {
  final Map<int, bool> _expandedSections = {};

  final List<Map<String, dynamic>> _menuItems = [
    {
      'icon': Icons.dashboard_rounded,
      'title': 'Dashboard',
      'index': 1,
      'hasSubmenu': false,
      'color': modern_constants.ModernConstants.primaryPurple,
    },
    {
      'icon': Icons.people_rounded,
      'title': 'Users',
      'index': 2,
      'hasSubmenu': true,
      'color': Colors.blue,
      'submenu': [
        {'title': 'Show Users', 'index': 2},
        {'title': 'Add User', 'index': 2},
      ],
    },
    {
      'icon': Icons.receipt_long_rounded,
      'title': 'User Transactions',
      'index': 10,
      'hasSubmenu': true,
      'color': Colors.green,
      'submenu': [
        {'title': 'All Transactions', 'index': 101},
        {'title': 'Manage Transactions', 'index': 102},
        {'title': 'Delete Transactions', 'index': 105},
      ],
    },
    {
      'icon': Icons.article_rounded,
      'title': 'News Management',
      'index': 20,
      'hasSubmenu': true,
      'color': Colors.purple,
      'submenu': [
        {'title': 'Add Article', 'index': 202},
        {'title': 'Manage Articles', 'index': 203},
      ],
    },
    {
      'icon': Icons.trending_up_rounded,
      'title': 'Market Data',
      'index': 30,
      'hasSubmenu': true,
      'color': Colors.orange,
      'submenu': [
        {'title': 'Add Trend', 'index': 301},
        {'title': 'Add Analysis', 'index': 302},
        {'title': 'Add Chart', 'index': 303},
        {'title': 'Manage Market Data', 'index': 304},
      ],
    },
    {
      'icon': Icons.settings_rounded,
      'title': 'Settings',
      'index': 3,
      'hasSubmenu': true,
      'color': Colors.teal,
      'submenu': [
        {'title': 'Show Settings', 'index': 3},
        {'title': 'Add Settings', 'index': 3},
      ],
    },
    {
      'icon': Icons.notifications_active_rounded,
      'title': 'Rate Alerts',
      'index': 4,
      'hasSubmenu': true,
      'color': Colors.indigo,
      'submenu': [
        {'title': 'Show Alerts', 'index': 4},
        {'title': 'Add Alert', 'index': 4},
      ],
    },
    {
      'icon': Icons.notifications_rounded,
      'title': 'App Notifications',
      'index': 7,
      'hasSubmenu': false,
      'color': Colors.pink,
    },
    {
      'icon': Icons.help_center_rounded,
      'title': 'User Support',
      'index': 8,
      'hasSubmenu': false,
      'color': Colors.amber,
    },
    {
      'icon': Icons.feedback_rounded,
      'title': 'User Feedback',
      'index': 9,
      'hasSubmenu': false,
      'color': Colors.cyan,
    },
  ];

  void _handleNavigation(int index, String? title) {
    switch (index) {
      case 101: // All Transactions
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AllTransactionsPage(),
          ),
        );
        break;
      case 102: // Manage Transactions
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ManageTransactionsScreen(),
          ),
        );
        break;
      case 105: // Delete Transactions
        _showDeleteTransactionsDialog();
        break;
      case 202: // Add Article
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AddArticleScreen(),
          ),
        );
        break;
      case 203: // Manage Articles
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ManageArticlesScreen(),
          ),
        );
        break;
      case 301: // Add Trend
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AddTrendScreen(),
          ),
        );
        break;
      case 302: // Add Analysis
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AddAnalysisScreen(),
          ),
        );
        break;
      case 303: // Add Chart
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AddChartScreen(),
          ),
        );
        break;
      case 304: // Manage Market Data
        _showComingSoonDialog('Manage Market Data');
        break;
      default:
        widget.onItemSelected(index);
        break;
    }
  }

  void _showDeleteTransactionsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: modern_constants.ModernConstants.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.delete_forever_rounded,
                color: Colors.red,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Delete Transactions',
              style: TextStyle(
                color: modern_constants.ModernConstants.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: const Text(
          'This feature is coming soon.',
          style: TextStyle(
            color: modern_constants.ModernConstants.textSecondary,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'OK',
              style: TextStyle(
                color: modern_constants.ModernConstants.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showComingSoonDialog(String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: modern_constants.ModernConstants.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: modern_constants.ModernConstants.primaryPurple.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.construction_rounded,
                color: modern_constants.ModernConstants.primaryPurple,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Coming Soon',
              style: TextStyle(
                color: modern_constants.ModernConstants.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$feature feature is under development.',
              style: const TextStyle(
                color: modern_constants.ModernConstants.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: modern_constants.ModernConstants.primaryPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: modern_constants.ModernConstants.primaryPurple.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: modern_constants.ModernConstants.primaryPurple,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'This feature will be available in the next update.',
                      style: TextStyle(
                        color: modern_constants.ModernConstants.primaryPurple,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'OK',
              style: TextStyle(
                color: modern_constants.ModernConstants.primaryPurple,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.isMobile ? double.infinity : 280,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            modern_constants.ModernConstants.sidebarBackground,
            modern_constants.ModernConstants.sidebarBackground.withOpacity(0.95),
            const Color(0xFF1a1a2e),
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildMenuList()),
            _buildUserPanelButton(),
            _buildLogoutButton(),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 80,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: modern_constants.ModernConstants.textTertiary.withOpacity(0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: modern_constants.ModernConstants.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.currency_exchange_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'CurrencyAdmin',
                  style: TextStyle(
                    color: modern_constants.ModernConstants.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Admin Dashboard',
                  style: TextStyle(
                    color: modern_constants.ModernConstants.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuList() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _menuItems.length,
      itemBuilder: (context, index) {
        final item = _menuItems[index];
        final isSelected = widget.selectedIndex == item['index'];
        final isExpanded = _expandedSections[item['index']] ?? false;
        final color = item['color'] as Color;

        return Column(
          children: [
            _buildMenuItem(item, isSelected, isExpanded, color),
            if (isExpanded && item['hasSubmenu'] == true) 
              _buildSubmenu(item, color),
          ],
        );
      },
    );
  }

  Widget _buildMenuItem(
    Map<String, dynamic> item,
    bool isSelected,
    bool isExpanded,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (item['hasSubmenu'] == true) {
              setState(() {
                _expandedSections[item['index']] = !isExpanded;
              });
            } else {
              _handleNavigation(item['index'], item['title']);
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: isSelected ? modern_constants.ModernConstants.primaryGradient : null,
              color: isExpanded && !isSelected
                  ? color.withOpacity(0.1)
                  : null,
              borderRadius: BorderRadius.circular(12),
              border: isExpanded
                  ? Border.all(color: color.withOpacity(0.3))
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  item['icon'],
                  color: isSelected
                      ? Colors.white
                      : isExpanded
                          ? color
                          : modern_constants.ModernConstants.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item['title'],
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : isExpanded
                              ? modern_constants.ModernConstants.textPrimary
                              : modern_constants.ModernConstants.textSecondary,
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
                if (item['hasSubmenu'] == true)
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: isSelected
                        ? Colors.white
                        : isExpanded
                            ? color
                            : modern_constants.ModernConstants.textSecondary,
                    size: 16,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubmenu(Map<String, dynamic> item, Color color) {
    final submenuItems = item['submenu'] as List<Map<String, dynamic>>? ?? [];

    return Container(
      margin: const EdgeInsets.only(left: 16, bottom: 8),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: color.withOpacity(0.3),
            width: 2,
          ),
        ),
      ),
      child: Column(
        children: submenuItems.map((submenuItem) {
          final isDeleteItem = submenuItem['index'] == 105;
          
          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                _handleNavigation(submenuItem['index'], submenuItem['title']);
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isDeleteItem 
                    ? Colors.red.withOpacity(0.1)
                    : color.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDeleteItem
                          ? Colors.red.withOpacity(0.8)
                          : color.withOpacity(0.8),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      _getSubmenuIcon(submenuItem['title']),
                      size: 12,
                      color: isDeleteItem
                        ? Colors.red.withOpacity(0.7)
                        : color.withOpacity(0.7),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        submenuItem['title'],
                        style: TextStyle(
                          color: isDeleteItem
                            ? Colors.red
                            : color,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 10,
                      color: color.withOpacity(0.6),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  IconData _getSubmenuIcon(String title) {
    switch (title) {
      case 'All Transactions':
        return Icons.list_alt_rounded;
      case 'Manage Transactions':
        return Icons.manage_accounts_rounded;
      case 'Delete Transactions':
        return Icons.delete_forever_rounded;
      case 'Add Article':
        return Icons.add_circle_outline_rounded;
      case 'Manage Articles':
        return Icons.edit_note_rounded;
      case 'Add Trend':
        return Icons.trending_up_rounded;
      case 'Add Analysis':
        return Icons.analytics_rounded;
      case 'Add Chart':
        return Icons.show_chart_rounded;
      case 'Manage Market Data':
        return Icons.data_usage_rounded;
      case 'Show Users':
        return Icons.people_alt_rounded;
      case 'Add User':
        return Icons.person_add_rounded;
      case 'Show Settings':
        return Icons.settings_display_rounded;
      case 'Add Settings':
        return Icons.settings_suggest_rounded;
      case 'Show Alerts':
        return Icons.notifications_active_rounded;
      case 'Add Alert':
        return Icons.add_alert_rounded;
      default:
        return Icons.circle;
    }
  }

  Widget _buildUserPanelButton() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const Mainscreen(),
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF10B981), Color(0xFF059669)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF10B981).withOpacity(0.3),
                  blurRadius: 15,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.person_rounded, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(
                  widget.isMobile ? 'User Panel' : 'Go to User Panel',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: authProvider.isLoading ? null : () => _showLogoutDialog(context),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.red.withOpacity(0.8),
                      Colors.red.withOpacity(0.9),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.red.withOpacity(0.3),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (authProvider.isLoading)
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    else
                      const Icon(
                        Icons.logout_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    const SizedBox(width: 8),
                    Text(
                      authProvider.isLoading ? 'Logging out...' : 'Admin Logout',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: modern_constants.ModernConstants.textTertiary.withOpacity(0.1)),
        ),
      ),
      child: Column(
        children: [
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              final userData = authProvider.userData;
              final userName = userData?['name'] ?? 'Admin User';
              final userEmail = userData?['email'] ?? 'admin@currency.com';
              final userInitial = userName.isNotEmpty ? userName[0].toUpperCase() : 'A';
              final userAvatar = userData?['profileImageBase64'] ?? '';

              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: modern_constants.ModernConstants.textTertiary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        gradient: userAvatar.isNotEmpty ? null : const LinearGradient(
                          colors: [Color(0xFF4CAF50), Color(0xFF2196F3)],
                        ),
                        borderRadius: BorderRadius.circular(8),
                        border: userAvatar.isNotEmpty ? Border.all(
                          color: modern_constants.ModernConstants.primaryPurple.withOpacity(0.3),
                          width: 1,
                        ) : null,
                      ),
                      child: userAvatar.isNotEmpty 
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: _buildProfileImage(userAvatar, userInitial),
                          )
                        : Center(
                            child: Text(
                              userInitial,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName,
                            style: const TextStyle(
                              color: modern_constants.ModernConstants.textPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            userEmail,
                            style: const TextStyle(
                              color: modern_constants.ModernConstants.textSecondary,
                              fontSize: 10,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 12,
                color: modern_constants.ModernConstants.textTertiary,
              ),
              const SizedBox(width: 4),
              Text(
                'Version 1.0.0',
                style: TextStyle(
                  color: modern_constants.ModernConstants.textTertiary,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // FIXED: Simplified logout dialog - let AuthProvider handle navigation automatically
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: modern_constants.ModernConstants.cardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: Colors.red,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Admin Logout',
                style: TextStyle(
                  color: modern_constants.ModernConstants.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Are you sure you want to logout from Admin Panel?',
                style: TextStyle(
                  color: modern_constants.ModernConstants.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.orange.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.orange,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'You will be redirected to the login screen',
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: modern_constants.ModernConstants.textSecondary,
                  fontSize: 14,
                ),
              ),
            ),
            Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                return ElevatedButton(
                  onPressed: authProvider.isLoading
                      ? null
                      : () async {
                          try {
                            // Close the dialog first
                            Navigator.of(dialogContext).pop();
                            
                            // Perform logout - AuthProvider will handle navigation automatically
                            bool success = await authProvider.logoutUser();
                            
                            // Show success message only if logout was successful
                            // Note: We don't need to navigate manually as AuthProvider handles it
                            if (success) {
                              print('✅ Admin logout successful - AuthProvider will handle navigation');
                            }
                          } catch (e) {
                            print('❌ Logout error: $e');
                            // Only show error if something goes wrong
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Logout failed: ${e.toString()}'),
                                  backgroundColor: Colors.red,
                                  duration: const Duration(seconds: 3),
                                ),
                              );
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                      : const Text(
                          'Logout',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildProfileImage(String imageData, String fallbackInitial) {
    try {
      final bytes = base64Decode(imageData);
      return Image.memory(
        bytes,
        width: 32,
        height: 32,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4CAF50), Color(0xFF2196F3)],
              ),
            ),
            child: Center(
              child: Text(
                fallbackInitial,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      );
    } catch (e) {
      return Container(
        width: 32,
        height: 32,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4CAF50), Color(0xFF2196F3)],
          ),
        ),
        child: Center(
          child: Text(
            fallbackInitial,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }
  }
}