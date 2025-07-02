import 'package:currency_converter/screen/admin/components/show_alerts_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

// Import the same models and constants from show_alerts_screen.dart
// (SimpleRateAlert, AdminRateAlert, ModernConstants, etc.)

// MANAGE ALERTS SCREEN - FULL CRUD OPERATIONS
class ManageAlertsScreen extends StatefulWidget {
  const ManageAlertsScreen({super.key});

  @override
  State<ManageAlertsScreen> createState() => _ManageAlertsScreenState();
}

class _ManageAlertsScreenState extends State<ManageAlertsScreen> with SingleTickerProviderStateMixin {
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
      'icon': Icons.settings_rounded,
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

  void _showManageAlertDialog(AdminRateAlert adminAlert) {
    showDialog(
      context: context,
      builder: (context) => ManageAlertDialog(
        adminAlert: adminAlert,
        onUpdate: () {
          _loadAllData(); // Refresh data after update
        },
        onDelete: () {
          _loadAllData(); // Refresh data after delete
        },
      ),
    );
  }

  Future<void> _bulkToggleActive(List<AdminRateAlert> alerts, bool isActive) async {
    try {
      final batch = FirebaseFirestore.instance.batch();
      
      for (var adminAlert in alerts) {
        final docRef = FirebaseFirestore.instance
            .collection('rate_alerts')
            .doc(adminAlert.alert.id);
        
        batch.update(docRef, {'isActive': isActive});
      }
      
      await batch.commit();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text('${alerts.length} alerts ${isActive ? 'activated' : 'deactivated'}!'),
              ],
            ),
            backgroundColor: ModernConstants.accent,
            behavior: SnackBarBehavior.floating,
          ),
        );
        
        _loadAllData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Text('Error: ${e.toString()}'),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
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
                    _buildBulkActions(),
                    const SizedBox(height: 16),
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
                        'Manage Rate Alerts',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: ResponsiveHelper.getTitleFontSize(context),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (!isMobile) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Edit and delete user rate alerts',
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
                        const Icon(Icons.settings_rounded, color: Colors.white, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          'Manage: ${allAlerts.length}',
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
                'Edit and delete user rate alerts',
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
          hintText: 'Search alerts to manage...',
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

  Widget _buildBulkActions() {
    final currentTabData = _getFilteredData(_tabController.index);
    
    if (currentTabData.isEmpty) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: ModernConstants.cardGradient,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ModernConstants.primaryPurple.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.admin_panel_settings_rounded, color: ModernConstants.primaryPurple, size: 20),
          const SizedBox(width: 8),
          const Text(
            'Bulk Actions:',
            style: TextStyle(
              color: ModernConstants.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _bulkToggleActive(currentTabData, true),
                    icon: const Icon(Icons.check_circle_rounded, size: 16),
                    label: const Text('Activate All'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: ModernConstants.accent,
                      side: const BorderSide(color: ModernConstants.accent),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _bulkToggleActive(currentTabData, false),
                    icon: const Icon(Icons.cancel_rounded, size: 16),
                    label: const Text('Deactivate All'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.orange,
                      side: const BorderSide(color: Colors.orange),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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
      return const LoadingWidget(message: 'Loading alerts to manage...');
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
        title: 'No ${_tabs[tabIndex]['title'].toLowerCase()} to manage',
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
        return _buildManageAlertCard(adminAlert, tabIndex);
      },
    );
  }

  Widget _buildManageAlertCard(AdminRateAlert adminAlert, int tabIndex) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final tabColor = _tabs[tabIndex]['color'] as Color;
    final alert = adminAlert.alert;
    final userInfo = adminAlert.userInfo;
    final userName = userInfo['name']?.toString() ?? 'Unknown User';
    final userEmail = userInfo['email']?.toString() ?? 'No email';

    return InkWell(
      onTap: () => _showManageAlertDialog(adminAlert),
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
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.edit_rounded,
                      color: Colors.blue,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.delete_rounded,
                      color: Colors.red,
                      size: 16,
                    ),
                  ],
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

// Manage Alert Dialog - FULL CRUD OPERATIONS
class ManageAlertDialog extends StatefulWidget {
  final AdminRateAlert adminAlert;
  final VoidCallback onUpdate;
  final VoidCallback onDelete;

  const ManageAlertDialog({
    super.key,
    required this.adminAlert,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  State<ManageAlertDialog> createState() => _ManageAlertDialogState();
}

class _ManageAlertDialogState extends State<ManageAlertDialog> {
  bool isEditing = false;
  bool isLoading = false;
  late SimpleRateAlert editableAlert;
  
  // Controllers for editing
  late TextEditingController targetRateController;
  late TextEditingController fromCurrencyController;
  late TextEditingController toCurrencyController;
  
  String selectedCondition = 'above';
  bool isActiveSwitch = true;

  @override
  void initState() {
    super.initState();
    editableAlert = widget.adminAlert.alert;
    _initializeControllers();
  }

  void _initializeControllers() {
    targetRateController = TextEditingController(
      text: editableAlert.targetRate.toString()
    );
    fromCurrencyController = TextEditingController(
      text: editableAlert.fromCurrency
    );
    toCurrencyController = TextEditingController(
      text: editableAlert.toCurrency
    );
    
    selectedCondition = editableAlert.condition;
    isActiveSwitch = editableAlert.isActive;
  }

  @override
  void dispose() {
    targetRateController.dispose();
    fromCurrencyController.dispose();
    toCurrencyController.dispose();
    super.dispose();
  }

  Future<void> _updateAlert() async {
    setState(() => isLoading = true);
    
    try {
      final updatedAlert = SimpleRateAlert(
        id: editableAlert.id,
        fromCurrency: fromCurrencyController.text.toUpperCase(),
        toCurrency: toCurrencyController.text.toUpperCase(),
        targetRate: double.tryParse(targetRateController.text) ?? editableAlert.targetRate,
        condition: selectedCondition,
        createdAt: editableAlert.createdAt,
        isActive: isActiveSwitch,
      );

      await FirebaseFirestore.instance
          .collection('rate_alerts')
          .doc(editableAlert.id)
          .update(updatedAlert.toMap());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Rate alert updated successfully!'),
              ],
            ),
            backgroundColor: ModernConstants.accent,
            behavior: SnackBarBehavior.floating,
          ),
        );
        
        setState(() => isEditing = false);
        widget.onUpdate();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Text('Error: ${e.toString()}'),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _deleteAlert() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ModernConstants.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.warning_rounded, color: Colors.red, size: 20),
            ),
            const SizedBox(width: 12),
            const Text(
              'Delete Rate Alert',
              style: TextStyle(color: ModernConstants.textPrimary, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to delete this user\'s rate alert? This action cannot be undone.',
          style: TextStyle(color: ModernConstants.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: ModernConstants.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => isLoading = true);
      
      try {
        await FirebaseFirestore.instance
            .collection('rate_alerts')
            .doc(editableAlert.id)
            .delete();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Rate alert deleted successfully!'),
                ],
              ),
              backgroundColor: ModernConstants.accent,
              behavior: SnackBarBehavior.floating,
            ),
          );
          
          Navigator.pop(context);
          widget.onDelete();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error, color: Colors.white),
                  const SizedBox(width: 8),
                  Text('Error: ${e.toString()}'),
                ],
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
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
            _buildActions(),
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
              Icons.settings_rounded,
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
                  'Manage Rate Alert',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${editableAlert.fromCurrency}/${editableAlert.toCurrency} Alert',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close_rounded, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final userInfo = widget.adminAlert.userInfo;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailSection(
          'Alert Information',
          Icons.notifications_active_rounded,
          [
            _buildDetailRow('Alert ID', editableAlert.id),
            isEditing
                ? _buildEditableRow('From Currency', fromCurrencyController, 'Enter from currency')
                : _buildDetailRow('From Currency', editableAlert.fromCurrency),
            isEditing
                ? _buildEditableRow('To Currency', toCurrencyController, 'Enter to currency')
                : _buildDetailRow('To Currency', editableAlert.toCurrency),
            isEditing
                ? _buildConditionDropdown()
                : _buildDetailRow('Condition', editableAlert.condition.toUpperCase()),
            isEditing
                ? _buildEditableRow('Target Rate', targetRateController, 'Enter target rate')
                : _buildDetailRow('Target Rate', editableAlert.targetRate.toStringAsFixed(6)),
            isEditing
                ? _buildActiveSwitch()
                : _buildDetailRow('Status', editableAlert.isActive ? 'ACTIVE' : 'INACTIVE'),
            _buildDetailRow('Created', DateFormat('MMM dd, yyyy • HH:mm:ss').format(editableAlert.createdAt)),
          ],
        ),
        const SizedBox(height: 20),
        _buildDetailSection(
          'User Information',
          Icons.person_rounded,
          [
            _buildDetailRow('User Name', userInfo['name']?.toString() ?? 'Unknown User'),
            _buildDetailRow('User Email', userInfo['email']?.toString() ?? 'No email'),
            _buildDetailRow('User ID', widget.adminAlert.userId),
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

  Widget _buildEditableRow(String label, TextEditingController controller, String hint) {
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
            child: TextField(
              controller: controller,
              style: const TextStyle(color: ModernConstants.textPrimary, fontSize: 14),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(color: ModernConstants.textTertiary, fontSize: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: ModernConstants.textTertiary.withOpacity(0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: ModernConstants.primaryPurple),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                filled: true,
                fillColor: ModernConstants.backgroundColor.withOpacity(0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConditionDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            width: 120,
            child: Text(
              'Condition',
              style: TextStyle(
                color: ModernConstants.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: selectedCondition,
              onChanged: (value) => setState(() => selectedCondition = value ?? 'above'),
              style: const TextStyle(color: ModernConstants.textPrimary, fontSize: 14),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: ModernConstants.textTertiary.withOpacity(0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: ModernConstants.primaryPurple),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                filled: true,
                fillColor: ModernConstants.backgroundColor.withOpacity(0.5),
              ),
              dropdownColor: ModernConstants.cardBackground,
              items: const [
                DropdownMenuItem(value: 'above', child: Text('ABOVE')),
                DropdownMenuItem(value: 'below', child: Text('BELOW')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveSwitch() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(
            width: 120,
            child: Text(
              'Active',
              style: TextStyle(
                color: ModernConstants.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Switch(
            value: isActiveSwitch,
            onChanged: (value) => setState(() => isActiveSwitch = value),
            activeColor: ModernConstants.accent,
          ),
          const SizedBox(width: 8),
          Text(
            isActiveSwitch ? 'Active' : 'Inactive',
            style: TextStyle(
              color: isActiveSwitch ? ModernConstants.accent : ModernConstants.textTertiary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
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
          if (isEditing) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: isLoading ? null : () {
                  setState(() => isEditing = false);
                  _initializeControllers(); // Reset controllers
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: ModernConstants.textSecondary,
                  side: const BorderSide(color: ModernConstants.textSecondary),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: isLoading ? null : _updateAlert,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ModernConstants.primaryPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('Save Changes'),
              ),
            ),
          ] else ...[
            Expanded(
              child: OutlinedButton.icon(
                onPressed: isLoading ? null : () => setState(() => isEditing = true),
                icon: const Icon(Icons.edit_rounded, size: 18),
                label: const Text('Edit Alert'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.blue,
                  side: const BorderSide(color: Colors.blue),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: isLoading ? null : _deleteAlert,
                icon: const Icon(Icons.delete_rounded, size: 18),
                label: const Text('Delete Alert'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
