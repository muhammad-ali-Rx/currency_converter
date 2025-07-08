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
      users = usersList ?? [];
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(ModernConstants.primaryPurple),
        ),
      );
    }
    
    return SingleChildScrollView(
      padding: ResponsiveHelper.getScreenPadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeSection(),
          SizedBox(height: isMobile ? 24 : 32),
          _buildStatsSection(),
          SizedBox(height: isMobile ? 24 : 32),
          _buildUsersSection(),
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
        _buildStatCard(
          'Total Users',
          users.length.toString(),
          '+12%',
          true,
          Icons.people_rounded,
          ModernConstants.primaryBlue,
        ),
        _buildStatCard(
          'Total Currency',
          '${(users.length * 2.5).round()}',
          '+18%',
          true,
          Icons.currency_exchange_rounded,
          ModernConstants.primaryCyan,
        ),
        _buildStatCard(
          'Admin Users',
          '${users.where((u) => (u['role']?.toString() ?? 'user').toLowerCase() == 'admin').length}',
          '+15%',
          true,
          Icons.admin_panel_settings_rounded,
          ModernConstants.primaryPink,
        ),
        _buildStatCard(
          'Transitions',
          '${(users.length * 45).round()}K',
          '+5%',
          true,
          Icons.swap_horiz_rounded,
          ModernConstants.primaryPurple,
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, String change, bool isPositive, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: ModernConstants.cardGradient,
        borderRadius: BorderRadius.circular(ModernConstants.cardRadius),
        boxShadow: ModernConstants.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isPositive ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  change,
                  style: TextStyle(
                    color: isPositive ? Colors.green : Colors.red,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: ModernConstants.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              color: ModernConstants.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersSection() {
    final isMobile = ResponsiveHelper.isMobile(context);
    
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        gradient: ModernConstants.cardGradient,
        borderRadius: BorderRadius.circular(ModernConstants.cardRadius),
        boxShadow: ModernConstants.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: ModernConstants.primaryBlue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.people_rounded,
                  color: ModernConstants.primaryBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Recent Users',
                style: TextStyle(
                  color: ModernConstants.textPrimary,
                  fontSize: isMobile ? 16 : 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '${users.length} total',
                style: TextStyle(
                  color: ModernConstants.textSecondary,
                  fontSize: isMobile ? 12 : 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (users.isEmpty)
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 48,
                    color: ModernConstants.textTertiary,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No users found',
                    style: TextStyle(
                      color: ModernConstants.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: users.length > 8 ? 8 : users.length, // Show only first 8 users
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final user = users[index];
                return _buildUserCard(user);
              },
            ),
          if (users.length > 8) ...[
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () {
                  // Navigate to full users page
                },
                child: Text(
                  'View All Users (${users.length})',
                  style: const TextStyle(
                    color: ModernConstants.primaryBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final userName = user['name']?.toString() ?? user['displayName']?.toString() ?? 'Unknown User';
    final userEmail = user['email']?.toString() ?? 'No email';
    final userRole = user['role']?.toString() ?? 'user';
    final isAdmin = userRole.toLowerCase() == 'admin';
    
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: ModernConstants.textTertiary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isAdmin 
              ? ModernConstants.primaryPurple.withOpacity(0.3)
              : ModernConstants.textTertiary.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: isMobile ? 20 : 24,
                backgroundColor: isAdmin ? ModernConstants.primaryPurple : ModernConstants.primaryBlue,
                child: Text(
                  userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isMobile ? 14 : 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (isAdmin)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      gradient: ModernConstants.primaryGradient,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.star_rounded,
                      color: Colors.white,
                      size: isMobile ? 10 : 12,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: TextStyle(
                    color: ModernConstants.textPrimary,
                    fontSize: isMobile ? 14 : 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  userEmail,
                  style: TextStyle(
                    color: ModernConstants.textSecondary,
                    fontSize: isMobile ? 12 : 14,
                  ),
                ),
                if (user['createdAt'] != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Joined ${_formatTime(user['createdAt'])}',
                    style: TextStyle(
                      color: ModernConstants.textTertiary,
                      fontSize: isMobile ? 10 : 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isAdmin
                      ? ModernConstants.primaryPurple.withOpacity(0.2)
                      : ModernConstants.primaryBlue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  userRole.toUpperCase(),
                  style: TextStyle(
                    color: isAdmin ? ModernConstants.primaryPurple : ModernConstants.primaryBlue,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              if (user['isActive'] == true || user['authProvider'] != null)
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(dynamic timestamp) {
    try {
      DateTime dateTime;
      
      if (timestamp == null) return 'Unknown';
      
      if (timestamp.runtimeType.toString().contains('Timestamp')) {
        dateTime = timestamp.toDate();
      } else if (timestamp is String) {
        dateTime = DateTime.parse(timestamp);
      } else if (timestamp is DateTime) {
        dateTime = timestamp;
      } else {
        return 'Unknown';
      }
      
      final now = DateTime.now();
      final difference = now.difference(dateTime);
      
      if (difference.inDays > 30) {
        final months = (difference.inDays / 30).floor();
        return '$months month${months > 1 ? 's' : ''} ago';
      } else if (difference.inDays > 0) {
        return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Unknown';
    }
  }
}
