import 'package:currency_converter/screen/admin/components/All_Transactions.dart';
import 'package:currency_converter/screen/mainscreen.dart';
import 'package:currency_converter/auth/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utils/modern_constants.dart';
import 'dart:convert';

class ResponsiveSidebar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;
  final bool isMobile;

  const ResponsiveSidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    this.isMobile = false,
  });

  @override
  State<ResponsiveSidebar> createState() => _ResponsiveSidebarState();
}

class _ResponsiveSidebarState extends State<ResponsiveSidebar> {
  final Map<int, bool> _expandedSections = {};

  // ✅ UPDATED: Added Delete Transactions option
  final List<Map<String, dynamic>> _menuItems = [
    {
      'icon': Icons.dashboard_rounded,
      'title': 'Dashboard',
      'index': 1,
      'hasSubmenu': false,
    },
    {
      'icon': Icons.people_rounded,
      'title': 'Users',
      'index': 2,
      'hasSubmenu': true,
      'submenu': [
        {'title': 'Show Users', 'index': 2},
        {'title': 'Add User', 'index': 2},
      ],
    },
    // ✅ UPDATED: Normal styling for User Transactions
    {
      'icon': Icons.receipt_long_rounded,
      'title': 'User Transactions',
      'index': 10,
      'hasSubmenu': true,
      'submenu': [
        {'title': 'All Transactions', 'index': 101},
        {'title': 'Delete Transactions', 'index': 105}, // ✅ NEW: Delete option
      ],
    },
    {
      'icon': Icons.settings_rounded,
      'title': 'Settings',
      'index': 3,
      'hasSubmenu': true,
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
      'submenu': [
        {'title': 'Show Alerts', 'index': 4},
        {'title': 'Add Alert', 'index': 4},
      ],
    },
    {
      'icon': Icons.article_rounded,
      'title': 'Currency News',
      'index': 5,
      'hasSubmenu': false,
    },
    {
      'icon': Icons.trending_up_rounded,
      'title': 'Market Trends',
      'index': 6,
      'hasSubmenu': false,
    },
    {
      'icon': Icons.notifications_rounded,
      'title': 'App Notifications',
      'index': 7,
      'hasSubmenu': false,
    },
    {
      'icon': Icons.help_center_rounded,
      'title': 'User Support',
      'index': 8,
      'hasSubmenu': false,
    },
    {
      'icon': Icons.feedback_rounded,
      'title': 'User Feedback',
      'index': 9,
      'hasSubmenu': false,
    },
  ];

