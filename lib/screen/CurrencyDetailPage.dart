import 'package:currency_converter/screen/convter.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:currency_converter/model/currency.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:currency_converter/auth/auth_provider.dart';
import 'dart:math';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

class CurrencyDetailPage extends StatefulWidget {
  final Currency currency; // Selected currency (PKR)
  final Currency baseCurrency; // Base currency (USD)

  const CurrencyDetailPage({
    super.key, 
    required this.currency,
    required this.baseCurrency, // ✅ NEW: Base currency parameter
  });

  @override
  State<CurrencyDetailPage> createState() => _CurrencyDetailPageState();
}

class ChartDataPoint {
  final DateTime date;
  final double value;
  final int timestamp;

  ChartDataPoint({
    required this.date,
    required this.value,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'value': value,
      'timestamp': timestamp,
    };
  }
}

class _CurrencyDetailPageState extends State<CurrencyDetailPage> {
  final TextEditingController _amountController = TextEditingController();
  double _convertedAmount = 0;
  bool _isRealTimeActive = true;
  DateTime _lastUpdateTime = DateTime.now();
  Timer? _realTimeTimer;
  
  String _selectedPeriod = '1Y';
  List<ChartDataPoint> _chartData = [];
  bool _isLoadingChart = false;
  
  // ✅ FIXED: Base currency logic
  late Currency _baseCurrency; // From Currency (USD)
  late Currency _targetCurrency; // To Currency (PKR)
  
  // ✅ Direct conversion rate (Base → Target)
  double _conversionRate = 1.0;
  double _previousRate = 1.0;
  bool _isRateIncreasing = true;

  // ✅ User Profile Data (for database only)
  String _userName = '';
  String _userEmail = '';
  String _userId = '';

  final List<Map<String, dynamic>> _timePeriods = [
    {'label': '1D', 'days': 1},
    {'label': '1W', 'days': 7},
    {'label': '1M', 'days': 30},
    {'label': '3M', 'days': 90},
    {'label': '6M', 'days': 180},
    {'label': '1Y', 'days': 365},
  ];

  @override
  void initState() {
    super.initState();
    // ✅ FIXED: Proper base and target assignment
    _baseCurrency = widget.baseCurrency; // USD (base)
    _targetCurrency = widget.currency; // PKR (selected)
    
    _loadUserProfile();
    _updateConversionRate();
    _generateChartData();
    _startRealTimeUpdates();
  }

  @override
  void dispose() {
    _realTimeTimer?.cancel();
    _amountController.dispose();
    super.dispose();
  }

  // ✅ Load user profile data (for database tracking only)
  Future<void> _loadUserProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        setState(() {
          _userId = user.uid;
          _userEmail = user.email ?? '';
          _userName = user.displayName ?? '';
        });

