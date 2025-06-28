import 'package:flutter/material.dart';
import '../../../utils/modern_constants.dart';
import '../../../utils/responsive_helper.dart';

class AppNotificationsContent extends StatelessWidget {
  const AppNotificationsContent({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    
    return SingleChildScrollView(
      padding: ResponsiveHelper.getScreenPadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(isMobile),
          SizedBox(height: isMobile ? 20 : 30),
          _buildNotificationsList(isMobile),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 20 : 24),
      decoration: BoxDecoration(
        gradient: ModernConstants.cardGradient,
        borderRadius: BorderRadius.circular(ModernConstants.cardRadius),
        boxShadow: ModernConstants.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: ModernConstants.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.notifications_rounded, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'App Notifications',
                  style: TextStyle(
                    color: ModernConstants.textPrimary,
                    fontSize: isMobile ? 20 : 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Manage app notifications and alerts',
                  style: TextStyle(
                    color: ModernConstants.textSecondary,
                    fontSize: isMobile ? 12 : 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList(bool isMobile) {
    final notifications = [
      {
        'title': 'Rate Alert Triggered',
        'message': 'USD/EUR has reached your target rate of 0.85',
        'time': '5 minutes ago',
        'type': 'alert',
        'read': false,
      },
      {
        'title': 'System Update',
        'message': 'Currency rates have been updated successfully',
        'time': '1 hour ago',
        'type': 'system',
        'read': true,
      },
      {
        'title': 'New User Registration',
        'message': 'A new user has registered on the platform',
        'time': '2 hours ago',
        'type': 'user',
        'read': true,
      },
    ];

    return Column(
      children: notifications.map((notification) {
        final isUnread = !(notification['read'] as bool);
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: ModernConstants.cardGradient,
            borderRadius: BorderRadius.circular(ModernConstants.cardRadius),
            boxShadow: ModernConstants.cardShadow,
            border: Border.all(
              color: isUnread 
                  ? ModernConstants.primaryPurple.withOpacity(0.3)
                  : ModernConstants.textTertiary.withOpacity(0.1),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getNotificationColor(notification['type'] as String).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getNotificationIcon(notification['type'] as String),
                  color: _getNotificationColor(notification['type'] as String),
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification['title'] as String,
                            style: TextStyle(
                              color: ModernConstants.textPrimary,
                              fontSize: 14,
                              fontWeight: isUnread ? FontWeight.bold : FontWeight.w500,
                            ),
                          ),
                        ),
                        if (isUnread)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: ModernConstants.primaryPurple,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification['message'] as String,
                      style: const TextStyle(
                        color: ModernConstants.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification['time'] as String,
                      style: TextStyle(
                        color: ModernConstants.textTertiary,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'alert':
        return const Color(0xFFF59E0B);
      case 'system':
        return const Color(0xFF10B981);
      case 'user':
        return ModernConstants.primaryBlue;
      default:
        return ModernConstants.primaryPurple;
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'alert':
        return Icons.warning_rounded;
      case 'system':
        return Icons.system_update_rounded;
      case 'user':
        return Icons.person_add_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }
}
