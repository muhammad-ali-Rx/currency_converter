import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '/model/currency.dart';
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
  
  // Chart related variables
  String _selectedPeriod = '1Y';
  List<ChartDataPoint> _chartData = [];
  bool _isLoadingChart = false;
  late Currency _currentCurrency;

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
    _realTimeTimer = Timer.periodic(Duration(seconds: 2), (timer) {
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

      // Update chart data for real-time view
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

    // Update converter if there's input
    if (_usdController.text.isNotEmpty) {
      _convertFromUsd(_usdController.text);
    }
  }

  void _generateChartData() {
    setState(() {
      _isLoadingChart = true;
    });

    // Simulate API delay
    Future.delayed(Duration(milliseconds: 500), () {
      final selectedPeriodData = _timePeriods.firstWhere(
        (period) => period['label'] == _selectedPeriod,
        orElse: () => {'label': '1Y', 'days': 365},
      );

      final days = selectedPeriodData['days'] as int;
      final data = _generateHistoricalData(days, _currentCurrency.rate);

      setState(() {
        _chartData = data;
        _isLoadingChart = false;
      });
    });
  }

  List<ChartDataPoint> _generateHistoricalData(int days, double baseRate) {
    final List<ChartDataPoint> data = [];
    final now = DateTime.now();
    final random = Random();
    double currentRate = baseRate * 0.8; // Start from 80% of current rate

    for (int i = days; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));

      // Add realistic market movements
      final dailyChange = (random.nextDouble() - 0.5) * 0.05; // ±2.5% daily change
      final trendFactor = ((days - i) / days) * 0.25; // Gradual upward trend

      currentRate = currentRate * (1 + dailyChange + trendFactor / days);

      // Add major market events (random spikes/dips)
      if (random.nextDouble() < 0.02) {
        final eventImpact = (random.nextDouble() - 0.5) * 0.15; // ±7.5% impact
        currentRate = currentRate * (1 + eventImpact);
      }

      data.add(ChartDataPoint(
        date: date,
        value: max(currentRate, 0.01), // Fixed: Use max instead of math.max
        timestamp: date.millisecondsSinceEpoch,
      ));
    }

    return data;
  }

  void _convertFromUsd(String input) {
    final usd = double.tryParse(input);
    if (usd != null) {
      setState(() {
        _convertedAmount = usd * _currentCurrency.ratePerUsd;
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
            padding: EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => _selectTimePeriod(period['label']),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue : Color(0xFF2A2D36),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? Colors.blue : Colors.grey.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  period['label'],
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey,
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
      return SizedBox(
        height: 300,
        child: Center(
          child: CircularProgressIndicator(color: Colors.blue),
        ),
      );
    }

    if (_chartData.isEmpty) {
      return SizedBox(
        height: 300,
        child: Center(
          child: Text('No data available', style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    final performance = _calculatePeriodPerformance();
    final isPositive = performance['percentage']! >= 0;
    final chartColor = isPositive ? Colors.green : Colors.red;

    final spots = _chartData.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.value);
    }).toList();

    return Container(
      height: 300,
      padding: EdgeInsets.all(16),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: null,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey.withOpacity(0.2),
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: spots.length / 5,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= 0 && value.toInt() < _chartData.length) {
                    final date = _chartData[value.toInt()].date;
                    String formattedDate;
                    
                    if (_selectedPeriod == '1D') {
                      formattedDate = '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
                    } else if (_selectedPeriod == '1W') {
                      formattedDate = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'][date.weekday % 7];
                    } else if (_selectedPeriod == '1M') {
                      formattedDate = '${date.day}';
                    } else {
                      formattedDate = '${date.month}/${date.year.toString().substring(2)}';
                    }
                    
                    return Text(
                      formattedDate,
                      style: TextStyle(color: Colors.grey, fontSize: 10),
                    );
                  }
                  return Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: null,
                reservedSize: 60,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toStringAsFixed(3),
                    style: TextStyle(color: Colors.grey, fontSize: 10),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: spots.length.toDouble() - 1,
          minY: spots.map((spot) => spot.y).reduce(min) * 0.98, // Fixed: Use min instead of math.min
          maxY: spots.map((spot) => spot.y).reduce(max) * 1.02, // Fixed: Use max instead of math.max
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: chartColor,
              barWidth: 2,
              isStrokeCapRound: true,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: chartColor.withOpacity(0.1),
              ),
            ),
          ],
        lineTouchData: LineTouchData(
  enabled: true,
  touchTooltipData: LineTouchTooltipData(
    // tooltipBgColor: Color(0xFF2A2D36),
    tooltipBorder: BorderSide(color: Colors.transparent),
    tooltipPadding: EdgeInsets.all(8),
    getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
      return touchedBarSpots.map((barSpot) {
        final date = _chartData[barSpot.x.toInt()].date;
        final formattedDate = _selectedPeriod == '1D'
            ? '${date.hour}:${date.minute.toString().padLeft(2, '0')}'
            : '${date.day}/${date.month}/${date.year}';

        return LineTooltipItem(
          '$formattedDate\n${barSpot.y.toStringAsFixed(4)} ${_currentCurrency.code}',
          TextStyle(color: Colors.white, fontSize: 12),
        );
      }).toList();
    },
  ),
),

        ),
      ),
    );
  }

  Widget _buildChartStats() {
    if (_chartData.isEmpty) return SizedBox.shrink();

    final values = _chartData.map((d) => d.value).toList();
    final high = values.reduce(max); // Fixed: Use max instead of math.max
    final low = values.reduce(min);  // Fixed: Use min instead of math.min
    final avg = values.reduce((a, b) => a + b) / values.length;

    return Container(
      padding: EdgeInsets.all(16),
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
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = _currentCurrency;
    final changeColor = c.percentChange >= 0 ? Colors.green : Colors.red;
    final accentColor = c.color ?? Theme.of(context).colorScheme.primary;
    final performance = _calculatePeriodPerformance();
    final isPeriodPositive = performance['percentage']! >= 0;
    final periodChangeColor = isPeriodPositive ? Colors.green : Colors.red;

    return Scaffold(
      backgroundColor: Color(0xFF181A20),
      appBar: AppBar(
        backgroundColor: Color(0xFF181A20),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${c.name} (${c.code})',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _isRealTimeActive ? Colors.green : Colors.orange,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _isRealTimeActive ? 'LIVE' : 'PAUSED',
                    style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  'Updated: ${_lastUpdateTime.toString().substring(11, 19)}',
                  style: TextStyle(color: Colors.grey, fontSize: 10),
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
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Price Card
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color(0xFF1F222A),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
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
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '\$${(c.amount / c.rate).toStringAsFixed(4)}',
                            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${c.amount.toStringAsFixed(4)} ${c.code}',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Exchange Rate:', style: TextStyle(color: Colors.grey)),
                      Text(
                        '1 USD = ${c.ratePerUsd.toStringAsFixed(4)} ${c.code}',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('24h Change:', style: TextStyle(color: Colors.grey)),
                      Row(
                        children: [
                          Icon(
                            c.percentChange >= 0 ? Icons.trending_up : Icons.trending_down,
                            color: changeColor,
                            size: 16,
                          ),
                          SizedBox(width: 4),
                          Text(
                            '${c.percentChange >= 0 ? '+' : ''}${c.percentChange.toStringAsFixed(2)}%',
                            style: TextStyle(color: changeColor, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('$_selectedPeriod Change:', style: TextStyle(color: Colors.grey)),
                      Row(
                        children: [
                          Icon(
                            isPeriodPositive ? Icons.trending_up : Icons.trending_down,
                            color: periodChangeColor,
                            size: 16,
                          ),
                          SizedBox(width: 4),
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

            SizedBox(height: 20),

            // Chart Card
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color(0xFF1F222A),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.show_chart, color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Price Chart',
                            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  _buildTimePeriodSelector(),
                  SizedBox(height: 16),
                  _buildChart(),
                  _buildChartStats(),
                ],
              ),
            ),

            SizedBox(height: 20),

            // Currency Converter
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color(0xFF1F222A),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Convert USD to ${c.code}',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _usdController,
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Amount in USD',
                      labelStyle: TextStyle(color: Colors.grey),
                      prefixText: '\$ ',
                      prefixStyle: TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Color(0xFF2A2D36),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                    ),
                    onChanged: _convertFromUsd,
                  ),
                  SizedBox(height: 16),
                  if (_convertedAmount > 0)
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Color(0xFF2A2D36),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.withOpacity(0.3)),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Converted Amount',
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '${_convertedAmount.toStringAsFixed(2)} ${c.code}',
                            style: TextStyle(
                              color: accentColor,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '${_usdController.text} USD = ${_convertedAmount.toStringAsFixed(2)} ${c.code}',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: Icon(Icons.refresh),
                    label: Text('Buy'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey),
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text('Sell', style: TextStyle(color: Colors.white)),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey),
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text('Swap', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),

            SizedBox(height: 20),

            // Additional Info
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color(0xFF1F222A),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  _buildInfoRow('Market Cap', '\$2.1T'),
                  _buildInfoRow('24h Volume', '\$45.2B'),
                  _buildInfoRow('Circulating Supply', '19.8M ${c.code}'),
                  _buildInfoRow('All Time High', '\$${(c.rate * 1.5).toStringAsFixed(4)}'),
                  if (_chartData.isNotEmpty) ...[
                    _buildInfoRow('52 Week High', _chartData.map((d) => d.value).reduce(max).toStringAsFixed(4)), // Fixed: Use max instead of math.max
                    _buildInfoRow('52 Week Low', _chartData.map((d) => d.value).reduce(min).toStringAsFixed(4)),  // Fixed: Use min instead of math.min
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
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey)),
          Text(value, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}