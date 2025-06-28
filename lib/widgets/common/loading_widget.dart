import 'package:flutter/material.dart';
import '../../utils/modern_constants.dart';

class LoadingWidget extends StatelessWidget {
  final String? message;
  final double? size;

  const LoadingWidget({
    super.key,
    this.message,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: size ?? 60,
            height: size ?? 60,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: ModernConstants.cardGradient,
              borderRadius: BorderRadius.circular(30),
              boxShadow: ModernConstants.cardShadow,
            ),
            child: CircularProgressIndicator(
              color: ModernConstants.primaryPurple,
              strokeWidth: 3,
              backgroundColor: ModernConstants.primaryPurple.withOpacity(0.2),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 24),
            Text(
              message!,
              style: TextStyle(
                color: ModernConstants.textSecondary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
