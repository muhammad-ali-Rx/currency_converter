import 'package:currency_converter/screen/admin/components/admin_drawer.dart';
import 'package:currency_converter/screen/admin/components/dashboard_content.dart';
import 'package:currency_converter/screen/admin/components/header.dart';
import 'package:currency_converter/screen/admin/components/users_management.dart';
import 'package:currency_converter/screen/admin/components/rate_alerts_content.dart';
import 'package:currency_converter/screen/admin/components/currency_news_content.dart';
import 'package:currency_converter/screen/admin/components/market_trends_content.dart';
import 'package:currency_converter/screen/admin/components/app_notifications_content.dart';
import 'package:currency_converter/screen/admin/components/user_support_content.dart';
import 'package:currency_converter/screen/admin/components/user_feedback_content.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/auth_provider.dart';
import '../../utils/modern_constants.dart';
import '../../utils/responsive_helper.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _ResponsiveAdminDashboardState();
}

class _ResponsiveAdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0; // Start with Home
  bool _isSidebarOpen = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  final List<String> _pageTitles = [
    'Home',
    'Dashboard',
    'Users Management',
    'Settings',
    'Rate Alerts',
    'Currency News',
    'Market Trends',
    'App Notifications',
    'User Support',
    'User Feedback',
  ];

  final List<String> _pageDescriptions = [
    'Welcome to CurrencyAdmin',
    'Overview of your currency converter',
    'Manage all registered users',
    'Configure system settings',
    'Manage currency rate alerts',
    'Latest currency news and updates',
    'Market trends and analysis',
    'App notification management',
    'User support and help center',
    'User feedback and reviews',
  ];

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: ModernConstants.darkBackground,
      drawer: isMobile ? _buildMobileDrawer() : null,
      body: isMobile ? _buildMobileLayout() : _buildDesktopLayout(),
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        Header(
          title: _pageTitles[_selectedIndex],
          subtitle: _pageDescriptions[_selectedIndex],
          onMenuTap: () {
            _scaffoldKey.currentState?.openDrawer();
          },
          isMobile: true,
        ),
        Expanded(child: _buildContent()),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        AdminDrawer(
          selectedIndex: _selectedIndex,
          onItemSelected: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
        Expanded(
          child: Column(
            children: [
              Header(
                title: _pageTitles[_selectedIndex],
                subtitle: _pageDescriptions[_selectedIndex],
                onMenuTap: () {},
                isMobile: false,
              ),
              Expanded(child: _buildContent()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileDrawer() {
    return Drawer(
      backgroundColor: ModernConstants.sidebarBackground,
      child: AdminDrawer(
        selectedIndex: _selectedIndex,
        onItemSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
          Navigator.pop(context);
        },
        isMobile: true,
      ),
    );
  }
  Widget _buildContent() {
    switch (_selectedIndex) {
      case 2:
        return const UsersManagement();
      case 3:
        return _buildPlaceholderContent('Settings', Icons.settings);
      case 4:
        return const RateAlertsContent();
      case 5:
        return const CurrencyNewsContent();
      case 6:
        return const MarketTrendsContent();
      case 7:
        return const AppNotificationsContent();
      case 8:
        return const UserSupportContent();
      case 9:
        return const UserFeedbackContent();
      default:
        return const ResponsiveDashboardContent();
    }
  }

  Widget _buildPlaceholderContent(String title, IconData icon) {
    return Center(
      child: Container(
        margin: ResponsiveHelper.getScreenPadding(context),
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          gradient: ModernConstants.cardGradient,
          borderRadius: BorderRadius.circular(ModernConstants.cardRadius),
          boxShadow: ModernConstants.cardShadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: ModernConstants.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: ModernConstants.glowShadow,
              ),
              child: Icon(icon, size: 40, color: Colors.white),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: TextStyle(
                color: ModernConstants.textPrimary,
                fontSize: ResponsiveHelper.getTitleFontSize(context),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Coming Soon',
              style: TextStyle(
                color: ModernConstants.textSecondary,
                fontSize: ResponsiveHelper.getSubtitleFontSize(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
