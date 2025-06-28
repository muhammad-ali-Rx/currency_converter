import 'package:flutter/material.dart';
import '../../../utils/modern_constants.dart';
import '../../../utils/responsive_helper.dart';

class ResponsiveActivityCard extends StatelessWidget {
  const ResponsiveActivityCard({super.key});

  final List<Map<String, dynamic>> _activities = const [
    {
      'title': 'New user registered',
      'subtitle': 'john.doe@email.com',
      'time': '2 min ago',
      'icon': Icons.person_add_rounded,
      'color': Color(0xFF10B981),
    },
    {
      'title': 'Currency conversion',
      'subtitle': 'USD to EUR - \$1,250',
      'time': '5 min ago',
      'icon': Icons.currency_exchange_rounded,
      'color': Color(0xFF3B82F6),
    },
    {
      'title': 'API rate limit reached',
      'subtitle': 'User: premium_user_01',
      'time': '12 min ago',
      'icon': Icons.warning_rounded,
      'color': Color(0xFFF59E0B),
    },
    {
      'title': 'System backup completed',
      'subtitle': 'Database backup successful',
      'time': '1 hour ago',
      'icon': Icons.backup_rounded,
      'color': Color(0xFF8B5CF6),
    },
    {
      'title': 'New admin login',
      'subtitle': 'admin@currencyapp.com',
      'time': '2 hours ago',
      'icon': Icons.admin_panel_settings_rounded,
      'color': Color(0xFFEC4899),
    },
  ];

  @override
  Widget build(BuildContext context) {
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Activity',
                style: TextStyle(
                  color: ModernConstants.textPrimary,
                  fontSize: isMobile ? 16 : 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: ModernConstants.primaryPurple.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.more_horiz_rounded,
                  color: ModernConstants.primaryPurple,
                  size: isMobile ? 16 : 18,
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 16 : 20),
          
          ...List.generate(
            isMobile ? 3 : _activities.length, 
            (index) {
              final activity = _activities[index];
              return Container(
                margin: EdgeInsets.only(bottom: isMobile ? 12 : 14),
                child: Row(
                  children: [
                    Container(
                      width: isMobile ? 32 : 36,
                      height: isMobile ? 32 : 36,
                      decoration: BoxDecoration(
                        color: activity['color'].withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        activity['icon'],
                        color: activity['color'],
                        size: isMobile ? 16 : 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            activity['title'],
                            style: TextStyle(
                              color: ModernConstants.textPrimary,
                              fontSize: isMobile ? 13 : 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            activity['subtitle'],
                            style: TextStyle(
                              color: ModernConstants.textSecondary,
                              fontSize: isMobile ? 11 : 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Text(
                      activity['time'],
                      style: TextStyle(
                        color: ModernConstants.textTertiary,
                        fontSize: isMobile ? 10 : 11,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          
          SizedBox(height: isMobile ? 12 : 16),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: isMobile ? 10 : 12),
            decoration: BoxDecoration(
              border: Border.all(
                color: ModernConstants.primaryPurple.withOpacity(0.3),
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'View All Activities',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: ModernConstants.primaryPurple,
                fontSize: isMobile ? 13 : 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
