import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../../utils/modern_constants.dart';
import '../../../utils/responsive_helper.dart';
import '../../../widgets/common/loading_widget.dart';
import '../../../widgets/common/empty_state_widget.dart';

class AllTransactionsPage extends StatefulWidget {
  const AllTransactionsPage({super.key});

  @override
  State<AllTransactionsPage> createState() => _AllTransactionsPageState();
}

class _AllTransactionsPageState extends State<AllTransactionsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Data lists for different tabs
  List<Map<String, dynamic>> allTransactions = [];
  List<Map<String, dynamic>> currencyConversions = [];
  List<Map<String, dynamic>> transactionHistory = [];
  List<Map<String, dynamic>> userActivity = [];

  bool isLoading = true;
  String searchQuery = '';
  String? errorMessage;

  // Tab data with modern colors
  final List<Map<String, dynamic>> _tabs = [
    {
      'title': 'All Transactions',
      'icon': Icons.list_alt_rounded,
      'color': ModernConstants.primaryPurple,
    },
    {
      'title': 'Currency Conversions',
      'icon': Icons.currency_exchange_rounded,
      'color': ModernConstants.textPrimary,
    },
    {
      'title': 'Transaction History',
      'icon': Icons.history_rounded,
      'color': ModernConstants.primaryPurple,
    },
    {
      'title': 'User Activity',
      'icon': Icons.person_search_rounded,
      'color': ModernConstants.textPrimary,
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

      // Process Currency Conversions (Same as all transactions but filtered)
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

      print('✅ Loaded data successfully:');
      print('- All Transactions: ${allTransactions.length}');
      print('- Currency Conversions: ${currencyConversions.length}');
      print('- Transaction History: ${transactionHistory.length}');
      print('- User Activity: ${userActivity.length}');
    } catch (e) {
      print('❌ Error loading data: $e');
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

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    
    return Scaffold(
      backgroundColor: ModernConstants.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildModernHeader(),
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

  Widget _buildModernHeader() {
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
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      color: Colors.white,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'All Transactions',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: ResponsiveHelper.getTitleFontSize(context),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (!isMobile) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Complete overview of all user transactions and activities',
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
                    icon: const Icon(
                      Icons.refresh_rounded,
                      color: Colors.white,
                    ),
                  ),
                ),
                if (!isMobile) ...[
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.file_download_rounded, color: Colors.white, size: 18),
                        SizedBox(width: 6),
                        Text(
                          'Export',
                          style: TextStyle(
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
                'Complete overview of all user transactions and activities',
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
        border: Border.all(
          color: ModernConstants.primaryPurple.withOpacity(0.2),
        ),
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
          hintText: 'Search transactions, users, currencies...',
          hintStyle: TextStyle(color: ModernConstants.textTertiary),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: ModernConstants.primaryPurple,
          ),
          suffixIcon: searchQuery.isNotEmpty
              ? IconButton(
                  onPressed: () => setState(() => searchQuery = ''),
                  icon: Icon(
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
            color: ModernConstants.primaryPurple.withOpacity(0.2),
          ),
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
          isScrollable: isMobile,
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
      return const LoadingWidget(message: 'Loading transactions...');
    }

    if (errorMessage != null) {
      return Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: ModernConstants.cardGradient,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.red.withOpacity(0.2),
            ),
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
              Text(
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
                style: TextStyle(color: ModernConstants.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  gradient: ModernConstants.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ElevatedButton(
                  onPressed: _loadAllData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Retry',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
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
    
    switch (tabIndex) {
      case 0:
      case 1:
        return _buildConversionCard(item, tabColor, isMobile);
      case 2:
        return _buildHistoryCard(item, tabColor, isMobile);
      case 3:
        return _buildActivityCard(item, tabColor, isMobile);
      default:
        return _buildConversionCard(item, tabColor, isMobile);
    }
  }

  Widget _buildConversionCard(Map<String, dynamic> transaction, Color color, bool isMobile) {
    final userInfo = transaction['user_info'] as Map<String, dynamic>? ?? {};
    final userName = userInfo['name']?.toString() ?? 'Unknown User';
    final userEmail = userInfo['email']?.toString() ?? 'No email';
    final timestamp = transaction['timestamp'] as DateTime;
    final baseCurrency = transaction['base_currency']?.toString() ?? 'USD';
    final targetCurrency = transaction['target_currency']?.toString() ?? 'PKR';
    final baseAmount = transaction['base_amount']?.toDouble() ?? 0.0;
    final targetAmount = transaction['target_amount']?.toDouble() ?? 0.0;
    final conversionRate = transaction['conversion_rate']?.toDouble() ?? 0.0;

    return Container(
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
        border: Border.all(color: color.withOpacity(0.2)),
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
                      color.withOpacity(0.2),
                      color.withOpacity(0.1),
                    ],
                  ),
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
                      style: TextStyle(
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
                    style: TextStyle(
                      color: ModernConstants.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withOpacity(0.7)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
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
                      style: TextStyle(
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
                  gradient: LinearGradient(
                    colors: [
                      color.withOpacity(0.2),
                      color.withOpacity(0.1),
                    ],
                  ),
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
      ),
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> history, Color color, bool isMobile) {
    final userInfo = history['user_info'] as Map<String, dynamic>? ?? {};
    final userName = userInfo['name']?.toString() ?? 'Unknown User';
    final timestamp = history['timestamp'] as DateTime;
    final baseCurrency = history['base_currency']?.toString() ?? 'USD';
    final targetCurrency = history['target_currency']?.toString() ?? 'PKR';
    final conversionRate = history['conversion_rate']?.toDouble() ?? 0.0;
    final period = history['period']?.toString() ?? '1Y';

    return Container(
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
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withOpacity(0.2),
                  color.withOpacity(0.1),
                ],
              ),
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
                  style: TextStyle(
                    color: ModernConstants.textSecondary,
                    fontSize: 12,
                  ),
                ),
                Text(
                  DateFormat('MMM dd, yyyy • HH:mm').format(timestamp),
                  style: TextStyle(
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
              gradient: LinearGradient(
                colors: [
                  color.withOpacity(0.2),
                  color.withOpacity(0.1),
                ],
              ),
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
        ],
      ),
    );
  }

  Widget _buildActivityCard(Map<String, dynamic> activity, Color color, bool isMobile) {
    final userInfo = activity['user_info'] as Map<String, dynamic>? ?? {};
    final userName = userInfo['name']?.toString() ?? 'Unknown User';
    final userEmail = userInfo['email']?.toString() ?? 'No email';
    final timestamp = activity['timestamp'] as DateTime;
    final action = activity['action']?.toString() ?? 'app_usage';
    final platform = activity['platform']?.toString() ?? 'mobile';

    return Container(
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
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withOpacity(0.2),
                  color.withOpacity(0.1),
                ],
              ),
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
                  style: TextStyle(
                    color: ModernConstants.textSecondary,
                    fontSize: 12,
                  ),
                ),
                Text(
                  '${DateFormat('MMM dd, yyyy • HH:mm').format(timestamp)} • $platform',
                  style: TextStyle(
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
              gradient: LinearGradient(
                colors: [
                  color.withOpacity(0.2),
                  color.withOpacity(0.1),
                ],
              ),
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
        ],
      ),
    );
  }
}
