import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:currency_converter/model/currency.dart';
import 'dart:math';
import 'dart:async';

class CurrencyConverterScreen extends StatefulWidget {
  final Currency? fromCurrency;
  final List<Currency> availableCurrencies;

  const CurrencyConverterScreen({
    super.key,
    this.fromCurrency,
    required this.availableCurrencies,
  });

  @override
  State<CurrencyConverterScreen> createState() =>
      _CurrencyConverterScreenState();
}

class _CurrencyConverterScreenState extends State<CurrencyConverterScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();

  late Currency _fromCurrency;
  late Currency _toCurrency;

  Timer? _realTimeTimer;
  bool _isRealTimeActive = true;
  DateTime _lastUpdateTime = DateTime.now();

  List<FlSpot> _comparisonChartData = [];
  String _selectedChartPeriod = '1D';

  final List<String> _chartPeriods = ['1H', '1D', '1W', '1M'];

  @override
  void initState() {
    super.initState();

    // Initialize currencies
    _fromCurrency = widget.fromCurrency ?? widget.availableCurrencies.first;
    _toCurrency = widget.availableCurrencies.firstWhere(
      (c) => c.code != _fromCurrency.code,
      orElse: () => widget.availableCurrencies.last,
    );

    // Initialize animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _generateComparisonChart();
    _startRealTimeUpdates();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _realTimeTimer?.cancel();
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  void _startRealTimeUpdates() {
    _realTimeTimer?.cancel();
    _realTimeTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_isRealTimeActive && mounted) {
        _updateRatesRealTime();
      }
    });
  }

  void _updateRatesRealTime() {
    setState(() {
      final random = Random();

      // Update from currency
      final fromFluctuation = (random.nextDouble() - 0.5) * 0.02;
      _fromCurrency = Currency(
        code: _fromCurrency.code,
        name: _fromCurrency.name,
        rate: _fromCurrency.rate * (1 + fromFluctuation),
        amount: _fromCurrency.amount * (1 + fromFluctuation),
        percentChange:
            _fromCurrency.percentChange + (random.nextDouble() - 0.5) * 0.2,
        ratePerUsd: _fromCurrency.ratePerUsd * (1 + fromFluctuation),
        color: _fromCurrency.color,
      );

      // Update to currency
      final toFluctuation = (random.nextDouble() - 0.5) * 0.02;
      _toCurrency = Currency(
        code: _toCurrency.code,
        name: _toCurrency.name,
        rate: _toCurrency.rate * (1 + toFluctuation),
        amount: _toCurrency.amount * (1 + toFluctuation),
        percentChange:
            _toCurrency.percentChange + (random.nextDouble() - 0.5) * 0.2,
        ratePerUsd: _toCurrency.ratePerUsd * (1 + toFluctuation),
        color: _toCurrency.color,
      );

      _lastUpdateTime = DateTime.now();

      // Update chart data
      if (_comparisonChartData.isNotEmpty) {
        final lastPoint = _comparisonChartData.last;
        final newRate = _fromCurrency.ratePerUsd / _toCurrency.ratePerUsd;
        final newY = lastPoint.y * (1 + (fromFluctuation - toFluctuation));

        if (_comparisonChartData.length > 50) {
          _comparisonChartData.removeAt(0);
          // Adjust x values
          for (int i = 0; i < _comparisonChartData.length; i++) {
            _comparisonChartData[i] = FlSpot(
              i.toDouble(),
              _comparisonChartData[i].y,
            );
          }
        }

        _comparisonChartData.add(
          FlSpot(_comparisonChartData.length.toDouble(), newY),
        );
      }
    });

    // Auto-convert if there's input
    if (_fromController.text.isNotEmpty) {
      _convertCurrency(_fromController.text, true);
    }
  }

  void _generateComparisonChart() {
    final random = Random();
    _comparisonChartData.clear();

    final baseRate = _fromCurrency.ratePerUsd / _toCurrency.ratePerUsd;
    double currentRate = baseRate;

    final dataPoints =
        _selectedChartPeriod == '1H'
            ? 60
            : _selectedChartPeriod == '1D'
            ? 24
            : _selectedChartPeriod == '1W'
            ? 7
            : 30;

    for (int i = 0; i < dataPoints; i++) {
      final fluctuation = (random.nextDouble() - 0.5) * 0.05;
      currentRate = currentRate * (1 + fluctuation);
      _comparisonChartData.add(FlSpot(i.toDouble(), currentRate));
    }
  }

  void _convertCurrency(String input, bool fromToTo) {
    final amount = double.tryParse(input);
    if (amount != null && amount > 0) {
      if (fromToTo) {
        // Convert from -> to
        final usdAmount = amount / _fromCurrency.ratePerUsd;
        final convertedAmount = usdAmount * _toCurrency.ratePerUsd;
        _toController.text = convertedAmount.toStringAsFixed(4);
      } else {
        // Convert to -> from
        final usdAmount = amount / _toCurrency.ratePerUsd;
        final convertedAmount = usdAmount * _fromCurrency.ratePerUsd;
        _fromController.text = convertedAmount.toStringAsFixed(4);
      }
    } else {
      if (fromToTo) {
        _toController.clear();
      } else {
        _fromController.clear();
      }
    }
  }

  void _swapCurrencies() {
    setState(() {
      final temp = _fromCurrency;
      _fromCurrency = _toCurrency;
      _toCurrency = temp;

      final tempText = _fromController.text;
      _fromController.text = _toController.text;
      _toController.text = tempText;
    });

    _generateComparisonChart();

    // Trigger swap animation
    _animationController.reset();
    _animationController.forward();
  }

  void _selectCurrency(bool isFromCurrency) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (context) => Container(
            height: MediaQuery.of(context).size.height * 0.7,
            decoration: const BoxDecoration(
              color: Color(0xFF0F0F23),
              borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            ),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFF8A94A6),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'Select ${isFromCurrency ? 'From' : 'To'} Currency',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: widget.availableCurrencies.length,
                    itemBuilder: (context, index) {
                      final currency = widget.availableCurrencies[index];
                      final isSelected =
                          isFromCurrency
                              ? currency.code == _fromCurrency.code
                              : currency.code == _toCurrency.code;

                      return Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? const Color(0xFF4ECDC4).withOpacity(0.2)
                                  : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                isSelected
                                    ? const Color(0xFF4ECDC4)
                                    : Colors.transparent,
                          ),
                        ),
                        child: ListTile(
                          leading: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: currency.color?.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                color: currency.color ?? Colors.grey,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                currency.code[0],
                                style: TextStyle(
                                  color: currency.color,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                          title: Text(
                            currency.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Row(
                            children: [
                              Text(
                                currency.code,
                                style: const TextStyle(
                                  color: Color(0xFF8A94A6),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      currency.percentChange >= 0
                                          ? Colors.green.withOpacity(0.2)
                                          : Colors.red.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '${currency.percentChange >= 0 ? '+' : ''}${currency.percentChange.toStringAsFixed(2)}%',
                                  style: TextStyle(
                                    color:
                                        currency.percentChange >= 0
                                            ? Colors.green
                                            : Colors.red,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          trailing:
                              isSelected
                                  ? const Icon(
                                    Icons.check_circle,
                                    color: Color(0xFF4ECDC4),
                                  )
                                  : null,
                          onTap: () {
                            setState(() {
                              if (isFromCurrency) {
                                _fromCurrency = currency;
                              } else {
                                _toCurrency = currency;
                              }
                            });
                            Navigator.pop(context);
                            _generateComparisonChart();

                            // Re-convert if there's input
                            if (_fromController.text.isNotEmpty) {
                              _convertCurrency(_fromController.text, true);
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A1A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Currency Converter',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color:
                  _isRealTimeActive
                      ? Colors.green.withOpacity(0.2)
                      : Colors.orange.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _isRealTimeActive ? Colors.green : Colors.orange,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isRealTimeActive
                      ? Icons.radio_button_checked
                      : Icons.pause_circle_outline,
                  color: _isRealTimeActive ? Colors.green : Colors.orange,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  _isRealTimeActive ? 'LIVE' : 'PAUSED',
                  style: TextStyle(
                    color: _isRealTimeActive ? Colors.green : Colors.orange,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _slideAnimation.value),
            child: Opacity(
              opacity: _fadeAnimation.value,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Exchange Rate Header
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF4ECDC4).withOpacity(0.1),
                            const Color(0xFF44A08D).withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF4ECDC4).withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '1 ${_fromCurrency.code}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Icon(
                                Icons.trending_up,
                                color: Color(0xFF4ECDC4),
                              ),
                              Text(
                                '${(_fromCurrency.ratePerUsd / _toCurrency.ratePerUsd).toStringAsFixed(4)} ${_toCurrency.code}',
                                style: const TextStyle(
                                  color: Color(0xFF4ECDC4),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Updated: ${_lastUpdateTime.toString().substring(11, 19)}',
                            style: const TextStyle(
                              color: Color(0xFF8A94A6),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Converter Section
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F0F23),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF1A1A2E)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // From Currency
                          _buildCurrencyInput(
                            currency: _fromCurrency,
                            controller: _fromController,
                            label: 'From',
                            onTap: () => _selectCurrency(true),
                            onChanged: (value) => _convertCurrency(value, true),
                          ),

                          const SizedBox(height: 20),

                          // Swap Button
                          GestureDetector(
                            onTap: _swapCurrencies,
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: const Color(0xFF4ECDC4),
                                borderRadius: BorderRadius.circular(25),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF4ECDC4,
                                    ).withOpacity(0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.swap_vert,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // To Currency
                          _buildCurrencyInput(
                            currency: _toCurrency,
                            controller: _toController,
                            label: 'To',
                            onTap: () => _selectCurrency(false),
                            onChanged:
                                (value) => _convertCurrency(value, false),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Chart Section
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F0F23),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF1A1A2E)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${_fromCurrency.code}/${_toCurrency.code} Chart',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                children:
                                    _chartPeriods.map((period) {
                                      final isSelected =
                                          _selectedChartPeriod == period;
                                      return GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _selectedChartPeriod = period;
                                          });
                                          _generateComparisonChart();
                                        },
                                        child: Container(
                                          margin: const EdgeInsets.only(
                                            left: 8,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                isSelected
                                                    ? const Color(0xFF4ECDC4)
                                                    : Colors.transparent,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            border: Border.all(
                                              color:
                                                  isSelected
                                                      ? const Color(0xFF4ECDC4)
                                                      : const Color(0xFF8A94A6),
                                            ),
                                          ),
                                          child: Text(
                                            period,
                                            style: TextStyle(
                                              color:
                                                  isSelected
                                                      ? Colors.white
                                                      : const Color(0xFF8A94A6),
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            height: 200,
                            child:
                                _comparisonChartData.isNotEmpty
                                    ? LineChart(
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
                                        titlesData: const FlTitlesData(
                                          show: false,
                                        ),
                                        borderData: FlBorderData(show: false),
                                        lineBarsData: [
                                          LineChartBarData(
                                            spots: _comparisonChartData,
                                            isCurved: true,
                                            color: const Color(0xFF4ECDC4),
                                            barWidth: 3,
                                            isStrokeCapRound: true,
                                            dotData: const FlDotData(
                                              show: false,
                                            ),
                                            belowBarData: BarAreaData(
                                              show: true,
                                              color: const Color(
                                                0xFF4ECDC4,
                                              ).withOpacity(0.1),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                    : const Center(
                                      child: CircularProgressIndicator(
                                        color: Color(0xFF4ECDC4),
                                      ),
                                    ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Quick Actions
                    Row(
                      children: [
                        Expanded(
                          child: _buildQuickActionButton(
                            'Reset',
                            Icons.refresh,
                            () {
                              _fromController.clear();
                              _toController.clear();
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildQuickActionButton(
                            _isRealTimeActive ? 'Pause' : 'Resume',
                            _isRealTimeActive ? Icons.pause : Icons.play_arrow,
                            () {
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
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCurrencyInput({
    required Currency currency,
    required TextEditingController controller,
    required String label,
    required VoidCallback onTap,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF8A94A6),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            GestureDetector(
              onTap: onTap,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A2E),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF8A94A6).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      backgroundColor: currency.color,
                      radius: 16,
                      child: Text(
                        currency.code[0],
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currency.code,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          currency.name.length > 10
                              ? '${currency.name.substring(0, 10)}...'
                              : currency.name,
                          style: const TextStyle(
                            color: Color(0xFF8A94A6),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.keyboard_arrow_down,
                      color: Color(0xFF8A94A6),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  hintText: '0.00',
                  hintStyle: const TextStyle(color: Color(0xFF8A94A6)),
                  filled: true,
                  fillColor: const Color(0xFF1A1A2E),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                onChanged: onChanged,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionButton(
    String text,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white, size: 18),
      label: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1A1A2E),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: const BorderSide(color: Color(0xFF8A94A6), width: 0.5),
      ),
    );
  }
}