        // Load additional profile data from Firestore
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          final userData = userDoc.data();
          if (mounted) {
            setState(() {
              _userName = userData?['name'] ?? userData?['displayName'] ?? user.displayName ?? '';
              _userEmail = userData?['email'] ?? user.email ?? '';
            });
          }
        }

        print('✅ User Profile Loaded: $_userName ($_userEmail)');
      }
    } catch (e) {
      print('❌ Error loading user profile: $e');
    }
  }

  // ✅ FIXED: Calculate conversion rate (Base → Target)
  void _updateConversionRate() {
    _previousRate = _conversionRate;
    
    // ✅ Base to Target conversion
    if (_baseCurrency.code == _targetCurrency.code) {
      _conversionRate = 1.0;
    } else {
      // Direct rate from base to target
      _conversionRate = _getDirectRate(_baseCurrency.code, _targetCurrency.code);
    }
    
    _isRateIncreasing = _conversionRate > _previousRate;
    
    print('🔄 Rate: 1 ${_baseCurrency.code} = $_conversionRate ${_targetCurrency.code}');
  }

  // ✅ Get direct exchange rate between two currencies
  double _getDirectRate(String from, String to) {
    // Real exchange rates
    final Map<String, Map<String, double>> directRates = {
      'USD': {
        'PKR': 278.0, 'INR': 83.12, 'EUR': 0.92, 'GBP': 0.79, 'JPY': 149.0,
        'CAD': 1.36, 'AUD': 1.52, 'CHF': 0.88, 'CNY': 7.24, 'BDT': 110.0,
        'LKR': 325.0, 'NPR': 133.0, 'KRW': 1320.0, 'SGD': 1.35, 'MYR': 4.7,
        'THB': 35.8, 'AED': 3.67, 'SAR': 3.75,
      },
      'PKR': {
        'USD': 0.0036, 'INR': 0.30, 'EUR': 0.0033, 'GBP': 0.0028, 'JPY': 0.54,
        'CAD': 0.0049, 'AUD': 0.0055, 'CHF': 0.0032, 'CNY': 0.026, 'BDT': 0.40,
      },
      'INR': {
        'USD': 0.012, 'PKR': 3.34, 'EUR': 0.011, 'GBP': 0.0095, 'JPY': 1.79,
        'CAD': 0.016, 'AUD': 0.018, 'CHF': 0.011, 'CNY': 0.087, 'BDT': 1.32,
      },
      'EUR': {
        'USD': 1.09, 'PKR': 302.0, 'INR': 90.4, 'GBP': 0.86, 'JPY': 162.0,
        'CAD': 1.48, 'AUD': 1.65, 'CHF': 0.96, 'CNY': 7.88,
      },
      'GBP': {
        'USD': 1.27, 'PKR': 353.0, 'INR': 105.5, 'EUR': 1.16, 'JPY': 189.0,
        'CAD': 1.73, 'AUD': 1.93, 'CHF': 1.12, 'CNY': 9.20,
      },
    };

    return directRates[from]?[to] ?? 1.0;
  }

  void _startRealTimeUpdates() {
    _realTimeTimer?.cancel();
    _realTimeTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_isRealTimeActive && mounted) {
        _updateRatesRealTime();
      }
    });
  }

  // ✅ Real-time updates
  void _updateRatesRealTime() {
    setState(() {
      final random = Random();
      final fluctuation = (random.nextDouble() - 0.5) * 0.001;
      
      _previousRate = _conversionRate;
      _conversionRate = _conversionRate * (1 + fluctuation);
      
      // Keep rate within reasonable bounds
      final baseRate = _getDirectRate(_baseCurrency.code, _targetCurrency.code);
      _conversionRate = max(_conversionRate, baseRate * 0.95);
      _conversionRate = min(_conversionRate, baseRate * 1.05);

      _isRateIncreasing = _conversionRate > _previousRate;
      _lastUpdateTime = DateTime.now();

      // Update chart for real-time periods
      if (_selectedPeriod == '1D' && _chartData.isNotEmpty) {
        if (_chartData.length > 100) {
          _chartData.removeAt(0);
        }
        
        _chartData.add(ChartDataPoint(
          date: DateTime.now(),
          value: _conversionRate,
          timestamp: DateTime.now().millisecondsSinceEpoch,
        ));
      }
    });

    // ✅ Save conversion rate with user data (for admin tracking)
    _saveConversionRateToHistory();

    if (_amountController.text.isNotEmpty) {
      _convertCurrency(_amountController.text);
    }
  }

  // ✅ Save conversion rate with user profile data (for admin panel)
  Future<void> _saveConversionRateToHistory() async {
    try {
      final now = DateTime.now();
      final pairCode = '${_baseCurrency.code}_${_targetCurrency.code}';
      final docId = '${pairCode}_${now.millisecondsSinceEpoch}';
      
      await FirebaseFirestore.instance
          .collection('currency_conversion_history')
          .doc(docId)
          .set({
        'base_currency': _baseCurrency.code,
        'target_currency': _targetCurrency.code,
        'conversion_rate': _conversionRate,
        'timestamp': FieldValue.serverTimestamp(),
        'date': now.toIso8601String(),
        'period': _selectedPeriod,
        
        // ✅ User info for admin tracking
        'user_info': {
          'uid': _userId,
          'name': _userName,
          'email': _userEmail,
        },
        
        // ✅ Additional tracking data
        'session_info': {
          'app_version': '2.0.0',
          'platform': 'Flutter',
          'conversion_type': 'base_to_target',
        },
      });
      
      print('💾 Saved conversion: $_userName converted ${_baseCurrency.code} to ${_targetCurrency.code}');
    } catch (e) {
      print('❌ Error saving conversion history: $e');
    }
  }

  // ✅ Convert currency (Base → Target)
  void _convertCurrency(String input) {
    final amount = double.tryParse(input);
    if (amount != null) {
      setState(() {
        _convertedAmount = amount * _conversionRate;
        
        print('🔄 Converting: $amount ${_baseCurrency.code} × $_conversionRate = $_convertedAmount ${_targetCurrency.code}');
      });
      
      // ✅ Save conversion transaction for admin tracking
      if (amount > 0) {
        _saveConversionTransaction(amount, _convertedAmount);
      }
    } else {
      setState(() {
        _convertedAmount = 0;
      });
    }
  }

  // ✅ Save individual conversion transaction
  Future<void> _saveConversionTransaction(double amount, double convertedAmount) async {
    try {
      final now = DateTime.now();
      final transactionId = 'txn_${now.millisecondsSinceEpoch}';
      
      await FirebaseFirestore.instance
          .collection('conversion_transactions')
          .doc(transactionId)
          .set({
        'transaction_id': transactionId,
        'base_currency': _baseCurrency.code,
        'target_currency': _targetCurrency.code,
        'base_amount': amount,
        'target_amount': convertedAmount,
        'conversion_rate': _conversionRate,
        
        // ✅ User info for admin panel
        'user_info': {
          'uid': _userId,
          'name': _userName,
          'email': _userEmail,
        },
        
        'timestamp': FieldValue.serverTimestamp(),
        'date': now.toIso8601String(),
        'transaction_type': 'currency_conversion',
      });
      
      print('💰 Transaction saved: $_userName converted $amount ${_baseCurrency.code} to $convertedAmount ${_targetCurrency.code}');
    } catch (e) {
      print('❌ Error saving transaction: $e');
    }
  }

  // Generate historical data
  Future<void> _generateChartData() async {
    setState(() {
      _isLoadingChart = true;
    });

    final selectedPeriodData = _timePeriods.firstWhere(
      (period) => period['label'] == _selectedPeriod,
      orElse: () => {'label': '1Y', 'days': 365},
    );

    final days = selectedPeriodData['days'] as int;
    final historicalData = _generateHistoricalDataForPair(days);
    
    if (mounted) {
      setState(() {
        _chartData = historicalData;
        _isLoadingChart = false;
      });
    }
  }

  List<ChartDataPoint> _generateHistoricalDataForPair(int days) {
    final List<ChartDataPoint> data = [];
    final now = DateTime.now();
    final random = Random();
    
    double currentRate = _conversionRate;
    
    for (int i = days; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dailyChange = (random.nextDouble() - 0.5) * 0.008;
      final trendFactor = sin((days - i) / days * 2 * pi) * 0.001;
      
      currentRate = currentRate * (1 + dailyChange + trendFactor);
      currentRate = max(currentRate, _conversionRate * 0.85);
      currentRate = min(currentRate, _conversionRate * 1.15);

      data.add(ChartDataPoint(
        date: date,
        value: currentRate,
        timestamp: date.millisecondsSinceEpoch,
      ));
    }

    return data;
  }

  void _selectTimePeriod(String period) {
    setState(() {
      _selectedPeriod = period;
    });
    _generateChartData();
  }

  Map<String, double> _calculatePeriodPerformance() {
    if (_chartData.length < 2) return {'change': 0, 'percentage': 0};

    final firstValue = _chartData.first.value;
    final lastValue = _chartData.last.value;
    final change = lastValue - firstValue;
    final percentage = (change / firstValue) * 100;

    return {'change': change, 'percentage': percentage};
  }

  Widget _buildTimePeriodSelector() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _timePeriods.length,
        itemBuilder: (context, index) {
          final period = _timePeriods[index];
          final isSelected = _selectedPeriod == period['label'];

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => _selectTimePeriod(period['label']),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF4ECDC4) : const Color(0xFF1A1A2E),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF4ECDC4) : const Color(0xFF8A94A6).withOpacity(0.3),
                  ),
                ),
                child: Text(
                  period['label'],
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF8A94A6),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildChart() {
    if (_isLoadingChart) {
      return const SizedBox(
        height: 300,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Color(0xFF4ECDC4)),
              SizedBox(height: 16),
              Text('Loading chart data...', style: TextStyle(color: Color(0xFF8A94A6))),
            ],
          ),
        ),
      );
    }

    if (_chartData.isEmpty) {
      return const SizedBox(
        height: 300,
        child: Center(
          child: Text('No data available', style: TextStyle(color: Color(0xFF8A94A6))),
        ),
      );
    }

    final performance = _calculatePeriodPerformance();
    final isPositive = performance['percentage']! >= 0;
    final chartColor = isPositive ? Colors.green : Colors.red;

    final spots = _chartData.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.value);
    }).toList();

    final yValues = spots.map((spot) => spot.y).toList();
    final minY = yValues.isNotEmpty ? yValues.reduce(min) * 0.98 : 0.0;
    final maxY = yValues.isNotEmpty ? yValues.reduce(max) * 1.02 : 1.0;

    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) {
              return const FlLine(
                color: Color(0xFF8A94A6),
                strokeWidth: 0.5,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: spots.length > 5 ? spots.length / 5 : 1,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < _chartData.length) {
                    final date = _chartData[index].date;
                    String formattedDate;
                    
                    switch (_selectedPeriod) {
                      case '1D':
                        formattedDate = '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
                        break;
                      case '1W':
                        final weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
                        formattedDate = weekdays[date.weekday % 7];
                        break;
                      case '1M':
                        formattedDate = '${date.day}';
                        break;
                      default:
                        formattedDate = '${date.month}/${date.year.toString().substring(2)}';
                    }
                    
                    return Text(
                      formattedDate,
                      style: const TextStyle(color: Color(0xFF8A94A6), fontSize: 10),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 60,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toStringAsFixed(3),
                    style: const TextStyle(color: Color(0xFF8A94A6), fontSize: 10),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: spots.isNotEmpty ? spots.length.toDouble() - 1 : 1,
          minY: minY,
          maxY: maxY,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: chartColor,
              barWidth: 2,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: chartColor.withOpacity(0.1),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            enabled: true,
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (touchedSpot) => const Color(0xFF0F0F23),
              tooltipBorder: const BorderSide(color: Colors.transparent),
              tooltipPadding: const EdgeInsets.all(8),
              getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                return touchedBarSpots.map((barSpot) {
                  final index = barSpot.x.toInt();
                  if (index >= 0 && index < _chartData.length) {
                    final date = _chartData[index].date;
                    final formattedDate = _selectedPeriod == '1D'
                        ? '${date.hour}:${date.minute.toString().padLeft(2, '0')}'
                        : '${date.day}/${date.month}/${date.year}';
                    return LineTooltipItem(
                      '$formattedDate\n1 ${_baseCurrency.code} = ${barSpot.y.toStringAsFixed(4)} ${_targetCurrency.code}',
                      const TextStyle(color: Colors.white, fontSize: 12),
                    );
                  }
                  return null;
                }).where((item) => item != null).cast<LineTooltipItem>().toList();
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChartStats() {
    if (_chartData.isEmpty) return const SizedBox.shrink();

    final values = _chartData.map((d) => d.value).toList();
    final high = values.reduce(max);
    final low = values.reduce(min);
    final avg = values.reduce((a, b) => a + b) / values.length;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem('High', high.toStringAsFixed(4)),
          _buildStatItem('Low', low.toStringAsFixed(4)),
          _buildStatItem('Avg', avg.toStringAsFixed(4)),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xFF8A94A6), fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final performance = _calculatePeriodPerformance();
    final isPeriodPositive = performance['percentage']! >= 0;
    final periodChangeColor = isPeriodPositive ? Colors.green : Colors.red;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A1A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ FIXED: Show Base → Target
            Text(
              '${_baseCurrency.code} → ${_targetCurrency.code}',
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _isRealTimeActive ? Colors.green : Colors.orange,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _isRealTimeActive ? 'LIVE' : 'PAUSED',
                    style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Updated: ${_lastUpdateTime.toString().substring(11, 19)}',
                  style: const TextStyle(color: Color(0xFF8A94A6), fontSize: 10),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isRealTimeActive ? Icons.pause : Icons.play_arrow,
              color: _isRealTimeActive ? Colors.green : Colors.red,
            ),
            onPressed: () {
              setState(() {
                _isRealTimeActive = !_isRealTimeActive;
                if (_isRealTimeActive) {
                  _startRealTimeUpdates();
                } else {
                  _realTimeTimer?.cancel();
                }
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ MAIN: Conversion Rate Card (No From/To selectors)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF0F0F23),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: const Color(0xFF1A1A2E).withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  Column(
                    children: [
                      // Currency name display
                      Text(
                        _targetCurrency.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _targetCurrency.code,
                        style: const TextStyle(
                          color: Color(0xFF8A94A6),
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Rate display
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _isRateIncreasing ? Icons.trending_up : Icons.trending_down,
                            color: _isRateIncreasing ? Colors.green : Colors.red,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _conversionRate.toStringAsFixed(4),
                            style: TextStyle(
                              color: _isRateIncreasing ? Colors.green : Colors.red,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '1 ${_baseCurrency.code} = ${_conversionRate.toStringAsFixed(4)} ${_targetCurrency.code}',
                        style: const TextStyle(color: Color(0xFF8A94A6), fontSize: 14),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // ✅ Currency Info (No selectors)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A2E),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${_baseCurrency.code}',
                          style: const TextStyle(
                            color: Color(0xFF4ECDC4),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.arrow_forward, color: Color(0xFF4ECDC4)),
                        const SizedBox(width: 12),
                        Text(
                          '${_targetCurrency.code}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Period Performance
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('$_selectedPeriod Performance:', style: const TextStyle(color: Color(0xFF8A94A6))),
                      Row(
                        children: [
                          Icon(
                            isPeriodPositive ? Icons.trending_up : Icons.trending_down,
                            color: periodChangeColor,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${isPeriodPositive ? '+' : ''}${performance['percentage']!.toStringAsFixed(2)}%',
                            style: TextStyle(color: periodChangeColor, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Chart Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF0F0F23),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: const Color(0xFF1A1A2E).withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.show_chart, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '${_baseCurrency.code}/${_targetCurrency.code} Chart',
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildTimePeriodSelector(),
                  const SizedBox(height: 16),
                  _buildChart(),
                  _buildChartStats(),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ✅ Currency Converter
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF0F0F23),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: const Color(0xFF1A1A2E).withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Currency Converter',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  
                  TextField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                    decoration: InputDecoration(
                      labelText: 'Enter amount in ${_baseCurrency.code}',
                      labelStyle: const TextStyle(color: Color(0xFF8A94A6)),
                      filled: true,
                      fillColor: const Color(0xFF1A1A2E),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: const Color(0xFF8A94A6).withOpacity(0.3)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: const Color(0xFF8A94A6).withOpacity(0.3)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFF4ECDC4)),
                      ),
                    ),
                    onChanged: _convertCurrency,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  if (_convertedAmount > 0)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A2E),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF4ECDC4).withOpacity(0.3)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _isRateIncreasing ? Icons.trending_up : Icons.trending_down,
                                color: _isRateIncreasing ? Colors.green : Colors.red,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${_convertedAmount.toStringAsFixed(2)} ${_targetCurrency.code}',
                                style: const TextStyle(
                                  color: Color(0xFF4ECDC4),
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${_amountController.text} ${_baseCurrency.code} = ${_convertedAmount.toStringAsFixed(4)} ${_targetCurrency.code}',
                            style: const TextStyle(color: Color(0xFF8A94A6), fontSize: 14),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4ECDC4).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Live Rate: 1 ${_baseCurrency.code} = ${_conversionRate.toStringAsFixed(6)} ${_targetCurrency.code}',
                              style: const TextStyle(color: Color(0xFF4ECDC4), fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Additional Info
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF0F0F23),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: const Color(0xFF1A1A2E).withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  _buildInfoRow('Currency Pair', '${_baseCurrency.code}/${_targetCurrency.code}'),
                  _buildInfoRow('Current Rate', _conversionRate.toStringAsFixed(6)),
                  _buildInfoRow('Rate Direction', _isRateIncreasing ? '📈 Increasing' : '📉 Decreasing'),
                  if (_chartData.isNotEmpty) ...[
                    _buildInfoRow('${_selectedPeriod} High', _chartData.map((d) => d.value).reduce(max).toStringAsFixed(4)),
                    _buildInfoRow('${_selectedPeriod} Low', _chartData.map((d) => d.value).reduce(min).toStringAsFixed(4)),
                  ],
                  _buildInfoRow('Last Updated', _lastUpdateTime.toString().substring(11, 19)),
                  _buildInfoRow('Update Frequency', _isRealTimeActive ? 'Every 2 seconds' : 'Paused'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF8A94A6))),
          Expanded(
            child: Text(
              value, 
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}