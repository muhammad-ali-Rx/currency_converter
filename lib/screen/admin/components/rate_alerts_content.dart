import 'package:flutter/material.dart';
import '../../../utils/modern_constants.dart';
import '../../../utils/responsive_helper.dart';

class RateAlertsContent extends StatefulWidget {
  const RateAlertsContent({super.key});

  @override
  State<RateAlertsContent> createState() => _RateAlertsContentState();
}

class _RateAlertsContentState extends State<RateAlertsContent> {
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
          _buildAlertsList(isMobile),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Rate Alerts',
                style: TextStyle(
                  color: ModernConstants.textPrimary,
                  fontSize: isMobile ? 20 : 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Manage currency rate alerts',
                style: TextStyle(
                  color: ModernConstants.textSecondary,
                  fontSize: isMobile ? 12 : 14,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: ModernConstants.primaryGradient,
              borderRadius: BorderRadius.circular(12),
              boxShadow: ModernConstants.glowShadow,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.add_alert_rounded, color: Colors.white, size: 18),
                const SizedBox(width: 6),
                Text(
                  'Add Alert',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
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

  Widget _buildAlertsList(bool isMobile) {
    final alerts = [
      {'currency': 'USD/EUR', 'target': '0.85', 'current': '0.84', 'status': 'Active'},
      {'currency': 'GBP/USD', 'target': '1.25', 'current': '1.23', 'status': 'Active'},
      {'currency': 'USD/JPY', 'target': '150.00', 'current': '149.50', 'status': 'Triggered'},
    ];

    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        gradient: ModernConstants.cardGradient,
        borderRadius: BorderRadius.circular(ModernConstants.cardRadius),
        boxShadow: ModernConstants.cardShadow,
      ),
      child: Column(
        children: alerts.map((alert) {
          final isTriggered = alert['status'] == 'Triggered';
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isTriggered 
                  ? const Color(0xFF10B981).withOpacity(0.1)
                  : ModernConstants.textTertiary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isTriggered 
                    ? const Color(0xFF10B981).withOpacity(0.3)
                    : ModernConstants.textTertiary.withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isTriggered 
                        ? const Color(0xFF10B981).withOpacity(0.2)
                        : ModernConstants.primaryPurple.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isTriggered ? Icons.check_circle_rounded : Icons.notifications_active_rounded,
                    color: isTriggered ? const Color(0xFF10B981) : ModernConstants.primaryPurple,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        alert['currency']!,
                        style: const TextStyle(
                          color: ModernConstants.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Target: ${alert['target']} | Current: ${alert['current']}',
                        style: const TextStyle(
                          color: ModernConstants.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isTriggered 
                        ? const Color(0xFF10B981).withOpacity(0.2)
                        : ModernConstants.primaryBlue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    alert['status']!,
                    style: TextStyle(
                      color: isTriggered ? const Color(0xFF10B981) : ModernConstants.primaryBlue,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
