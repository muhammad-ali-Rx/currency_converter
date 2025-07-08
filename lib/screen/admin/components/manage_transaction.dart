import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

// Fixed ModernConstants with proper color definitions
class ModernConstants {
  static const Color backgroundColor = Color(0xFF0F0F23);
  static const Color cardBackground = Color(0xFF1A1A2E);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color textTertiary = Color(0xFF6B7280);
  static const Color accent = Color(0xFF10B981);
  static const Color accentSecondary = Color(0xFF059669);
  
  // Card gradient
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1A1A2E),
      Color(0xFF16213E),
    ],
  );
  
  // Card shadow
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 20,
      spreadRadius: 0,
      offset: Offset(0, 4),
    ),
  ];
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

class ManageTransactionsScreen extends StatefulWidget {
  const ManageTransactionsScreen({super.key});

  @override
  State<ManageTransactionsScreen> createState() => _ManageTransactionsScreenState();
}

class _ManageTransactionsScreenState extends State<ManageTransactionsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Data lists for different tabs
  List<Map<String, dynamic>> allTransactions = [];
  List<Map<String, dynamic>> currencyConversions = [];
  List<Map<String, dynamic>> transactionHistory = [];
  List<Map<String, dynamic>> userActivity = [];
  
  bool isLoading = true;
  String searchQuery = '';
  String? errorMessage;
  
  // Tab data
  final List<Map<String, dynamic>> _tabs = [
    {
      'title': 'All Conversions',
      'icon': Icons.list_alt_rounded,
      'color': ModernConstants.accent,
    },
    {
      'title': 'Currency Conversions',
      'icon': Icons.currency_exchange_rounded,
      'color': const Color(0xFF3B82F6),
    },
    {
      'title': 'Conversions History',
      'icon': Icons.history_rounded,
      'color': const Color(0xFF8B5CF6),
    },
    {
      'title': 'User Activity',
      'icon': Icons.person_search_rounded,
      'color': const Color(0xFFF59E0B),
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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

      // Load All Transactions (Conversion Transactions)
      final conversionsQuery = await FirebaseFirestore.instance
          .collection('conversion_transactions')
          .orderBy('timestamp', descending: true)
          .limit(500)
          .get();

      // Load Currency Conversion History
      final historyQuery = await FirebaseFirestore.instance
          .collection('currency_conversion_history')
          .orderBy('timestamp', descending: true)
          .limit(300)
          .get();

      // Load User Activity (App Data)
      final activityQuery = await FirebaseFirestore.instance
          .collection('app_data')
          .orderBy('timestamp', descending: true)
          .limit(200)
          .get();

      // Process All Transactions
      final List<Map<String, dynamic>> loadedTransactions = [];
      for (var doc in conversionsQuery.docs) {
        final data = doc.data();
        loadedTransactions.add({
          'id': doc.id,
          'type': 'conversion',
          'base_currency': data['base_currency'] ?? 'USD',
          'target_currency': data['target_currency'] ?? 'PKR',
          'base_amount': data['base_amount']?.toDouble() ?? 0.0,
          'target_amount': data['target_amount']?.toDouble() ?? 0.0,
          'conversion_rate': data['conversion_rate']?.toDouble() ?? 0.0,
          'user_info': data['user_info'] ?? {},
          'timestamp': data['timestamp']?.toDate() ?? DateTime.now(),
          'transaction_id': data['transaction_id'] ?? doc.id,
          'status': 'completed',
        });
      }

      // Process Currency Conversions
      final List<Map<String, dynamic>> loadedConversions = loadedTransactions
          .where((t) => t['type'] == 'conversion')
          .toList();

      // Process Transaction History
      final List<Map<String, dynamic>> loadedHistory = [];
      for (var doc in historyQuery.docs) {
        final data = doc.data();
        loadedHistory.add({
          'id': doc.id,
          'type': 'rate_history',
          'base_currency': data['base_currency'] ?? 'USD',
          'target_currency': data['target_currency'] ?? 'PKR',
          'conversion_rate': data['conversion_rate']?.toDouble() ?? 0.0,
          'user_info': data['user_info'] ?? {},
          'timestamp': data['timestamp']?.toDate() ?? DateTime.now(),
          'period': data['period'] ?? '1Y',
          'session_info': data['session_info'] ?? {},
        });
      }

      // Process User Activity
      final List<Map<String, dynamic>> loadedActivity = [];
      for (var doc in activityQuery.docs) {
        final data = doc.data();
        loadedActivity.add({
          'id': doc.id,
          'type': 'user_activity',
          'action': data['action'] ?? 'app_usage',
          'user_info': data['user_info'] ?? {},
          'timestamp': data['timestamp']?.toDate() ?? DateTime.now(),
          'details': data['details'] ?? {},
          'platform': data['platform'] ?? 'mobile',
        });
      }

      setState(() {
        allTransactions = loadedTransactions;
        currencyConversions = loadedConversions;
        transactionHistory = loadedHistory;
        userActivity = loadedActivity;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load data: ${e.toString()}';
      });
    }
  }

  List<Map<String, dynamic>> _getFilteredData(int tabIndex) {
    List<Map<String, dynamic>> data;
    
    switch (tabIndex) {
      case 0:
        data = allTransactions;
        break;
      case 1:
        data = currencyConversions;
        break;
      case 2:
        data = transactionHistory;
        break;
      case 3:
        data = userActivity;
        break;
      default:
        data = allTransactions;
    }

    if (searchQuery.isEmpty) return data;

    return data.where((item) {
      final userInfo = item['user_info'] as Map<String, dynamic>? ?? {};
      final userName = (userInfo['name'] ?? '').toString().toLowerCase();
      final userEmail = (userInfo['email'] ?? '').toString().toLowerCase();
      final baseCurrency = (item['base_currency'] ?? '').toString().toLowerCase();
      final targetCurrency = (item['target_currency'] ?? '').toString().toLowerCase();
      final action = (item['action'] ?? '').toString().toLowerCase();
      final query = searchQuery.toLowerCase();
      
      return userName.contains(query) || 
             userEmail.contains(query) || 
             baseCurrency.contains(query) || 
             targetCurrency.contains(query) ||
             action.contains(query);
    }).toList();
  }

  void _showTransactionDetails(Map<String, dynamic> transaction, int tabIndex) {
    showDialog(
      context: context,
      builder: (context) => TransactionDetailsDialog(
        transaction: transaction,
        tabIndex: tabIndex,
        onUpdate: () {
          _loadAllData(); // Refresh data after update
        },
        onDelete: () {
          _loadAllData(); // Refresh data after delete
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    
    return Scaffold(
      backgroundColor: ModernConstants.backgroundColor,
      appBar: AppBar(
        backgroundColor: ModernConstants.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: ModernConstants.textPrimary,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Manage Conversions',
          style: TextStyle(
            color: ModernConstants.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _loadAllData,
            icon: const Icon(
              Icons.refresh_rounded,
              color: ModernConstants.textSecondary,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: ResponsiveHelper.getScreenPadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            SizedBox(height: isMobile ? 16 : 20),
            _buildSearchBar(),
            SizedBox(height: isMobile ? 16 : 20),
            _buildTabBar(),
            const SizedBox(height: 20),
            Expanded(child: _buildTabContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Conversions Management',
                style: TextStyle(
                  color: ModernConstants.textPrimary,
                  fontSize: ResponsiveHelper.getTitleFontSize(context),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Manage and edit all user Conversions',
                style: TextStyle(
                  color: ModernConstants.textSecondary,
                  fontSize: ResponsiveHelper.getSubtitleFontSize(context),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        gradient: ModernConstants.cardGradient,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ModernConstants.textTertiary.withOpacity(0.2),
        ),
      ),
      child: TextField(
        onChanged: (value) => setState(() => searchQuery = value),
        style: const TextStyle(color: ModernConstants.textPrimary),
        decoration: InputDecoration(
          hintText: 'Search Conversions, users, currencies...',
          hintStyle: const TextStyle(color: ModernConstants.textTertiary),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: ModernConstants.textSecondary,
          ),
          suffixIcon: searchQuery.isNotEmpty
              ? IconButton(
                  onPressed: () => setState(() => searchQuery = ''),
                  icon: const Icon(
                    Icons.clear_rounded,
                    color: ModernConstants.textSecondary,
                  ),
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
          border: Border.all(
            color: ModernConstants.textTertiary.withOpacity(0.2),
          ),
        ),
        child: TabBar(
          controller: _tabController,
          isScrollable: isMobile,
          indicator: BoxDecoration(
            gradient: const LinearGradient(
              colors: [ModernConstants.accent, ModernConstants.accentSecondary],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          labelColor: Colors.white,
          unselectedLabelColor: ModernConstants.textSecondary,
          labelStyle: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: isMobile ? 12 : 14,
          ),
          unselectedLabelStyle: TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: isMobile ? 12 : 14,
          ),
          tabs: _tabs.map((tab) {
            final index = _tabs.indexOf(tab);
            final count = _getFilteredData(index).length;
            
            return Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    tab['icon'],
                    size: isMobile ? 16 : 18,
                  ),
                  const SizedBox(width: 6),
                  if (!isMobile || _tabs.length <= 2) ...[
                    Text(tab['title']),
                    const SizedBox(width: 4),
                  ],
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      count.toString(),
                      style: const TextStyle(
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
      ),
    );
  }

  Widget _buildTabContent() {
    if (isLoading) {
      return const LoadingWidget(message: 'Loading Conversions...');
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
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
                backgroundColor: ModernConstants.accent,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _buildTransactionsList(0), // All Transactions
        _buildTransactionsList(1), // Currency Conversions
        _buildTransactionsList(2), // Transaction History
        _buildTransactionsList(3), // User Activity
      ],
    );
  }

  Widget _buildTransactionsList(int tabIndex) {
    final data = _getFilteredData(tabIndex);
    
    if (data.isEmpty) {
      return EmptyStateWidget(
        icon: _tabs[tabIndex]['icon'],
        title: 'No ${_tabs[tabIndex]['title'].toLowerCase()}',
        message: searchQuery.isNotEmpty
            ? 'Try adjusting your search criteria'
            : 'Data will appear here once available',
        actionText: searchQuery.isNotEmpty ? 'Clear Search' : null,
        onAction: searchQuery.isNotEmpty ? () => setState(() => searchQuery = '') : null,
      );
    }

    return ListView.builder(
      itemCount: data.length,
      itemBuilder: (context, index) {
        final item = data[index];
        return _buildTransactionCard(item, tabIndex);
      },
    );
  }

  Widget _buildTransactionCard(Map<String, dynamic> item, int tabIndex) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final tabColor = _tabs[tabIndex]['color'] as Color;
    
    return InkWell(
      onTap: () => _showTransactionDetails(item, tabIndex),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(isMobile ? 16 : 18),
        decoration: BoxDecoration(
          gradient: ModernConstants.cardGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: ModernConstants.cardShadow,
          border: Border.all(color: tabColor.withOpacity(0.2)),
        ),
        child: _buildCardContent(item, tabColor, tabIndex),
      ),
    );
  }

  Widget _buildCardContent(Map<String, dynamic> item, Color color, int tabIndex) {
    switch (tabIndex) {
      case 0:
      case 1:
        return _buildConversionCardContent(item, color);
      case 2:
        return _buildHistoryCardContent(item, color);
      case 3:
        return _buildActivityCardContent(item, color);
      default:
        return _buildConversionCardContent(item, color);
    }
  }

  Widget _buildConversionCardContent(Map<String, dynamic> transaction, Color color) {
    final userInfo = transaction['user_info'] as Map<String, dynamic>? ?? {};
    final userName = userInfo['name']?.toString() ?? 'Unknown User';
    final userEmail = userInfo['email']?.toString() ?? 'No email';
    final timestamp = transaction['timestamp'] as DateTime;
    final baseCurrency = transaction['base_currency']?.toString() ?? 'USD';
    final targetCurrency = transaction['target_currency']?.toString() ?? 'PKR';
    final baseAmount = transaction['base_amount']?.toDouble() ?? 0.0;
    final targetAmount = transaction['target_amount']?.toDouble() ?? 0.0;
    final conversionRate = transaction['conversion_rate']?.toDouble() ?? 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.currency_exchange_rounded,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$baseCurrency → $targetCurrency',
                    style: const TextStyle(
                      color: ModernConstants.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    DateFormat('MMM dd, yyyy • HH:mm').format(timestamp),
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
                  '${baseAmount.toStringAsFixed(2)} $baseCurrency',
                  style: const TextStyle(
                    color: ModernConstants.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${targetAmount.toStringAsFixed(2)} $targetCurrency',
                  style: const TextStyle(
                    color: ModernConstants.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_forward_ios_rounded,
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
              backgroundColor: color,
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
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Rate: ${conversionRate.toStringAsFixed(4)}',
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHistoryCardContent(Map<String, dynamic> history, Color color) {
    final userInfo = history['user_info'] as Map<String, dynamic>? ?? {};
    final userName = userInfo['name']?.toString() ?? 'Unknown User';
    final timestamp = history['timestamp'] as DateTime;
    final baseCurrency = history['base_currency']?.toString() ?? 'USD';
    final targetCurrency = history['target_currency']?.toString() ?? 'PKR';
    final conversionRate = history['conversion_rate']?.toDouble() ?? 0.0;
    final period = history['period']?.toString() ?? '1Y';

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.history_rounded,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$baseCurrency/$targetCurrency Rate History',
                style: const TextStyle(
                  color: ModernConstants.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'User: $userName • Period: $period',
                style: const TextStyle(
                  color: ModernConstants.textSecondary,
                  fontSize: 12,
                ),
              ),
              Text(
                DateFormat('MMM dd, yyyy • HH:mm').format(timestamp),
                style: const TextStyle(
                  color: ModernConstants.textTertiary,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            conversionRate.toStringAsFixed(4),
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 8),
        const Icon(
          Icons.arrow_forward_ios_rounded,
          color: ModernConstants.textSecondary,
          size: 16,
        ),
      ],
    );
  }

  Widget _buildActivityCardContent(Map<String, dynamic> activity, Color color) {
    final userInfo = activity['user_info'] as Map<String, dynamic>? ?? {};
    final userName = userInfo['name']?.toString() ?? 'Unknown User';
    final userEmail = userInfo['email']?.toString() ?? 'No email';
    final timestamp = activity['timestamp'] as DateTime;
    final action = activity['action']?.toString() ?? 'app_usage';
    final platform = activity['platform']?.toString() ?? 'mobile';

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.person_search_rounded,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                action.replaceAll('_', ' ').toUpperCase(),
                style: const TextStyle(
                  color: ModernConstants.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '$userName • $userEmail',
                style: const TextStyle(
                  color: ModernConstants.textSecondary,
                  fontSize: 12,
                ),
              ),
              Text(
                '${DateFormat('MMM dd, yyyy • HH:mm').format(timestamp)} • $platform',
                style: const TextStyle(
                  color: ModernConstants.textTertiary,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            platform.toUpperCase(),
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 8),
        const Icon(
          Icons.arrow_forward_ios_rounded,
          color: ModernConstants.textSecondary,
          size: 16,
        ),
      ],
    );
  }
}

// Transaction Details Dialog
class TransactionDetailsDialog extends StatefulWidget {
  final Map<String, dynamic> transaction;
  final int tabIndex;
  final VoidCallback onUpdate;
  final VoidCallback onDelete;

  const TransactionDetailsDialog({
    super.key,
    required this.transaction,
    required this.tabIndex,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  State<TransactionDetailsDialog> createState() => _TransactionDetailsDialogState();
}

class _TransactionDetailsDialogState extends State<TransactionDetailsDialog> {
  bool isEditing = false;
  bool isLoading = false;
  late Map<String, dynamic> editableTransaction;
  
  // Controllers for editing
  late TextEditingController baseAmountController;
  late TextEditingController targetAmountController;
  late TextEditingController conversionRateController;
  late TextEditingController userNameController;
  late TextEditingController userEmailController;

  @override
  void initState() {
    super.initState();
    editableTransaction = Map<String, dynamic>.from(widget.transaction);
    _initializeControllers();
  }

  void _initializeControllers() {
    final userInfo = editableTransaction['user_info'] as Map<String, dynamic>? ?? {};
    
    baseAmountController = TextEditingController(
      text: (editableTransaction['base_amount']?.toDouble() ?? 0.0).toString()
    );
    targetAmountController = TextEditingController(
      text: (editableTransaction['target_amount']?.toDouble() ?? 0.0).toString()
    );
    conversionRateController = TextEditingController(
      text: (editableTransaction['conversion_rate']?.toDouble() ?? 0.0).toString()
    );
    userNameController = TextEditingController(
      text: userInfo['name']?.toString() ?? ''
    );
    userEmailController = TextEditingController(
      text: userInfo['email']?.toString() ?? ''
    );
  }

  @override
  void dispose() {
    baseAmountController.dispose();
    targetAmountController.dispose();
    conversionRateController.dispose();
    userNameController.dispose();
    userEmailController.dispose();
    super.dispose();
  }

  Future<void> _updateTransaction() async {
    setState(() => isLoading = true);
    
    try {
      final updatedData = {
        'base_amount': double.tryParse(baseAmountController.text) ?? 0.0,
        'target_amount': double.tryParse(targetAmountController.text) ?? 0.0,
        'conversion_rate': double.tryParse(conversionRateController.text) ?? 0.0,
        'user_info': {
          'name': userNameController.text,
          'email': userEmailController.text,
        },
        'updated_at': FieldValue.serverTimestamp(),
      };

      String collection = _getCollectionName();
      
      await FirebaseFirestore.instance
          .collection(collection)
          .doc(widget.transaction['id'])
          .update(updatedData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Transaction updated successfully!'),
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

  Future<void> _deleteTransaction() async {
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
              'Delete Transaction',
              style: TextStyle(color: ModernConstants.textPrimary, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to delete this transaction? This action cannot be undone.',
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
        String collection = _getCollectionName();
        
        await FirebaseFirestore.instance
            .collection(collection)
            .doc(widget.transaction['id'])
            .delete();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Conversions deleted successfully!'),
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

  String _getCollectionName() {
    switch (widget.tabIndex) {
      case 0:
      case 1:
        return 'conversion_transactions';
      case 2:
        return 'currency_conversion_history';
      case 3:
        return 'app_data';
      default:
        return 'conversion_transactions';
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
        gradient: LinearGradient(
          colors: [ModernConstants.accent, ModernConstants.accentSecondary],
        ),
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
            child: Icon(
              _getHeaderIcon(),
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
                  'Conversions Details',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _getSubtitle(),
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
    switch (widget.tabIndex) {
      case 0:
      case 1:
        return _buildConversionDetails();
      case 2:
        return _buildHistoryDetails();
      case 3:
        return _buildActivityDetails();
      default:
        return _buildConversionDetails();
    }
  }

  Widget _buildConversionDetails() {
    final userInfo = editableTransaction['user_info'] as Map<String, dynamic>? ?? {};
    final timestamp = editableTransaction['timestamp'] as DateTime;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailSection(
          'Conversions Information',
          Icons.currency_exchange_rounded,
          [
            _buildDetailRow('Transaction ID', editableTransaction['id'] ?? 'N/A'),
            _buildDetailRow('Type', editableTransaction['type']?.toString().toUpperCase() ?? 'CONVERSION'),
            _buildDetailRow('Status', editableTransaction['status']?.toString().toUpperCase() ?? 'COMPLETED'),
            _buildDetailRow('Date', DateFormat('MMM dd, yyyy • HH:mm:ss').format(timestamp)),
          ],
        ),
        const SizedBox(height: 20),
        _buildDetailSection(
          'Currency Details',
          Icons.monetization_on_rounded,
          [
            _buildDetailRow('From Currency', editableTransaction['base_currency'] ?? 'USD'),
            _buildDetailRow('To Currency', editableTransaction['target_currency'] ?? 'PKR'),
            isEditing
                ? _buildEditableRow('Base Amount', baseAmountController, 'Enter base amount')
                : _buildDetailRow('Base Amount', '${(editableTransaction['base_amount']?.toDouble() ?? 0.0).toStringAsFixed(2)} ${editableTransaction['base_currency']}'),
            isEditing
                ? _buildEditableRow('Target Amount', targetAmountController, 'Enter target amount')
                : _buildDetailRow('Target Amount', '${(editableTransaction['target_amount']?.toDouble() ?? 0.0).toStringAsFixed(2)} ${editableTransaction['target_currency']}'),
            isEditing
                ? _buildEditableRow('Conversion Rate', conversionRateController, 'Enter conversion rate')
                : _buildDetailRow('Conversion Rate', (editableTransaction['conversion_rate']?.toDouble() ?? 0.0).toStringAsFixed(6)),
          ],
        ),
        const SizedBox(height: 20),
        _buildDetailSection(
          'User Information',
          Icons.person_rounded,
          [
            isEditing
                ? _buildEditableRow('User Name', userNameController, 'Enter user name')
                : _buildDetailRow('User Name', userInfo['name']?.toString() ?? 'Unknown User'),
            isEditing
                ? _buildEditableRow('User Email', userEmailController, 'Enter user email')
                : _buildDetailRow('User Email', userInfo['email']?.toString() ?? 'No email'),
            _buildDetailRow('User ID', userInfo['uid']?.toString() ?? 'N/A'),
          ],
        ),
      ],
    );
  }

  Widget _buildHistoryDetails() {
    final userInfo = editableTransaction['user_info'] as Map<String, dynamic>? ?? {};
    final sessionInfo = editableTransaction['session_info'] as Map<String, dynamic>? ?? {};
    final timestamp = editableTransaction['timestamp'] as DateTime;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailSection(
          'History Information',
          Icons.history_rounded,
          [
            _buildDetailRow('Record ID', editableTransaction['id'] ?? 'N/A'),
            _buildDetailRow('Type', 'RATE HISTORY'),
            _buildDetailRow('Date', DateFormat('MMM dd, yyyy • HH:mm:ss').format(timestamp)),
            _buildDetailRow('Period', editableTransaction['period']?.toString() ?? '1Y'),
          ],
        ),
        const SizedBox(height: 20),
        _buildDetailSection(
          'Rate Information',
          Icons.trending_up_rounded,
          [
            _buildDetailRow('Currency Pair', '${editableTransaction['base_currency']}/${editableTransaction['target_currency']}'),
            _buildDetailRow('Conversion Rate', (editableTransaction['conversion_rate']?.toDouble() ?? 0.0).toStringAsFixed(6)),
          ],
        ),
        const SizedBox(height: 20),
        _buildDetailSection(
          'User Information',
          Icons.person_rounded,
          [
            _buildDetailRow('User Name', userInfo['name']?.toString() ?? 'Unknown User'),
            _buildDetailRow('User Email', userInfo['email']?.toString() ?? 'No email'),
            _buildDetailRow('User ID', userInfo['uid']?.toString() ?? 'N/A'),
          ],
        ),
        if (sessionInfo.isNotEmpty) ...[
          const SizedBox(height: 20),
          _buildDetailSection(
            'Session Information',
            Icons.info_rounded,
            sessionInfo.entries.map((entry) => 
              _buildDetailRow(entry.key.toString(), entry.value.toString())
            ).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildActivityDetails() {
    final userInfo = editableTransaction['user_info'] as Map<String, dynamic>? ?? {};
    final details = editableTransaction['details'] as Map<String, dynamic>? ?? {};
    final timestamp = editableTransaction['timestamp'] as DateTime;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailSection(
          'Activity Information',
          Icons.person_search_rounded,
          [
            _buildDetailRow('Activity ID', editableTransaction['id'] ?? 'N/A'),
            _buildDetailRow('Action', editableTransaction['action']?.toString().replaceAll('_', ' ').toUpperCase() ?? 'APP USAGE'),
            _buildDetailRow('Platform', editableTransaction['platform']?.toString().toUpperCase() ?? 'MOBILE'),
            _buildDetailRow('Date', DateFormat('MMM dd, yyyy • HH:mm:ss').format(timestamp)),
          ],
        ),
        const SizedBox(height: 20),
        _buildDetailSection(
          'User Information',
          Icons.person_rounded,
          [
            _buildDetailRow('User Name', userInfo['name']?.toString() ?? 'Unknown User'),
            _buildDetailRow('User Email', userInfo['email']?.toString() ?? 'No email'),
            _buildDetailRow('User ID', userInfo['uid']?.toString() ?? 'N/A'),
          ],
        ),
        if (details.isNotEmpty) ...[
          const SizedBox(height: 20),
          _buildDetailSection(
            'Activity Details',
            Icons.info_rounded,
            details.entries.map((entry) => 
              _buildDetailRow(entry.key.toString(), entry.value.toString())
            ).toList(),
          ),
        ],
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
              Icon(icon, color: ModernConstants.accent, size: 20),
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
                  borderSide: const BorderSide(color: ModernConstants.accent),
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
                onPressed: isLoading ? null : _updateTransaction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ModernConstants.accent,
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
                label: const Text('Edit'),
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
                onPressed: isLoading ? null : _deleteTransaction,
                icon: const Icon(Icons.delete_rounded, size: 18),
                label: const Text('Delete'),
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

  IconData _getHeaderIcon() {
    switch (widget.tabIndex) {
      case 0:
      case 1:
        return Icons.currency_exchange_rounded;
      case 2:
        return Icons.history_rounded;
      case 3:
        return Icons.person_search_rounded;
      default:
        return Icons.currency_exchange_rounded;
    }
  }

  String _getSubtitle() {
    switch (widget.tabIndex) {
      case 0:
      case 1:
        return 'Currency Conversion Details';
      case 2:
        return 'Rate History Record';
      case 3:
        return 'User Activity Record';
      default:
        return 'Conversions Record';
    }
  }
}