import 'package:flutter/material.dart';
import '../utils/modern_constants.dart';

class MobileSidebar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;
  final VoidCallback onClose;

  const MobileSidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.onClose,
  });

  @override
  State<MobileSidebar> createState() => _MobileSidebarState();
}

class _MobileSidebarState extends State<MobileSidebar> {
  final Map<int, bool> _expandedSections = {};

  final List<Map<String, dynamic>> _menuItems = [
    {
      'icon': Icons.dashboard_rounded,
      'title': 'Dashboard',
      'index': 0,
      'hasSubmenu': true,
      'submenu': [
        {'title': 'Overview', 'index': 0},
        {'title': 'Statistics', 'index': 0},
        {'title': 'Recent Activity', 'index': 0},
      ]
    },
    {
      'icon': Icons.people_rounded,
      'title': 'Users',
      'index': 1,
      'hasSubmenu': true,
      'submenu': [
        {'title': 'All Users', 'index': 1},
        {'title': 'Add User', 'index': 1},
        {'title': 'User Roles', 'index': 1},
        {'title': 'Permissions', 'index': 1},
      ]
    },
    {
      'icon': Icons.analytics_rounded,
      'title': 'Analytics',
      'index': 2,
      'hasSubmenu': true,
      'submenu': [
        {'title': 'Conversion Rates', 'index': 2},
        {'title': 'Usage Stats', 'index': 2},
        {'title': 'Performance', 'index': 2},
      ]
    },
    {
      'icon': Icons.assessment_rounded,
      'title': 'Reports',
      'index': 3,
      'hasSubmenu': true,
      'submenu': [
        {'title': 'Generate Report', 'index': 3},
        {'title': 'Scheduled Reports', 'index': 3},
        {'title': 'Export Data', 'index': 3},
      ]
    },
    {
      'icon': Icons.settings_rounded,
      'title': 'Settings',
      'index': 4,
      'hasSubmenu': true,
      'submenu': [
        {'title': 'General', 'index': 4},
        {'title': 'Currency Config', 'index': 4},
        {'title': 'API Settings', 'index': 4},
        {'title': 'Notifications', 'index': 4},
      ]
    },
    {
      'icon': Icons.api_rounded,
      'title': 'API',
      'index': 5,
      'hasSubmenu': true,
      'submenu': [
        {'title': 'Documentation', 'index': 5},
        {'title': 'API Keys', 'index': 5},
        {'title': 'Rate Limits', 'index': 5},
        {'title': 'Webhooks', 'index': 5},
      ]
    },
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final sidebarWidth = screenWidth * 0.8;

    return Container(
      width: sidebarWidth,
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
          IconButton(
            onPressed: widget.onClose,
            icon: const Icon(
              Icons.close_rounded,
              color: ModernConstants.textSecondary,
              size: 20,
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
            if (isExpanded) _buildSubmenu(item),
          ],
        );
      },
    );
  }

  Widget _buildMenuItem(Map<String, dynamic> item, bool isSelected, bool isExpanded) {
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
              widget.onItemSelected(item['index']);
              widget.onClose();
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(14),
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
                      : (isExpanded ? ModernConstants.primaryPurple : ModernConstants.textSecondary),
                  size: 22,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    item['title'],
                    style: TextStyle(
                      color: isSelected 
                          ? Colors.white 
                          : (isExpanded ? ModernConstants.textPrimary : ModernConstants.textSecondary),
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
                if (item['hasSubmenu'] == true)
                  Icon(
                    isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: isSelected 
                        ? Colors.white 
                        : (isExpanded ? ModernConstants.primaryPurple : ModernConstants.textSecondary),
                    size: 18,
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
      margin: const EdgeInsets.only(left: 18, bottom: 8),
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
          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                widget.onItemSelected(item['index']);
                widget.onClose();
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: ModernConstants.primaryPurple.withOpacity(0.6),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        submenuItem['title'],
                        style: const TextStyle(
                          color: ModernConstants.textSecondary,
                          fontSize: 14,
                        ),
                      ),
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

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: ModernConstants.textTertiary.withOpacity(0.1),
          ),
        ),
      ),
      child: Column(
        children: [
          Container(
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
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4CAF50), Color(0xFF2196F3)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text(
                      'A',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Admin User',
                        style: TextStyle(
                          color: ModernConstants.textPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'admin@currency.com',
                        style: TextStyle(
                          color: ModernConstants.textSecondary,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
}
