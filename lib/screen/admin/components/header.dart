import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:currency_converter/auth/auth_provider.dart';
import '../../../utils/modern_constants.dart';

class Header extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback onMenuTap;
  final bool isMobile;

  const Header({
    super.key,
    required this.title,
    this.subtitle,
    required this.onMenuTap,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ModernConstants.sidebarBackground,
        border: Border(
          bottom: BorderSide(
            color: ModernConstants.textTertiary.withOpacity(0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          if (isMobile)
            IconButton(
              onPressed: onMenuTap,
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: ModernConstants.textTertiary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.menu_rounded,
                  color: ModernConstants.textSecondary,
                ),
              ),
            ),
          
          if (isMobile) const SizedBox(width: 16),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: ModernConstants.textPrimary,
                    fontSize: isMobile ? 20 : 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      color: ModernConstants.textSecondary,
                      fontSize: isMobile ? 12 : 14,
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              final userData = authProvider.userData;
              final userName = userData?['name'] ?? 'Admin';
              final userInitial = (userName.isNotEmpty ? userName[0] : 'A').toUpperCase();
              final profileImageBase64 = userData?['profileImageBase64'];

              return Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: profileImageBase64 == null || profileImageBase64.isEmpty
                      ? ModernConstants.primaryGradient
                      : null,
                  borderRadius: BorderRadius.circular(12),
                  border: profileImageBase64 != null && profileImageBase64.isNotEmpty
                      ? Border.all(
                          color: ModernConstants.primaryPurple.withOpacity(0.3),
                          width: 2,
                        )
                      : null,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: profileImageBase64 != null && profileImageBase64.isNotEmpty
                      ? _buildProfileImage(profileImageBase64, userInitial)
                      : Center(
                          child: Text(
                            userInitial,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage(String base64String, String fallbackInitial) {
    try {
      final bytes = base64Decode(base64String);
      return Image.memory(
        bytes,
        width: 40,
        height: 40,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: ModernConstants.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                fallbackInitial,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      );
    } catch (e) {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          gradient: ModernConstants.primaryGradient,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            fallbackInitial,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }
  }
}
