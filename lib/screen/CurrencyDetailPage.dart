import 'package:currency_converter/screen/convter.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:currency_converter/model/currency.dart';

import 'dart:math';
import 'dart:async';

class CurrencyDetailPage extends StatefulWidget {
  final Currency currency;

  const CurrencyDetailPage({super.key, required this.currency});

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
}

class _CurrencyDetailPageState extends State<CurrencyDetailPage> {
  final TextEditingController _usdController = TextEditingController();
  double _convertedAmount = 0;
  bool _isRealTimeActive = true;
  DateTime _lastUpdateTime = DateTime.now();
  Timer? _realTimeTimer;
  
  String _selectedPeriod = '1Y';
  List<ChartDataPoint> _chartData = [];
  bool _isLoadingChart = false;
  late Currency _currentCurrency;

  // Available currencies for conversion
  final List<Currency> _availableCurrencies = [
    Currency(code: 'USD', name: 'US Dollar', rate: 1.0, amount: 1.0, percentChange: 0.0, ratePerUsd: 1.0, color: Colors.green),
    Currency(code: 'EUR', name: 'Euro', rate: 0.85, amount: 0.85, percentChange: 1.2, ratePerUsd: 0.85, color: Colors.blue),
    Currency(code: 'GBP', name: 'British Pound', rate: 0.73, amount: 0.73, percentChange: -0.8, ratePerUsd: 0.73, color: Colors.purple),
    Currency(code: 'JPY', name: 'Japanese Yen', rate: 110.0, amount: 110.0, percentChange: 0.5, ratePerUsd: 110.0, color: Colors.red),
    Currency(code: 'CAD', name: 'Canadian Dollar', rate: 1.25, amount: 1.25, percentChange: 0.3, ratePerUsd: 1.25, color: Colors.orange),
  ];

