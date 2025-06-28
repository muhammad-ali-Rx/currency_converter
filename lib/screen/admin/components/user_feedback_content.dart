import 'package:flutter/material.dart';
import '../../../utils/modern_constants.dart';
import '../../../utils/responsive_helper.dart';

class UserFeedbackContent extends StatelessWidget {
  const UserFeedbackContent({super.key});

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
          _buildFeedbackStats(isMobile),
          SizedBox(height: isMobile ? 20 : 30),
          _buildRecentFeedback(isMobile),
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
            child: const Icon(Icons.feedback_rounded, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'User Feedback',
                  style: TextStyle(
                    color: ModernConstants.textPrimary,
                    fontSize: isMobile ? 20 : 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'User reviews and feedback management',
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

  Widget _buildFeedbackStats(bool isMobile) {
    final stats = [
      {'title': 'Total Reviews', 'value': '1,234', 'icon': Icons.rate_review_rounded},
      {'title': 'Average Rating', 'value': '4.5', 'icon': Icons.star_rounded},
      {'title': 'This Month', 'value': '89', 'icon': Icons.calendar_month_rounded},
      {'title': 'Pending', 'value': '12', 'icon': Icons.pending_rounded},
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
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
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
                  color: ModernConstants.primaryPurple.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  stat['icon'] as IconData,
                  color: ModernConstants.primaryPurple,
                  size: 24,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                stat['value'] as String,
                style: const TextStyle(
                  color: ModernConstants.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                stat['title'] as String,
                style: const TextStyle(
                  color: ModernConstants.textSecondary,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRecentFeedback(bool isMobile) {
    final feedback = [
      {
        'user': 'John Doe',
        'rating': 5,
        'comment': 'Excellent app! Very accurate currency conversion rates.',
        'time': '2 hours ago',
        'status': 'Published',
      },
      {
        'user': 'Jane Smith',
        'rating': 4,
        'comment': 'Good app but could use better UI design.',
        'time': '5 hours ago',
        'status': 'Published',
      },
      {
        'user': 'Mike Johnson',
        'rating': 3,
        'comment': 'App crashes sometimes when converting large amounts.',
        'time': '1 day ago',
        'status': 'Pending',
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
            'Recent Feedback',
            style: TextStyle(
              color: ModernConstants.textPrimary,
              fontSize: isMobile ? 16 : 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...feedback.map((review) {
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
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
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: ModernConstants.primaryPurple,
                        child: Text(
                          (review['user']! as String).split(' ').map((e) => e[0]).join(''),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              review['user']! as String,
                              style: const TextStyle(
                                color: ModernConstants.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Row(
                              children: List.generate(5, (index) {
                                return Icon(
                                  index < (review['rating'] as int) 
                                      ? Icons.star_rounded 
                                      : Icons.star_outline_rounded,
                                  color: const Color(0xFFF59E0B),
                                  size: 16,
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: review['status'] == 'Published'
                              ? const Color(0xFF10B981).withOpacity(0.2)
                              : const Color(0xFFF59E0B).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                            (review['status']! as String),
                          style: TextStyle(
                            color: review['status'] == 'Published'
                                ? const Color(0xFF10B981)
                                : const Color(0xFFF59E0B),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    (review['comment']! as String),
                    style: const TextStyle(
                      color: ModernConstants.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    (review['time']! as String),
                    style: TextStyle(
                      color: ModernConstants.textTertiary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