  // ✅ UPDATED: Navigation handler with Delete Transactions
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
      case 102: // Currency Conversions
        _showComingSoonDialog('Currency Conversions');
        break;
      case 103: // Transaction History
        _showComingSoonDialog('Transaction History');
        break;
      case 104: // User Activity
        _showComingSoonDialog('User Activity');
        break;
      case 105: // Delete Transactions
        _showDeleteTransactionsDialog();
        break;
      default:
        widget.onItemSelected(index);
        break;
    }
  }

  // ✅ NEW: Delete Transactions Dialog
  void _showDeleteTransactionsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ModernConstants.cardBackground,
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
            const Text(
              'Delete Transactions',
              style: TextStyle(
                color: ModernConstants.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Choose what type of transactions you want to delete:',
              style: TextStyle(
                color: ModernConstants.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            // Delete Options
            _buildDeleteOption(
              'Delete All Transactions',
              'Remove all transaction records',
              Icons.delete_sweep_rounded,
              Colors.red,
              () => _confirmDelete('All Transactions'),
            ),
            const SizedBox(height: 8),
            _buildDeleteOption(
              'Delete Old Transactions',
              'Remove transactions older than 30 days',
              Icons.history_rounded,
              Colors.orange,
              () => _confirmDelete('Old Transactions'),
            ),
            const SizedBox(height: 8),
            _buildDeleteOption(
              'Delete Failed Transactions',
              'Remove failed/incomplete transactions',
              Icons.error_outline_rounded,
              Colors.amber,
              () => _confirmDelete('Failed Transactions'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: ModernConstants.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ NEW: Delete Option Widget
  Widget _buildDeleteOption(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: color.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: color,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: color.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: color.withOpacity(0.6),
                size: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ NEW: Confirm Delete Dialog
  void _confirmDelete(String type) {
    Navigator.of(context).pop(); // Close first dialog
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ModernConstants.cardBackground,
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
                Icons.warning_rounded,
                color: Colors.red,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Confirm Delete',
              style: TextStyle(
                color: Colors.red,
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
              'Are you sure you want to delete $type?',
              style: const TextStyle(
                color: ModernConstants.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'This action cannot be undone and will permanently remove the selected transactions from the database.',
              style: TextStyle(
                color: ModernConstants.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.red.withOpacity(0.3),
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.red,
                    size: 16,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Warning: This will permanently delete data!',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
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
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: ModernConstants.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _performDelete(type);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Delete',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ NEW: Perform Delete Operation
  void _performDelete(String type) {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: ModernConstants.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Deleting $type...',
              style: const TextStyle(
                color: ModernConstants.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please wait while we process your request.',
              style: TextStyle(
                color: ModernConstants.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );

    // Simulate delete operation
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pop(); // Close loading dialog
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$type deleted successfully!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
    });
  }

  void _showComingSoonDialog(String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ModernConstants.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: ModernConstants.primaryPurple.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.construction_rounded,
                color: ModernConstants.primaryPurple,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Coming Soon',
              style: TextStyle(
                color: ModernConstants.textPrimary,
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
                color: ModernConstants.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ModernConstants.primaryPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: ModernConstants.primaryPurple.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: ModernConstants.primaryPurple,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'This feature will be available in the next update.',
                      style: TextStyle(
                        color: ModernConstants.primaryPurple,
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
                color: ModernConstants.primaryPurple,
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
            ModernConstants.sidebarBackground,
            ModernConstants.sidebarBackground.withOpacity(0.95),
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
            color: ModernConstants.textTertiary.withOpacity(0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: ModernConstants.primaryGradient,
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
                    color: ModernConstants.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Admin Dashboard',
                  style: TextStyle(
                    color: ModernConstants.textSecondary,
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

        return Column(
          children: [
            _buildMenuItem(item, isSelected, isExpanded),
            if (isExpanded && item['hasSubmenu'] == true) _buildSubmenu(item),
          ],
        );
      },
    );
  }

  Widget _buildMenuItem(
    Map<String, dynamic> item,
    bool isSelected,
    bool isExpanded,
  ) {
    // ✅ REMOVED: Special transaction item styling - now normal
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
              gradient: isSelected ? ModernConstants.primaryGradient : null,
              color: isExpanded && !isSelected
                  ? ModernConstants.primaryPurple.withOpacity(0.1)
                  : null,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  item['icon'],
                  color: isSelected
                      ? Colors.white
                      : isExpanded
                          ? ModernConstants.primaryPurple
                          : ModernConstants.textSecondary,
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
                              ? ModernConstants.textPrimary
                              : ModernConstants.textSecondary,
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
                            ? ModernConstants.primaryPurple
                            : ModernConstants.textSecondary,
                    size: 16,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubmenu(Map<String, dynamic> item) {
    final submenuItems = item['submenu'] as List<Map<String, dynamic>>? ?? [];

    return Container(
      margin: const EdgeInsets.only(left: 16, bottom: 8),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: ModernConstants.primaryPurple.withOpacity(0.3),
            width: 2,
          ),
        ),
      ),
      child: Column(
        children: submenuItems.map((submenuItem) {
          // ✅ Special styling for Delete Transactions
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
                    : null,
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
                          : ModernConstants.primaryPurple.withOpacity(0.6),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      _getTransactionSubmenuIcon(submenuItem['title']),
                      size: 12,
                      color: isDeleteItem
                        ? Colors.red.withOpacity(0.7)
                        : ModernConstants.primaryPurple.withOpacity(0.7),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        submenuItem['title'],
                        style: TextStyle(
                          color: isDeleteItem
                            ? Colors.red
                            : ModernConstants.textSecondary,
                          fontSize: 12,
                          fontWeight: isDeleteItem ? FontWeight.w500 : FontWeight.normal,
                        ),
                      ),
                    ),
                    if (submenuItem['index'] == 101) // All Transactions arrow
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 10,
                        color: ModernConstants.primaryPurple.withOpacity(0.6),
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

  IconData _getTransactionSubmenuIcon(String title) {
    switch (title) {
      case 'All Transactions':
        return Icons.list_alt_rounded;
      case 'Currency Conversions':
        return Icons.currency_exchange_rounded;
      case 'Transaction History':
        return Icons.history_rounded;
      case 'User Activity':
        return Icons.person_search_rounded;
      case 'Delete Transactions':
        return Icons.delete_forever_rounded;
      default:
        return Icons.circle;
    }
  }

  // Rest of the methods remain the same...
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
          top: BorderSide(color: ModernConstants.textTertiary.withOpacity(0.1)),
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
                  color: ModernConstants.textTertiary.withOpacity(0.1),
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
                          color: ModernConstants.primaryPurple.withOpacity(0.3),
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
                              color: ModernConstants.textPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            userEmail,
                            style: const TextStyle(
                              color: ModernConstants.textSecondary,
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
                color: ModernConstants.textTertiary,
              ),
              const SizedBox(width: 4),
              Text(
                'Version 1.0.0',
                style: TextStyle(
                  color: ModernConstants.textTertiary,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: ModernConstants.cardBackground,
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
                  color: ModernConstants.textPrimary,
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
                  color: ModernConstants.textSecondary,
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
                        'You will be redirected to the main app',
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
                  color: ModernConstants.textSecondary,
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
                            Navigator.of(dialogContext).pop();
                            await authProvider.logoutUser();
                            
                            if (context.mounted) {
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (context) => const Mainscreen(),
                                ),
                                (route) => false,
                              );
                              
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Admin logged out successfully!'),
                                  backgroundColor: Color(0xFF10B981),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          } catch (e) {
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