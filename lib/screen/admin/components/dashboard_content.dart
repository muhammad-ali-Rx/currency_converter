import 'package:currency_converter/screen/admin/components/activity_card.dart';
import 'package:currency_converter/screen/admin/components/chart_card.dart';
import 'package:currency_converter/screen/admin/components/stat_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../auth/auth_provider.dart';
import '../../../utils/modern_constants.dart';
import '../../../utils/responsive_helper.dart';

class ResponsiveDashboardContent extends StatefulWidget {
  const ResponsiveDashboardContent({super.key});

  @override
  State<ResponsiveDashboardContent> createState() => _ResponsiveDashboardContentState();
}

class _ResponsiveDashboardContentState extends State<ResponsiveDashboardContent> {
  List<Map<String, dynamic>> users = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final usersList = await authProvider.getAllUsers();
    setState(() {
      users = usersList;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);
    
    return SingleChildScrollView(
      padding: ResponsiveHelper.getScreenPadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeSection(),
          SizedBox(height: isMobile ? 24 : 32),
          _buildStatsSection(),
          SizedBox(height: isMobile ? 24 : 32),
          if (isMobile) 
            _buildMobileChartsSection()
          else if (isTablet)
            _buildTabletChartsSection()
          else
            _buildDesktopChartsSection(),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    final isMobile = ResponsiveHelper.isMobile(context);
    
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Container(
          padding: EdgeInsets.all(isMobile ? 20 : 24),
          decoration: BoxDecoration(
            gradient: ModernConstants.primaryGradient,
            borderRadius: BorderRadius.circular(ModernConstants.cardRadius),
            boxShadow: ModernConstants.glowShadow,
          ),
          child: isMobile ? _buildMobileWelcome(authProvider) : _buildDesktopWelcome(authProvider),
        );
      },
    );
  }

  Widget _buildMobileWelcome(AuthProvider authProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: ResponsiveHelper.getTitleFontSize(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    authProvider.userData?['name'] ?? 'Admin',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Icon(
                Icons.currency_exchange_rounded,
                size: 30,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Here\'s your currency converter overview',
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(child: _buildQuickAction('Reports', Icons.assessment_rounded)),
            const SizedBox(width: 12),
            Expanded(child: _buildQuickAction('Users', Icons.people_rounded)),
          ],
        ),
      ],
    );
  }

  Widget _buildDesktopWelcome(AuthProvider authProvider) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back, ${authProvider.userData?['name'] ?? 'Admin'}!',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Here\'s what\'s happening with your currency converter today.',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  _buildQuickAction('View Reports', Icons.assessment_rounded),
                  const SizedBox(width: 16),
                  _buildQuickAction('Manage Users', Icons.people_rounded),
                ],
              ),
            ],
          ),
        ),
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(60),
          ),
          child: const Icon(
            Icons.currency_exchange_rounded,
            size: 60,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAction(String title, IconData icon) {
    final isMobile = ResponsiveHelper.isMobile(context);
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 16, 
        vertical: isMobile ? 6 : 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: isMobile ? 14 : 16),
          const SizedBox(width: 6),
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: isMobile ? 12 : 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    final columns = ResponsiveHelper.getStatsColumns(context);
    final isMobile = ResponsiveHelper.isMobile(context);
    
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: columns,
      crossAxisSpacing: isMobile ? 12 : 16,
      mainAxisSpacing: isMobile ? 12 : 16,
      childAspectRatio: isMobile ? 1.3 : 1.2,
      children: [
        ResponsiveStatCard(
          title: 'Total Users',
          value: users.length.toString(),
          change: '+12%',
          isPositive: true,
          icon: Icons.people_rounded,
          color: ModernConstants.primaryBlue,
        ),
        ResponsiveStatCard(
          title: 'Conversions',
          value: '${(users.length * 3.2).round()}',
          change: '+8%',
          isPositive: true,
          icon: Icons.currency_exchange_rounded,
          color: ModernConstants.primaryCyan,
        ),
        ResponsiveStatCard(
          title: 'Active Sessions',
          value: '${users.where((u) => u['authProvider'] != null).length}',
          change: '+15%',
          isPositive: true,
          icon: Icons.online_prediction_rounded,
          color: ModernConstants.primaryPink,
        ),
        ResponsiveStatCard(
          title: 'API Calls',
          value: '${(users.length * 45).round()}K',
          change: '-2%',
          isPositive: false,
          icon: Icons.api_rounded,
          color: ModernConstants.primaryPurple,
        ),
      ],
    );
  }

  Widget _buildMobileChartsSection() {
    return Column(
      children: [
        ResponsiveChartCard(
          title: 'Currency Conversions',
          subtitle: 'Real-time trends',
          chartType: 'bar',
        ),
        const SizedBox(height: 16),
        ResponsiveChartCard(
          title: 'User Activity',
          subtitle: 'Active users',
          chartType: 'line',
        ),
        const SizedBox(height: 16),
        ResponsiveActivityCard(),
        const SizedBox(height: 16),
        _buildPromotionCard(),
      ],
    );
  }

  Widget _buildTabletChartsSection() {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ResponsiveChartCard(
                title: 'Currency Conversions',
                subtitle: 'Real-time trends',
                chartType: 'bar',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ResponsiveActivityCard(),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ResponsiveChartCard(
                title: 'User Activity',
                subtitle: 'Active users',
                chartType: 'line',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildPromotionCard(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDesktopChartsSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            children: [
              ResponsiveChartCard(
                title: 'Currency Conversions',
                subtitle: 'Real-time conversion trends',
                chartType: 'bar',
              ),
              const SizedBox(height: 24),
              ResponsiveChartCard(
                title: 'User Activity',
                subtitle: 'Active users over time',
                chartType: 'line',
              ),
            ],
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          flex: 1,
          child: Column(
            children: [
              ResponsiveActivityCard(),
              const SizedBox(height: 24),
              _buildPromotionCard(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPromotionCard() {
    final isMobile = ResponsiveHelper.isMobile(context);
    
    return Container(
      padding: EdgeInsets.all(isMobile ? 20 : 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(ModernConstants.cardRadius),
        boxShadow: ModernConstants.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Upgrade Plan',
            style: TextStyle(
              color: Colors.white,
              fontSize: isMobile ? 18 : 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: isMobile ? 6 : 8),
          Text(
            'Get premium features and unlimited API calls.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: isMobile ? 13 : 14,
            ),
          ),
          SizedBox(height: isMobile ? 16 : 20),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: isMobile ? 10 : 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Upgrade Now',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFF8B5CF6),
                fontSize: isMobile ? 14 : 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
