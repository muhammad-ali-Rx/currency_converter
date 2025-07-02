import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

// Your existing model
class SimpleRateAlert {
  final String id;
  final String fromCurrency;
  final String toCurrency;
  final double targetRate;
  final String condition; // 'above' or 'below'
  final DateTime createdAt;
  final bool isActive;

  SimpleRateAlert({
    required this.id,
    required this.fromCurrency,
    required this.toCurrency,
    required this.targetRate,
    required this.condition,
    required this.createdAt,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fromCurrency': fromCurrency,
      'toCurrency': toCurrency,
      'targetRate': targetRate,
      'condition': condition,
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
    };
  }

  factory SimpleRateAlert.fromMap(Map<String, dynamic> map) {
    DateTime parsedDate;
    
    final createdAtField = map['createdAt'];
    
    if (createdAtField is Timestamp) {
      parsedDate = createdAtField.toDate();
    } else if (createdAtField is String) {
      parsedDate = DateTime.parse(createdAtField);
    } else {
      parsedDate = DateTime.now();
      print('Warning: createdAt field type not recognized, using current time');
    }
    
    return SimpleRateAlert(
      id: map['id'] ?? '',
      fromCurrency: map['fromCurrency'] ?? '',
      toCurrency: map['toCurrency'] ?? '',
      targetRate: (map['targetRate'] ?? 0.0).toDouble(),
      condition: map['condition'] ?? 'above',
      createdAt: parsedDate,
      isActive: map['isActive'] ?? true,
    );
  }
}

// Extended model for admin panel with user info
class AdminRateAlert {
  final SimpleRateAlert alert;
  final Map<String, dynamic> userInfo;
  final String userId;

  AdminRateAlert({
    required this.alert,
    required this.userInfo,
    required this.userId,
  });
}

// Modern Constants
class ModernConstants {
  static const Color backgroundColor = Color(0xFF0F0F23);
  static const Color cardBackground = Color(0xFF1A1A2E);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color textTertiary = Color(0xFF6B7280);
  static const Color accent = Color(0xFF10B981);
  static const Color accentSecondary = Color(0xFF059669);
  static const Color primaryPurple = Color(0xFF8B5CF6);
  
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1A1A2E),
      Color(0xFF16213E),
    ],
  );
  
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryPurple, Color(0xFF7C3AED)],
  );
}

// Responsive Helper
class ResponsiveHelper {
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 768;
  }
  
  static EdgeInsets getScreenPadding(BuildContext context) {
    return EdgeInsets.symmetric(
      horizontal: isMobile(context) ? 16 : 24,
      vertical: 16,
    );
  }
  
  static double getTitleFontSize(BuildContext context) {
    return isMobile(context) ? 24 : 28;
  }
  
  static double getSubtitleFontSize(BuildContext context) {
    return isMobile(context) ? 14 : 16;
  }
}

// Loading Widget
class LoadingWidget extends StatelessWidget {
  final String message;
  
  const LoadingWidget({super.key, required this.message});
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(ModernConstants.accent),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              color: ModernConstants.textSecondary,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

// Empty State Widget
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionText;
  final VoidCallback? onAction;
  
  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionText,
    this.onAction,
  });
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: ModernConstants.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              color: ModernConstants.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(
              color: ModernConstants.textSecondary,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          if (actionText != null && onAction != null) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: ModernConstants.accent,
                foregroundColor: Colors.white,
              ),
              child: Text(actionText!),
            ),
          ],
        ],
      ),
    );
  }
}

// SHOW ALERTS SCREEN - READ ONLY
class ShowAlertsScreen extends StatefulWidget {
  const ShowAlertsScreen({super.key});

  @override
  State<ShowAlertsScreen> createState() => _ShowAlertsScreenState();
}

