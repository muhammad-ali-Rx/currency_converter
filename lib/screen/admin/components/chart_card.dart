import 'package:flutter/material.dart';
import '../../../utils/modern_constants.dart';
import '../../../utils/responsive_helper.dart';

class ResponsiveChartCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String chartType;

  const ResponsiveChartCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.chartType,
  });

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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: ModernConstants.textPrimary,
                        fontSize: isMobile ? 16 : 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: ModernConstants.textSecondary,
                        fontSize: isMobile ? 12 : 13,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 8 : 10, 
                  vertical: isMobile ? 4 : 5,
                ),
                decoration: BoxDecoration(
                  gradient: ModernConstants.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'This Week',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isMobile ? 10 : 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 16 : 20),
          
          // Mock Chart
          SizedBox(
            height: isMobile ? 150 : 180,
            child: chartType == 'bar' ? _buildBarChart(context) : _buildLineChart(context),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(7, (index) {
        final heights = isMobile 
            ? [40.0, 60.0, 80.0, 65.0, 95.0, 75.0, 70.0]
            : [60.0, 80.0, 120.0, 90.0, 140.0, 110.0, 100.0];
        final colors = ModernConstants.chartColors;
        
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              width: isMobile ? 16 : 20,
              height: heights[index],
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colors[index % colors.length],
                    colors[index % colors.length].withOpacity(0.6),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: colors[index % colors.length].withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][index],
              style: TextStyle(
                color: ModernConstants.textTertiary,
                fontSize: isMobile ? 10 : 11,
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildLineChart(BuildContext context) {
    return CustomPaint(
      size: Size(double.infinity, ResponsiveHelper.isMobile(context) ? 150 : 180),
      painter: ResponsiveLineChartPainter(),
    );
  }
}

class ResponsiveLineChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [ModernConstants.primaryCyan, ModernConstants.primaryPurple],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final points = [
      Offset(0, size.height * 0.7),
      Offset(size.width * 0.2, size.height * 0.5),
      Offset(size.width * 0.4, size.height * 0.3),
      Offset(size.width * 0.6, size.height * 0.4),
      Offset(size.width * 0.8, size.height * 0.2),
      Offset(size.width, size.height * 0.3),
    ];

    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    canvas.drawPath(path, paint);

    // Draw points
    final pointPaint = Paint()
      ..color = ModernConstants.primaryCyan
      ..style = PaintingStyle.fill;

    for (final point in points) {
      canvas.drawCircle(point, 3, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