  Currency _selectedToCurrency = Currency(code: 'USD', name: 'US Dollar', rate: 1.0, amount: 1.0, percentChange: 0.0, ratePerUsd: 1.0, color: Colors.green);

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
    _currentCurrency = widget.currency;
    _generateChartData();
    _startRealTimeUpdates();
  }

  @override
  void dispose() {
    _realTimeTimer?.cancel();
    _usdController.dispose();
    super.dispose();
  }

  void _startRealTimeUpdates() {
    _realTimeTimer?.cancel();
    _realTimeTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_isRealTimeActive && mounted) {
        _updateRatesRealTime();
      }
    });
  }

  void _updateRatesRealTime() {
    setState(() {
      final random = Random();
      final fluctuation = (random.nextDouble() - 0.5) * 0.01;
      final newRate = _currentCurrency.rate * (1 + fluctuation);
      final newAmount = _currentCurrency.amount * (1 + fluctuation);
      final newPercentChange = _currentCurrency.percentChange + (random.nextDouble() - 0.5) * 0.1;

      _currentCurrency = Currency(
        code: _currentCurrency.code,
        name: _currentCurrency.name,
        rate: newRate,
        amount: newAmount,
        percentChange: newPercentChange,
        ratePerUsd: newRate,
        color: _currentCurrency.color,
      );

      _lastUpdateTime = DateTime.now();

      if (_selectedPeriod == '1D' && _chartData.isNotEmpty) {
        final lastPoint = _chartData.last;
        final newValue = lastPoint.value * (1 + fluctuation);
        
        if (_chartData.length > 24) {
          _chartData.removeAt(0);
        }
        
        _chartData.add(ChartDataPoint(
          date: DateTime.now(),
          value: newValue,
          timestamp: DateTime.now().millisecondsSinceEpoch,
        ));
      }
    });

    if (_usdController.text.isNotEmpty) {
      _convertCurrency(_usdController.text);
    }
  }

  void _generateChartData() {
    setState(() {
      _isLoadingChart = true;
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      final selectedPeriodData = _timePeriods.firstWhere(
        (period) => period['label'] == _selectedPeriod,
        orElse: () => {'label': '1Y', 'days': 365},
      );

      final days = selectedPeriodData['days'] as int;
      final data = _generateHistoricalData(days, _currentCurrency.rate);

      if (mounted) {
        setState(() {
          _chartData = data;
          _isLoadingChart = false;
        });
      }
    });
  }

  List<ChartDataPoint> _generateHistoricalData(int days, double baseRate) {
    final List<ChartDataPoint> data = [];
    final now = DateTime.now();
    final random = Random();
    double currentRate = baseRate * 0.8;

    for (int i = days; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));

      final dailyChange = (random.nextDouble() - 0.5) * 0.05;
      final trendFactor = ((days - i) / days) * 0.25;

      currentRate = currentRate * (1 + dailyChange + trendFactor / days);

      if (random.nextDouble() < 0.02) {
        final eventImpact = (random.nextDouble() - 0.5) * 0.15;
        currentRate = currentRate * (1 + eventImpact);
      }

      data.add(ChartDataPoint(
        date: date,
        value: max(currentRate, 0.01),
        timestamp: date.millisecondsSinceEpoch,
      ));
    }

    return data;
  }

  void _convertCurrency(String input) {
    final amount = double.tryParse(input);
    if (amount != null) {
      setState(() {
        // Convert from current currency to selected currency
        final usdAmount = amount / _currentCurrency.ratePerUsd;
        _convertedAmount = usdAmount * _selectedToCurrency.ratePerUsd;
      });
    } else {
      setState(() {
        _convertedAmount = 0;
      });
    }
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
          child: CircularProgressIndicator(color: Color(0xFF4ECDC4)),
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
                      '$formattedDate\n${barSpot.y.toStringAsFixed(4)} ${_currentCurrency.code}',
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
    final c = _currentCurrency;
    final changeColor = c.percentChange >= 0 ? Colors.green : Colors.red;
    final accentColor = c.color ?? const Color(0xFF4ECDC4);
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
            Text(
              '${c.name} (${c.code})',
              style: const TextStyle(color: Colors.white, fontSize: 18),
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
            // Price Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF0F0F23),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: const Color(0xFF1A1A2E).withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CircleAvatar(
                        backgroundColor: accentColor,
                        child: Text(
                          c.code[0],
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '\$${(c.amount / c.rate).toStringAsFixed(4)}',
                            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${c.amount.toStringAsFixed(4)} ${c.code}',
                            style: const TextStyle(color: Color(0xFF8A94A6)),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Exchange Rate:', style: TextStyle(color: Color(0xFF8A94A6))),
                      Text(
                        '1 USD = ${c.ratePerUsd.toStringAsFixed(4)} ${c.code}',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('24h Change:', style: TextStyle(color: Color(0xFF8A94A6))),
                      Row(
                        children: [
                          Icon(
                            c.percentChange >= 0 ? Icons.trending_up : Icons.trending_down,
                            color: changeColor,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${c.percentChange >= 0 ? '+' : ''}${c.percentChange.toStringAsFixed(2)}%',
                            style: TextStyle(color: changeColor, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('$_selectedPeriod Change:', style: const TextStyle(color: Color(0xFF8A94A6))),
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
                  const Row(
                    children: [
                      Icon(Icons.show_chart, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Price Chart',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
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

            // Quick Currency Converter
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Quick Convert ${c.code}',
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CurrencyConverterScreen(
                                fromCurrency: _currentCurrency,
                                availableCurrencies: _availableCurrencies,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4ECDC4),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Full Converter',
                            style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _usdController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Amount in ${c.code}',
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
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4ECDC4),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.swap_horiz, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              backgroundColor: const Color(0xFF0F0F23),
                              builder: (context) => Container(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      'Select Currency',
                                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 16),
                                    ..._availableCurrencies.map((currency) => ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: currency.color,
                                        child: Text(currency.code[0], style: const TextStyle(color: Colors.white)),
                                      ),
                                      title: Text(currency.name, style: const TextStyle(color: Colors.white)),
                                      subtitle: Text(currency.code, style: const TextStyle(color: Color(0xFF8A94A6))),
                                      onTap: () {
                                        setState(() {
                                          _selectedToCurrency = currency;
                                        });
                                        Navigator.pop(context);
                                        if (_usdController.text.isNotEmpty) {
                                          _convertCurrency(_usdController.text);
                                        }
                                      },
                                    )).toList(),
                                  ],
                                ),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A1A2E),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFF8A94A6).withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: _selectedToCurrency.color,
                                  radius: 12,
                                  child: Text(
                                    _selectedToCurrency.code[0],
                                    style: const TextStyle(color: Colors.white, fontSize: 12),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _selectedToCurrency.code,
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const Icon(Icons.keyboard_arrow_down, color: Color(0xFF8A94A6)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_convertedAmount > 0)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A2E),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF4ECDC4).withOpacity(0.3)),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Converted Amount',
                            style: TextStyle(color: Color(0xFF8A94A6), fontSize: 14),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${_convertedAmount.toStringAsFixed(4)} ${_selectedToCurrency.code}',
                            style: const TextStyle(
                              color: Color(0xFF4ECDC4),
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_usdController.text} ${c.code} = ${_convertedAmount.toStringAsFixed(4)} ${_selectedToCurrency.code}',
                            style: const TextStyle(color: Color(0xFF8A94A6), fontSize: 12),
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
                  _buildInfoRow('Market Cap', '\$2.1T'),
                  _buildInfoRow('24h Volume', '\$45.2B'),
                  _buildInfoRow('Circulating Supply', '19.8M ${c.code}'),
                  _buildInfoRow('All Time High', '\$${(c.rate * 1.5).toStringAsFixed(4)}'),
                  if (_chartData.isNotEmpty) ...[
                    _buildInfoRow('52 Week High', _chartData.map((d) => d.value).reduce(max).toStringAsFixed(4)),
                    _buildInfoRow('52 Week Low', _chartData.map((d) => d.value).reduce(min).toStringAsFixed(4)),
                  ],
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
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}