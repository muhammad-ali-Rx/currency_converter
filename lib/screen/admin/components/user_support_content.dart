import 'package:flutter/material.dart';
import '../../../utils/modern_constants.dart';
import '../../../utils/responsive_helper.dart';

class UserSupportContent extends StatelessWidget {
  const UserSupportContent({super.key});

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
          _buildSupportOptions(isMobile),
          SizedBox(height: isMobile ? 20 : 30),
          _buildRecentTickets(isMobile),
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
            child: const Icon(Icons.help_center_rounded, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'User Support & Help Center',
                  style: TextStyle(
                    color: ModernConstants.textPrimary,
                    fontSize: isMobile ? 18 : 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Help users and manage support tickets',
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

  Widget _buildSupportOptions(bool isMobile) {
    final options = [
      {'title': 'Live Chat', 'icon': Icons.chat_rounded, 'color': const Color(0xFF10B981)},
      {'title': 'Email Support', 'icon': Icons.email_rounded, 'color': ModernConstants.primaryBlue},
      {'title': 'FAQ', 'icon': Icons.quiz_rounded, 'color': ModernConstants.primaryPurple},
      {'title': 'Video Tutorials', 'icon': Icons.play_circle_rounded, 'color': const Color(0xFFF59E0B)},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isMobile ? 2 : 4,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: isMobile ? 1.2 : 1.1,
      ),
      itemCount: options.length,
      itemBuilder: (context, index) {
        final option = options[index];
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: ModernConstants.cardGradient,
            borderRadius: BorderRadius.circular(ModernConstants.cardRadius),
            boxShadow: ModernConstants.cardShadow,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (option['color'] as Color).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  option['icon'] as IconData,
                  color: option['color'] as Color,
                  size: 28,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                option['title'] as String,
                style: const TextStyle(
                  color: ModernConstants.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRecentTickets(bool isMobile) {
    final tickets = [
      {
        'id': '#12345',
        'title': 'Currency conversion issue',
        'user': 'john@example.com',
        'status': 'Open',
        'priority': 'High',
        'time': '2 hours ago',
      },
      {
        'id': '#12344',
        'title': 'Account verification problem',
        'user': 'jane@example.com',
        'status': 'In Progress',
        'priority': 'Medium',
        'time': '4 hours ago',
      },
      {
        'id': '#12343',
        'title': 'API integration help',
        'user': 'dev@company.com',
        'status': 'Resolved',
        'priority': 'Low',
        'time': '1 day ago',
      },
    ];

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
          Text(
            'Recent Support Tickets',
            style: TextStyle(
              color: ModernConstants.textPrimary,
              fontSize: isMobile ? 16 : 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...tickets.map((ticket) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ModernConstants.textTertiary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        ticket['id']!,
                        style: const TextStyle(
                          color: ModernConstants.primaryPurple,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(ticket['status']!).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          ticket['status']!,
                          style: TextStyle(
                            color: _getStatusColor(ticket['status']!),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    ticket['title']!,
                    style: const TextStyle(
                      color: ModernConstants.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'User: ${ticket['user']!}',
                    style: const TextStyle(
                      color: ModernConstants.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'Priority: ${ticket['priority']!}',
                        style: TextStyle(
                          color: _getPriorityColor(ticket['priority']!),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        ticket['time']!,
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
          }).toList(),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Open':
        return const Color(0xFFF59E0B);
      case 'In Progress':
        return ModernConstants.primaryBlue;
      case 'Resolved':
        return const Color(0xFF10B981);
      default:
        return ModernConstants.textSecondary;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'High':
        return const Color(0xFFEF4444);
      case 'Medium':
        return const Color(0xFFF59E0B);
      case 'Low':
        return const Color(0xFF10B981);
      default:
        return ModernConstants.textSecondary;
    }
  }
}