class _ShowAlertsScreenState extends State<ShowAlertsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  List<AdminRateAlert> allAlerts = [];
  List<AdminRateAlert> activeAlerts = [];
  List<AdminRateAlert> inactiveAlerts = [];
  List<AdminRateAlert> aboveAlerts = [];
  List<AdminRateAlert> belowAlerts = [];
  
  bool isLoading = true;
  String searchQuery = '';
  String? errorMessage;
  
  final List<Map<String, dynamic>> _tabs = [
    {
      'title': 'All Alerts',
      'icon': Icons.notifications_active_rounded,
      'color': ModernConstants.primaryPurple,
    },
    {
      'title': 'Active',
      'icon': Icons.notifications_rounded,
      'color': ModernConstants.accent,
    },
    {
      'title': 'Inactive',
      'icon': Icons.notifications_off_rounded,
      'color': const Color(0xFF6B7280),
    },
    {
      'title': 'Above',
      'icon': Icons.trending_up_rounded,
      'color': const Color(0xFF3B82F6),
    },
    {
      'title': 'Below',
      'icon': Icons.trending_down_rounded,
      'color': const Color(0xFFF59E0B),
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadAllData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAllData() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final alertsQuery = await FirebaseFirestore.instance
          .collection('rate_alerts')
          .orderBy('createdAt', descending: true)
          .limit(500)
          .get();

      final List<AdminRateAlert> loadedAlerts = [];
      
      for (var doc in alertsQuery.docs) {
        try {
          final data = doc.data();
          
          final alert = SimpleRateAlert.fromMap({
            ...data,
            'id': doc.id,
          });
          
          final userId = data['userId'] ?? data['user_id'] ?? '';
          Map<String, dynamic> userInfo = {};
          
          if (userId.isNotEmpty) {
            try {
              final userDoc = await FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .get();
              
              if (userDoc.exists) {
                userInfo = userDoc.data() ?? {};
              }
            } catch (e) {
              print('Error fetching user info for $userId: $e');
            }
          }
          
          if (userInfo.isEmpty) {
            userInfo = {
              'name': 'Unknown User',
              'email': 'No email',
              'uid': userId,
            };
          }
          
          loadedAlerts.add(AdminRateAlert(
            alert: alert,
            userInfo: userInfo,
            userId: userId,
          ));
          
        } catch (e) {
          print('Error processing alert document ${doc.id}: $e');
        }
      }

      final List<AdminRateAlert> active = loadedAlerts
          .where((adminAlert) => adminAlert.alert.isActive)
          .toList();
      
      final List<AdminRateAlert> inactive = loadedAlerts
          .where((adminAlert) => !adminAlert.alert.isActive)
          .toList();
      
      final List<AdminRateAlert> above = loadedAlerts
          .where((adminAlert) => adminAlert.alert.condition == 'above')
          .toList();
      
      final List<AdminRateAlert> below = loadedAlerts
          .where((adminAlert) => adminAlert.alert.condition == 'below')
          .toList();

      setState(() {
        allAlerts = loadedAlerts;
        activeAlerts = active;
        inactiveAlerts = inactive;
        aboveAlerts = above;
        belowAlerts = below;
        isLoading = false;
      });

    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load rate alerts: ${e.toString()}';
      });
    }
  }

  List<AdminRateAlert> _getFilteredData(int tabIndex) {
    List<AdminRateAlert> data;
    
    switch (tabIndex) {
      case 0: data = allAlerts; break;
      case 1: data = activeAlerts; break;
      case 2: data = inactiveAlerts; break;
      case 3: data = aboveAlerts; break;
      case 4: data = belowAlerts; break;
      default: data = allAlerts;
    }

    if (searchQuery.isEmpty) return data;

    return data.where((adminAlert) {
      final userInfo = adminAlert.userInfo;
      final alert = adminAlert.alert;
      final userName = (userInfo['name'] ?? '').toString().toLowerCase();
      final userEmail = (userInfo['email'] ?? '').toString().toLowerCase();
      final fromCurrency = alert.fromCurrency.toLowerCase();
      final toCurrency = alert.toCurrency.toLowerCase();
      final condition = alert.condition.toLowerCase();
      final query = searchQuery.toLowerCase();
      
      return userName.contains(query) || 
             userEmail.contains(query) || 
             fromCurrency.contains(query) || 
             toCurrency.contains(query) ||
             condition.contains(query);
    }).toList();
  }

  void _showAlertDetails(AdminRateAlert adminAlert) {
    showDialog(
      context: context,
      builder: (context) => ShowAlertDetailsDialog(adminAlert: adminAlert),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    
    return Scaffold(
      backgroundColor: ModernConstants.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Padding(
                padding: ResponsiveHelper.getScreenPadding(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: isMobile ? 16 : 20),
                    _buildSearchBar(),
                    SizedBox(height: isMobile ? 16 : 20),
                    _buildTabBar(),
                    const SizedBox(height: 20),
                    Expanded(child: _buildTabContent()),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final isMobile = ResponsiveHelper.isMobile(context);
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: ModernConstants.primaryGradient,
        boxShadow: [
          BoxShadow(
            color: ModernConstants.primaryPurple.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Show Rate Alerts',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: ResponsiveHelper.getTitleFontSize(context),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (!isMobile) ...[
                        const SizedBox(height: 4),
                        Text(
                          'View all user-created rate alerts',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: ResponsiveHelper.getSubtitleFontSize(context),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    onPressed: _loadAllData,
                    icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                  ),
                ),
                if (!isMobile) ...[
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.visibility_rounded, color: Colors.white, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          'Total: ${allAlerts.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            if (isMobile) ...[
              const SizedBox(height: 12),
              Text(
                'View all user-created rate alerts',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        gradient: ModernConstants.cardGradient,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ModernConstants.primaryPurple.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: ModernConstants.primaryPurple.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        onChanged: (value) => setState(() => searchQuery = value),
        style: const TextStyle(color: ModernConstants.textPrimary),
        decoration: InputDecoration(
          hintText: 'Search alerts, users, currencies...',
          hintStyle: const TextStyle(color: ModernConstants.textTertiary),
          prefixIcon: const Icon(Icons.search_rounded, color: ModernConstants.primaryPurple),
          suffixIcon: searchQuery.isNotEmpty
              ? IconButton(
                  onPressed: () => setState(() => searchQuery = ''),
                  icon: const Icon(Icons.clear_rounded, color: ModernConstants.textSecondary),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    final isMobile = ResponsiveHelper.isMobile(context);
    
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          gradient: ModernConstants.cardGradient,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: ModernConstants.primaryPurple.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: ModernConstants.primaryPurple.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicator: BoxDecoration(
            gradient: ModernConstants.primaryGradient,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: ModernConstants.primaryPurple.withOpacity(0.3),
                blurRadius: 8,
                spreadRadius: 0,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          labelColor: Colors.white,
          unselectedLabelColor: ModernConstants.textSecondary,
          labelStyle: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: isMobile ? 12 : 14,
          ),
          tabs: _tabs.map((tab) {
            final index = _tabs.indexOf(tab);
            final count = _getFilteredData(index).length;
            
            return Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(tab['icon'], size: isMobile ? 16 : 18),
                  const SizedBox(width: 6),
                  Text(tab['title']),
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      count.toString(),
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    if (isLoading) {
      return const LoadingWidget(message: 'Loading rate alerts...');
    }

    if (errorMessage != null) {
      return Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: ModernConstants.cardGradient,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.red.withOpacity(0.2)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.error_outline, color: Colors.red, size: 48),
              ),
              const SizedBox(height: 16),
              const Text(
                'Error loading data',
                style: TextStyle(
                  color: ModernConstants.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                errorMessage!,
                style: const TextStyle(color: ModernConstants.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadAllData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ModernConstants.primaryPurple,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _buildAlertsList(0), // All
        _buildAlertsList(1), // Active
        _buildAlertsList(2), // Inactive
        _buildAlertsList(3), // Above
        _buildAlertsList(4), // Below
      ],
    );
  }

  Widget _buildAlertsList(int tabIndex) {
    final data = _getFilteredData(tabIndex);
    
    if (data.isEmpty) {
      return EmptyStateWidget(
        icon: _tabs[tabIndex]['icon'],
        title: 'No ${_tabs[tabIndex]['title'].toLowerCase()}',
        message: searchQuery.isNotEmpty
            ? 'Try adjusting your search criteria'
            : 'Rate alerts will appear here once created',
        actionText: searchQuery.isNotEmpty ? 'Clear Search' : null,
        onAction: searchQuery.isNotEmpty ? () => setState(() => searchQuery = '') : null,
      );
    }

    return ListView.builder(
      itemCount: data.length,
      itemBuilder: (context, index) {
        final adminAlert = data[index];
        return _buildAlertCard(adminAlert, tabIndex);
      },
    );
  }

  Widget _buildAlertCard(AdminRateAlert adminAlert, int tabIndex) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final tabColor = _tabs[tabIndex]['color'] as Color;
    final alert = adminAlert.alert;
    final userInfo = adminAlert.userInfo;
    final userName = userInfo['name']?.toString() ?? 'Unknown User';
    final userEmail = userInfo['email']?.toString() ?? 'No email';

    return InkWell(
      onTap: () => _showAlertDetails(adminAlert),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(isMobile ? 16 : 18),
        decoration: BoxDecoration(
          gradient: ModernConstants.cardGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: ModernConstants.primaryPurple.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: tabColor.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        tabColor.withOpacity(0.2),
                        tabColor.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getAlertIcon(alert.condition),
                    color: tabColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '${alert.fromCurrency}/${alert.toCurrency}',
                            style: const TextStyle(
                              color: ModernConstants.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: _getStatusColor(alert.isActive).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              alert.isActive ? 'ACTIVE' : 'INACTIVE',
                              style: TextStyle(
                                color: _getStatusColor(alert.isActive),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${alert.condition.toUpperCase()} ${alert.targetRate.toStringAsFixed(4)}',
                        style: const TextStyle(
                          color: ModernConstants.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Target: ${alert.targetRate.toStringAsFixed(4)}',
                      style: const TextStyle(
                        color: ModernConstants.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      DateFormat('MMM dd, yyyy').format(alert.createdAt),
                      style: const TextStyle(
                        color: ModernConstants.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.visibility_rounded,
                  color: ModernConstants.textSecondary,
                  size: 16,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: tabColor,
                  child: Text(
                    userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
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
                        userName,
                        style: const TextStyle(
                          color: ModernConstants.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        userEmail,
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
                    color: tabColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'ID: ${alert.id.length > 8 ? alert.id.substring(0, 8) : alert.id}',
                    style: TextStyle(
                      color: tabColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getAlertIcon(String condition) {
    switch (condition) {
      case 'above': return Icons.trending_up_rounded;
      case 'below': return Icons.trending_down_rounded;
      default: return Icons.notifications_active_rounded;
    }
  }

  Color _getStatusColor(bool isActive) {
    return isActive ? ModernConstants.accent : ModernConstants.textTertiary;
  }
}

// Show Alert Details Dialog - READ ONLY
class ShowAlertDetailsDialog extends StatelessWidget {
  final AdminRateAlert adminAlert;

  const ShowAlertDetailsDialog({
    super.key,
    required this.adminAlert,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          gradient: ModernConstants.cardGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Color(0x4D000000),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: _buildContent(),
              ),
            ),
            _buildActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: ModernConstants.primaryGradient,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.visibility_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Alert Details',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${adminAlert.alert.fromCurrency}/${adminAlert.alert.toCurrency} Alert',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final alert = adminAlert.alert;
    final userInfo = adminAlert.userInfo;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailSection(
          'Alert Information',
          Icons.notifications_active_rounded,
          [
            _buildDetailRow('Alert ID', alert.id),
            _buildDetailRow('From Currency', alert.fromCurrency),
            _buildDetailRow('To Currency', alert.toCurrency),
            _buildDetailRow('Condition', alert.condition.toUpperCase()),
            _buildDetailRow('Target Rate', alert.targetRate.toStringAsFixed(6)),
            _buildDetailRow('Status', alert.isActive ? 'ACTIVE' : 'INACTIVE'),
            _buildDetailRow('Created', DateFormat('MMM dd, yyyy • HH:mm:ss').format(alert.createdAt)),
          ],
        ),
        const SizedBox(height: 20),
        _buildDetailSection(
          'User Information',
          Icons.person_rounded,
          [
            _buildDetailRow('User Name', userInfo['name']?.toString() ?? 'Unknown User'),
            _buildDetailRow('User Email', userInfo['email']?.toString() ?? 'No email'),
            _buildDetailRow('User ID', adminAlert.userId),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailSection(String title, IconData icon, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ModernConstants.backgroundColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ModernConstants.textTertiary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: ModernConstants.primaryPurple, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: ModernConstants.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                color: ModernConstants.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: ModernConstants.textPrimary,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ModernConstants.backgroundColor.withOpacity(0.5),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close_rounded, size: 18),
              label: const Text('Close'),
              style: OutlinedButton.styleFrom(
                foregroundColor: ModernConstants.textSecondary,
                side: const BorderSide(color: ModernConstants.textSecondary),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
