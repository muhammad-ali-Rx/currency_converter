import 'package:flutter/material.dart';

class ResponsiveHelper {
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 768;
  }
  
  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width >= 768 && 
           MediaQuery.of(context).size.width < 1024;
  }
  
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1024;
  }
  
  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }
  
  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }
  
  // Grid columns based on screen size
  static int getGridColumns(BuildContext context) {
    if (isMobile(context)) return 1;
    if (isTablet(context)) return 2;
    return 3;
  }
  
  // Stats cards columns
  static int getStatsColumns(BuildContext context) {
    if (isMobile(context)) return 2;
    if (isTablet(context)) return 2;
    return 4;
  }
  
  // Sidebar width
  static double getSidebarWidth(BuildContext context) {
    if (isMobile(context)) return MediaQuery.of(context).size.width * 0.8;
    return 280;
  }
  
  // Padding based on screen size
  static EdgeInsets getScreenPadding(BuildContext context) {
    if (isMobile(context)) return const EdgeInsets.all(16);
    if (isTablet(context)) return const EdgeInsets.all(20);
    return const EdgeInsets.all(24);
  }
  
  // Font sizes
  static double getTitleFontSize(BuildContext context) {
    if (isMobile(context)) return 20;
    if (isTablet(context)) return 24;
    return 28;
  }
  
  static double getSubtitleFontSize(BuildContext context) {
    if (isMobile(context)) return 14;
    return 16;
  }
}
