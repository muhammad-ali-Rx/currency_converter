import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  
  // Controllers for Add Position Form
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _purchaseRateController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  
  // State variables
  String _selectedBaseCurrency = 'USD';
  String _selectedTargetCurrency = 'EUR';
  String _portfolioFilter = 'All';
  bool _isAddingPosition = false;

  // Sample portfolio data
  List<Map<String, dynamic>> _portfolioPositions = [
    {
      'id': '1',
      'baseCurrency': 'USD',
      'targetCurrency': 'EUR',
      'amount': 5000.0,
      'purchaseRate': 1.0850,
      'currentRate': 1.0892,
      'purchaseDate': DateTime.now().subtract(const Duration(days: 15)),
      'notes': 'Long-term investment position',
      'isActive': true,
    },
    {
      'id': '2',
      'baseCurrency': 'GBP',
      'targetCurrency': 'USD',
      'amount': 3000.0,
      'purchaseRate': 1.2680,
      'currentRate': 1.2654,
      'purchaseDate': DateTime.now().subtract(const Duration(days: 7)),
      'notes': 'Brexit hedge position',
      'isActive': true,
    },
    {
      'id': '3',
      'baseCurrency': 'USD',
      'targetCurrency': 'JPY',
      'amount': 10000.0,
      'purchaseRate': 148.50,
      'currentRate': 149.87,
      'purchaseDate': DateTime.now().subtract(const Duration(days: 30)),
      'notes': 'Yen carry trade',
      'isActive': true,
    },
    {
      'id': '4',
      'baseCurrency': 'EUR',
      'targetCurrency': 'GBP',
      'amount': 2500.0,
      'purchaseRate': 0.8650,
      'currentRate': 0.8612,
      'purchaseDate': DateTime.now().subtract(const Duration(days: 5)),
      'notes': 'Short-term trade',
      'isActive': false,
    },
  ];

  final List<String> _currencies = [
    'USD', 'EUR', 'GBP', 'JPY', 'AUD', 'CAD', 'CHF', 'CNY', 'INR', 'PKR'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _amountController.dispose();
    _purchaseRateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F23),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F23),
        title: const Text(
          'Portfolio',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _showAddPositionDialog,
            icon: const Icon(Icons.add, color: Color.fromARGB(255, 10, 108, 236)),
            tooltip: 'Add Position',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            color: const Color(0xFF1A1A2E),
            onSelected: (value) {
              switch (value) {
                case 'export':
                  _exportPortfolio();
                  break;
                case 'settings':
                  _showPortfolioSettings();
                  break;
                case 'refresh':
                  _refreshPortfolio();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'refresh',
                child: Row(
                  children: [
                    Icon(Icons.refresh, color: Color.fromARGB(255, 10, 108, 236)),
                    SizedBox(width: 8),
                    Text('Refresh Rates', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.download, color: Color.fromARGB(255, 10, 108, 236)),
                    SizedBox(width: 8),
                    Text('Export Data', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings, color: Color.fromARGB(255, 10, 108, 236)),
                    SizedBox(width: 8),
                    Text('Settings', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color.fromARGB(255, 10, 108, 236),
          labelColor: const Color.fromARGB(255, 10, 108, 236),
          unselectedLabelColor: const Color(0xFF8A94A6),
          labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Positions'),
            Tab(text: 'Analytics'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildPositionsTab(),
          _buildAnalyticsTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    final totalValue = _calculateTotalPortfolioValue();
    final totalPnL = _calculateTotalPnL();
    final totalPnLPercentage = _calculateTotalPnLPercentage();
    final activePositions = _portfolioPositions.where((p) => p['isActive']).length;

    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(const Duration(seconds: 1));
        _refreshPortfolio();
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Portfolio Summary Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color.fromARGB(255, 10, 108, 236),
                    Color(0xFF44A08D),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Portfolio Value',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${totalValue.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: totalPnL >= 0 ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              totalPnL >= 0 ? Icons.trending_up : Icons.trending_down,
                              color: totalPnL >= 0 ? Colors.green : Colors.red,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${totalPnL >= 0 ? '+' : ''}\$${totalPnL.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: totalPnL >= 0 ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${totalPnLPercentage >= 0 ? '+' : ''}${totalPnLPercentage.toStringAsFixed(2)}%',
                        style: TextStyle(
                          color: totalPnLPercentage >= 0 ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Quick Stats
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Active Positions',
                    activePositions.toString(),
                    Icons.account_balance_wallet,
                    const Color.fromARGB(255, 10, 108, 236),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Best Performer',
                    _getBestPerformer(),
                    Icons.trending_up,
                    Colors.green,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Positions',
                    _portfolioPositions.length.toString(),
                    Icons.list_alt,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Worst Performer',
                    _getWorstPerformer(),
                    Icons.trending_down,
                    Colors.red,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Recent Activity
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A2E),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color.fromARGB(255, 10, 108, 236).withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.history, color: Color.fromARGB(255, 10, 108, 236)),
                      SizedBox(width: 8),
                      Text(
                        'Recent Activity',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ..._getRecentPositions().map((position) => _buildActivityItem(position)).toList(),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Portfolio Allocation
            _buildPortfolioAllocation(),
          ],
        ),
      ),
    );
  }

  Widget _buildPositionsTab() {
    final filteredPositions = _portfolioFilter == 'All' 
        ? _portfolioPositions 
        : _portfolioPositions.where((p) => 
            _portfolioFilter == 'Active' ? p['isActive'] : !p['isActive']
          ).toList();

    return Column(
      children: [
        // Filter Bar
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: ['All', 'Active', 'Closed'].map((filter) {
              final isSelected = _portfolioFilter == filter;
              return Container(
                margin: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(filter),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _portfolioFilter = filter;
                    });
                  },
                  backgroundColor: const Color(0xFF1A1A2E),
                  selectedColor: const Color.fromARGB(255, 10, 108, 236).withOpacity(0.2),
                  labelStyle: TextStyle(
                    color: isSelected ? const Color.fromARGB(255, 10, 108, 236) : Colors.white,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  side: BorderSide(
                    color: isSelected ? const Color.fromARGB(255, 10, 108, 236) : Colors.transparent,
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        // Positions List
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              await Future.delayed(const Duration(seconds: 1));
              _refreshPortfolio();
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredPositions.length,
              itemBuilder: (context, index) {
                final position = filteredPositions[index];
                return _buildPositionCard(position);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyticsTab() {
    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(const Duration(seconds: 1));
        _refreshPortfolio();
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Portfolio Analytics',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Detailed analysis of your portfolio performance',
              style: TextStyle(
                color: Color(0xFF8A94A6),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),

            // Performance Chart Placeholder
            Container(
              height: 200,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A2E),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color.fromARGB(255, 10, 108, 236).withOpacity(0.3),
                ),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.show_chart,
                    color: Color.fromARGB(255, 10, 108, 236),
                    size: 48,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Portfolio Performance Chart',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Interactive chart showing portfolio value over time',
                    style: TextStyle(
                      color: Color(0xFF8A94A6),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Analytics Cards
            _buildAnalyticsCard(
              'Risk Analysis',
              'Portfolio risk assessment and diversification metrics',
              Icons.security,
              [
                {'label': 'Risk Level', 'value': 'Medium', 'color': Colors.orange},
                {'label': 'Diversification', 'value': '75%', 'color': Colors.green},
                {'label': 'Volatility', 'value': '12.5%', 'color': Colors.red},
              ],
            ),

            _buildAnalyticsCard(
              'Currency Exposure',
              'Breakdown of your portfolio by currency',
              Icons.pie_chart,
              [
                {'label': 'USD Exposure', 'value': '45%', 'color': const Color.fromARGB(255, 10, 108, 236)},
                {'label': 'EUR Exposure', 'value': '25%', 'color': Colors.green},
                {'label': 'GBP Exposure', 'value': '20%', 'color': Colors.orange},
                {'label': 'Other', 'value': '10%', 'color': Colors.purple},
              ],
            ),

            _buildAnalyticsCard(
              'Performance Metrics',
              'Key performance indicators for your portfolio',
              Icons.analytics,
              [
                {'label': 'Sharpe Ratio', 'value': '1.25', 'color': Colors.green},
                {'label': 'Max Drawdown', 'value': '-5.2%', 'color': Colors.red},
                {'label': 'Win Rate', 'value': '68%', 'color': Colors.green},
                {'label': 'Avg Hold Time', 'value': '15 days', 'color': const Color.fromARGB(255, 10, 108, 236)},
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF8A94A6),
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPositionCard(Map<String, dynamic> position) {
    final pnl = _calculatePositionPnL(position);
    final pnlPercentage = _calculatePositionPnLPercentage(position);
    final isProfit = pnl >= 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: position['isActive'] 
              ? const Color.fromARGB(255, 10, 108, 236).withOpacity(0.3)
              : const Color(0xFF8A94A6).withOpacity(0.3),
        ),
      ),
      child: InkWell(
        onTap: () => _showPositionDetails(position),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 10, 108, 236).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${position['baseCurrency']}/${position['targetCurrency']}',
                      style: const TextStyle(
                        color: Color.fromARGB(255, 10, 108, 236),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: position['isActive'] ? Colors.green.withOpacity(0.2) : Colors.grey.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      position['isActive'] ? 'Active' : 'Closed',
                      style: TextStyle(
                        color: position['isActive'] ? Colors.green : Colors.grey,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Amount',
                          style: const TextStyle(
                            color: Color(0xFF8A94A6),
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          '${position['baseCurrency']} ${position['amount'].toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Purchase Rate',
                          style: const TextStyle(
                            color: Color(0xFF8A94A6),
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          position['purchaseRate'].toStringAsFixed(4),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Rate',
                          style: const TextStyle(
                            color: Color(0xFF8A94A6),
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          position['currentRate'].toStringAsFixed(4),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'P&L',
                          style: const TextStyle(
                            color: Color(0xFF8A94A6),
                            fontSize: 12,
                          ),
                        ),
                        Row(
                          children: [
                            Icon(
                              isProfit ? Icons.trending_up : Icons.trending_down,
                              color: isProfit ? Colors.green : Colors.red,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${isProfit ? '+' : ''}\$${pnl.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: isProfit ? Colors.green : Colors.red,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'P&L %',
                          style: const TextStyle(
                            color: Color(0xFF8A94A6),
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          '${isProfit ? '+' : ''}${pnlPercentage.toStringAsFixed(2)}%',
                          style: TextStyle(
                            color: isProfit ? Colors.green : Colors.red,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Date',
                          style: const TextStyle(
                            color: Color(0xFF8A94A6),
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          '${position['purchaseDate'].day}/${position['purchaseDate'].month}/${position['purchaseDate'].year}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (position['notes'].isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  position['notes'],
                  style: const TextStyle(
                    color: Color(0xFF8A94A6),
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> position) {
    final pnl = _calculatePositionPnL(position);
    final isProfit = pnl >= 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F23),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 10, 108, 236).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.currency_exchange,
              color: Color.fromARGB(255, 10, 108, 236),
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${position['baseCurrency']}/${position['targetCurrency']}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${position['amount'].toStringAsFixed(0)} ${position['baseCurrency']}',
                  style: const TextStyle(
                    color: Color(0xFF8A94A6),
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
                '${isProfit ? '+' : ''}\$${pnl.toStringAsFixed(2)}',
                style: TextStyle(
                  color: isProfit ? Colors.green : Colors.red,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${DateTime.now().difference(position['purchaseDate']).inDays}d ago',
                style: const TextStyle(
                  color: Color(0xFF8A94A6),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioAllocation() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color.fromARGB(255, 10, 108, 236).withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.pie_chart, color: Color.fromARGB(255, 10, 108, 236)),
              SizedBox(width: 8),
              Text(
                'Portfolio Allocation',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._getCurrencyAllocation().entries.map((entry) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _getCurrencyColor(entry.key),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      entry.key,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Text(
                    '${entry.value.toStringAsFixed(1)}%',
                    style: const TextStyle(
                      color: Color(0xFF8A94A6),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
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

  Widget _buildAnalyticsCard(String title, String description, IconData icon, List<Map<String, dynamic>> metrics) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color.fromARGB(255, 10, 108, 236).withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color.fromARGB(255, 10, 108, 236)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              color: Color(0xFF8A94A6),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          ...metrics.map((metric) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    metric['label'],
                    style: const TextStyle(
                      color: Color(0xFF8A94A6),
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    metric['value'],
                    style: TextStyle(
                      color: metric['color'],
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
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

  // Helper Methods
  double _calculateTotalPortfolioValue() {
    return _portfolioPositions.fold(0.0, (sum, position) {
      return sum + (position['amount'] * position['currentRate']);
    });
  }

  double _calculateTotalPnL() {
    return _portfolioPositions.fold(0.0, (sum, position) {
      return sum + _calculatePositionPnL(position);
    });
  }

  double _calculateTotalPnLPercentage() {
    final totalInvested = _portfolioPositions.fold(0.0, (sum, position) {
      return sum + (position['amount'] * position['purchaseRate']);
    });
    if (totalInvested == 0) return 0.0;
    return (_calculateTotalPnL() / totalInvested) * 100;
  }

  double _calculatePositionPnL(Map<String, dynamic> position) {
    final currentValue = position['amount'] * position['currentRate'];
    final purchaseValue = position['amount'] * position['purchaseRate'];
    return currentValue - purchaseValue;
  }

  double _calculatePositionPnLPercentage(Map<String, dynamic> position) {
    final purchaseValue = position['amount'] * position['purchaseRate'];
    if (purchaseValue == 0) return 0.0;
    return (_calculatePositionPnL(position) / purchaseValue) * 100;
  }

  String _getBestPerformer() {
    if (_portfolioPositions.isEmpty) return 'N/A';
    
    var bestPosition = _portfolioPositions.first;
    var bestPnL = _calculatePositionPnLPercentage(bestPosition);
    
    for (var position in _portfolioPositions) {
      final pnl = _calculatePositionPnLPercentage(position);
      if (pnl > bestPnL) {
        bestPnL = pnl;
        bestPosition = position;
      }
    }
    
    return '${bestPosition['baseCurrency']}/${bestPosition['targetCurrency']}';
  }

  String _getWorstPerformer() {
    if (_portfolioPositions.isEmpty) return 'N/A';
    
    var worstPosition = _portfolioPositions.first;
    var worstPnL = _calculatePositionPnLPercentage(worstPosition);
    
    for (var position in _portfolioPositions) {
      final pnl = _calculatePositionPnLPercentage(position);
      if (pnl < worstPnL) {
        worstPnL = pnl;
        worstPosition = position;
      }
    }
    
    return '${worstPosition['baseCurrency']}/${worstPosition['targetCurrency']}';
  }

  List<Map<String, dynamic>> _getRecentPositions() {
    var sortedPositions = List<Map<String, dynamic>>.from(_portfolioPositions);
    sortedPositions.sort((a, b) => b['purchaseDate'].compareTo(a['purchaseDate']));
    return sortedPositions.take(3).toList();
  }

  Map<String, double> _getCurrencyAllocation() {
    final Map<String, double> allocation = {};
    double totalValue = 0;

    for (var position in _portfolioPositions) {
      final value = position['amount'] * position['currentRate'];
      totalValue += value;
      
      final currency = position['baseCurrency'];
      allocation[currency] = (allocation[currency] ?? 0) + value;
    }

    // Convert to percentages
    allocation.forEach((key, value) {
      allocation[key] = (value / totalValue) * 100;
    });

    return allocation;
  }

  Color _getCurrencyColor(String currency) {
    final colors = {
      'USD': const Color.fromARGB(255, 10, 108, 236),
      'EUR': Colors.green,
      'GBP': Colors.orange,
      'JPY': Colors.red,
      'AUD': Colors.purple,
      'CAD': Colors.teal,
    };
    return colors[currency] ?? Colors.grey;
  }

  // Dialog Methods
  void _showAddPositionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0F0F23),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.add, color: Color.fromARGB(255, 10, 108, 236)),
            SizedBox(width: 8),
            Text(
              'Add New Position',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Currency Pair Selection
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedBaseCurrency,
                        style: const TextStyle(color: Colors.white),
                        dropdownColor: const Color(0xFF1A1A2E),
                        decoration: const InputDecoration(
                          labelText: 'From Currency',
                          labelStyle: TextStyle(color: Color(0xFF8A94A6)),
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color.fromARGB(255, 10, 108, 236)),
                          ),
                        ),
                        items: _currencies.map((currency) {
                          return DropdownMenuItem(
                            value: currency,
                            child: Text(currency),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedBaseCurrency = value!;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedTargetCurrency,
                        style: const TextStyle(color: Colors.white),
                        dropdownColor: const Color(0xFF1A1A2E),
                        decoration: const InputDecoration(
                          labelText: 'To Currency',
                          labelStyle: TextStyle(color: Color(0xFF8A94A6)),
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color.fromARGB(255, 10, 108, 236)),
                          ),
                        ),
                        items: _currencies.map((currency) {
                          return DropdownMenuItem(
                            value: currency,
                            child: Text(currency),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedTargetCurrency = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Amount Field
                TextFormField(
                  controller: _amountController,
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    labelStyle: TextStyle(color: Color(0xFF8A94A6)),
                    prefixIcon: Icon(Icons.attach_money, color: Color(0xFF8A94A6)),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color.fromARGB(255, 10, 108, 236)),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter amount';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter valid amount';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Purchase Rate Field
                TextFormField(
                  controller: _purchaseRateController,
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Purchase Rate',
                    labelStyle: TextStyle(color: Color(0xFF8A94A6)),
                    prefixIcon: Icon(Icons.trending_up, color: Color(0xFF8A94A6)),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color.fromARGB(255, 10, 108, 236)),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter purchase rate';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter valid rate';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Notes Field
                TextFormField(
                  controller: _notesController,
                  style: const TextStyle(color: Colors.white),
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Notes (Optional)',
                    labelStyle: TextStyle(color: Color(0xFF8A94A6)),
                    prefixIcon: Icon(Icons.note, color: Color(0xFF8A94A6)),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color.fromARGB(255, 10, 108, 236)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF8A94A6))),
          ),
          ElevatedButton(
            onPressed: _isAddingPosition ? null : _addPosition,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 10, 108, 236),
            ),
            child: _isAddingPosition
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Text('Add Position'),
          ),
        ],
      ),
    );
  }

  void _showPositionDetails(Map<String, dynamic> position) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0F0F23),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          '${position['baseCurrency']}/${position['targetCurrency']} Details',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Amount', '${position['amount'].toStringAsFixed(2)} ${position['baseCurrency']}'),
              _buildDetailRow('Purchase Rate', position['purchaseRate'].toStringAsFixed(4)),
              _buildDetailRow('Current Rate', position['currentRate'].toStringAsFixed(4)),
              _buildDetailRow('Purchase Date', '${position['purchaseDate'].day}/${position['purchaseDate'].month}/${position['purchaseDate'].year}'),
              _buildDetailRow('P&L', '\$${_calculatePositionPnL(position).toStringAsFixed(2)}'),
              _buildDetailRow('P&L %', '${_calculatePositionPnLPercentage(position).toStringAsFixed(2)}%'),
              _buildDetailRow('Status', position['isActive'] ? 'Active' : 'Closed'),
              if (position['notes'].isNotEmpty)
                _buildDetailRow('Notes', position['notes']),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Color(0xFF8A94A6))),
          ),
          if (position['isActive'])
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _closePosition(position);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Close Position'),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Color(0xFF8A94A6), fontSize: 14),
          ),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // Action Methods
  void _addPosition() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isAddingPosition = true);
    
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    
    final newPosition = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'baseCurrency': _selectedBaseCurrency,
      'targetCurrency': _selectedTargetCurrency,
      'amount': double.parse(_amountController.text),
      'purchaseRate': double.parse(_purchaseRateController.text),
      'currentRate': double.parse(_purchaseRateController.text), // Same as purchase for new position
      'purchaseDate': DateTime.now(),
      'notes': _notesController.text,
      'isActive': true,
    };
    
    setState(() {
      _portfolioPositions.add(newPosition);
      _isAddingPosition = false;
    });
    
    // Clear form
    _amountController.clear();
    _purchaseRateController.clear();
    _notesController.clear();
    
    Navigator.pop(context);
    _showSuccessSnackBar('Position added successfully!');
  }

  void _closePosition(Map<String, dynamic> position) {
    setState(() {
      position['isActive'] = false;
    });
    _showSuccessSnackBar('Position closed successfully!');
  }

  void _refreshPortfolio() {
    // Simulate rate updates
    setState(() {
      for (var position in _portfolioPositions) {
        // Add some random variation to current rates
        final variation = (position['purchaseRate'] * 0.02) * (0.5 - (DateTime.now().millisecond % 1000) / 1000);
        position['currentRate'] = position['purchaseRate'] + variation;
      }
    });
    _showSuccessSnackBar('Portfolio refreshed!');
  }

  void _exportPortfolio() {
    _showSuccessSnackBar('Portfolio data exported successfully!');
  }

  void _showPortfolioSettings() {
    _showSuccessSnackBar('Opening portfolio settings...');
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color.fromARGB(255, 10, 108, 236),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}