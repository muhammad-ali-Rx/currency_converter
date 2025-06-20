import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:currency_converter/model/currency.dart';
import 'dart:math';

class StatsScreen extends StatefulWidget {
  final List<Currency> currencies;

  const StatsScreen({super.key, required this.currencies});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String _selectedPeriod = '1M';
  int _selectedChartType = 0; // 0: Line, 1: Bar, 2: Pie

  final List<String> _periods = ['1D', '1W', '1M', '3M', '6M', '1Y'];
  final List<String> _chartTypes = ['Line', 'Bar', 'Pie'];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
          'Market Statistics',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF4ECDC4)),
            onPressed: () {
              _animationController.reset();
              _animationController.forward();
            },
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOverviewCards(),
              const SizedBox(height: 24),
              _buildChartControls(),
              const SizedBox(height: 16),
              _buildMainChart(),
              const SizedBox(height: 24),
              _buildTopPerformers(),
              const SizedBox(height: 24),
              _buildMarketAnalysis(),
              const SizedBox(height: 24),
              _buildVolatilityIndex(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewCards() {
    final totalCurrencies = widget.currencies.length;
    final gainers = widget.currencies.where((c) => c.percentChange > 0).length;
    final losers = widget.currencies.where((c) => c.percentChange < 0).length;
    final avgChange = widget.currencies.isNotEmpty
        ? widget.currencies.map((c) => c.percentChange).reduce((a, b) => a + b) / widget.currencies.length
        : 0.0;

    return Row(
      children: [
        Expanded(child: _buildOverviewCard('Total Currencies', totalCurrencies.toString(), Icons.account_balance_wallet, const Color(0xFF4ECDC4))),
        const SizedBox(width: 12),
        Expanded(child: _buildOverviewCard('Gainers', gainers.toString(), Icons.trending_up, Colors.green)),
        const SizedBox(width: 12),
        Expanded(child: _buildOverviewCard('Losers', losers.toString(), Icons.trending_down, Colors.red)),
        const SizedBox(width: 12),
        Expanded(child: _buildOverviewCard('Avg Change', '${avgChange.toStringAsFixed(2)}%', Icons.analytics, avgChange >= 0 ? Colors.green : Colors.red)),
      ],
    );
  }

  Widget _buildOverviewCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F23),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
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
            title,
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

  Widget _buildChartControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Market Overview',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _periods.length,
                  itemBuilder: (context, index) {
                    final period = _periods[index];
                    final isSelected = _selectedPeriod == period;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedPeriod = period),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF4ECDC4) : const Color(0xFF1A1A2E),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? const Color(0xFF4ECDC4) : const Color(0xFF8A94A6).withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            period,
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
              ),
            ),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A2E),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF8A94A6).withOpacity(0.3)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: _selectedChartType,
                  dropdownColor: const Color(0xFF0F0F23),
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                  items: _chartTypes.asMap().entries.map((entry) {
                    return DropdownMenuItem<int>(
                      value: entry.key,
                      child: Text(entry.value),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _selectedChartType = value!),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMainChart() {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F23),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF1A1A2E)),
      ),
      child: _selectedChartType == 0
          ? _buildLineChart()
          : _selectedChartType == 1
              ? _buildBarChart()
              : _buildPieChart(),
    );
  }

  Widget _buildLineChart() {
    final spots = widget.currencies.take(10).toList().asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.percentChange);
    }).toList();

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) {
            return const FlLine(color: Color(0xFF8A94A6), strokeWidth: 0.5);
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
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < widget.currencies.length) {
                  return Text(
                    widget.currencies[index].code,
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
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toStringAsFixed(1)}%',
                  style: const TextStyle(color: Color(0xFF8A94A6), fontSize: 10),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: const Color(0xFF4ECDC4),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: spot.y >= 0 ? Colors.green : Colors.red,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: const Color(0xFF4ECDC4).withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart() {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: widget.currencies.map((c) => c.percentChange).reduce(max) * 1.2,
        minY: widget.currencies.map((c) => c.percentChange).reduce(min) * 1.2,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < widget.currencies.length && index < 10) {
                  return Text(
                    widget.currencies[index].code,
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
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toStringAsFixed(1)}%',
                  style: const TextStyle(color: Color(0xFF8A94A6), fontSize: 10),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: widget.currencies.take(10).toList().asMap().entries.map((entry) {
          final currency = entry.value;
          final isPositive = currency.percentChange >= 0;
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: currency.percentChange,
                color: isPositive ? Colors.green : Colors.red,
                width: 16,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPieChart() {
    final positiveCount = widget.currencies.where((c) => c.percentChange > 0).length;
    final negativeCount = widget.currencies.where((c) => c.percentChange < 0).length;
    final neutralCount = widget.currencies.where((c) => c.percentChange == 0).length;

    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 60,
        sections: [
          PieChartSectionData(
            color: Colors.green,
            value: positiveCount.toDouble(),
            title: 'Gainers\n$positiveCount',
            radius: 80,
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          PieChartSectionData(
            color: Colors.red,
            value: negativeCount.toDouble(),
            title: 'Losers\n$negativeCount',
            radius: 80,
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          if (neutralCount > 0)
            PieChartSectionData(
              color: const Color(0xFF8A94A6),
              value: neutralCount.toDouble(),
              title: 'Neutral\n$neutralCount',
              radius: 80,
              titleStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTopPerformers() {
    final sortedCurrencies = [...widget.currencies];
    sortedCurrencies.sort((a, b) => b.percentChange.compareTo(a.percentChange));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Top Performers',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0F0F23),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF1A1A2E)),
          ),
          child: Column(
            children: sortedCurrencies.take(5).map((currency) {
              final isPositive = currency.percentChange >= 0;
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: const Color(0xFF1A1A2E).withOpacity(0.5),
                      width: 0.5,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: currency.color,
                      radius: 20,
                      child: Text(
                        currency.code[0],
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currency.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            currency.code,
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
                          '\$${currency.rate.toStringAsFixed(4)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isPositive ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isPositive ? Icons.trending_up : Icons.trending_down,
                                size: 12,
                                color: isPositive ? Colors.green : Colors.red,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${isPositive ? '+' : ''}${currency.percentChange.toStringAsFixed(2)}%',
                                style: TextStyle(
                                  color: isPositive ? Colors.green : Colors.red,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildMarketAnalysis() {
    final totalMarketCap = widget.currencies.length * 1000000000; // Mock data
    final volume24h = widget.currencies.length * 50000000; // Mock data
    final dominance = widget.currencies.isNotEmpty ? (1 / widget.currencies.length * 100) : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Market Analysis',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildAnalysisCard(
                'Market Cap',
                '\$${(totalMarketCap / 1000000000).toStringAsFixed(2)}B',
                Icons.account_balance,
                const Color(0xFF4ECDC4),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildAnalysisCard(
                '24h Volume',
                '\$${(volume24h / 1000000).toStringAsFixed(2)}M',
                Icons.bar_chart,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildAnalysisCard(
                'Dominance',
                '${dominance.toStringAsFixed(2)}%',
                Icons.pie_chart,
                Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAnalysisCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F23),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF8A94A6),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildVolatilityIndex() {
    final volatilityData = widget.currencies.take(7).map((currency) {
      return BarChartGroupData(
        x: widget.currencies.indexOf(currency),
        barRods: [
          BarChartRodData(
            toY: currency.percentChange.abs(),
            color: currency.percentChange >= 0 ? Colors.green : Colors.red,
            width: 20,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Volatility Index',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 200,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF0F0F23),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF1A1A2E)),
          ),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: widget.currencies.map((c) => c.percentChange.abs()).reduce(max) * 1.2,
              barTouchData: BarTouchData(enabled: false),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index >= 0 && index < widget.currencies.length && index < 7) {
                        return Text(
                          widget.currencies[index].code,
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
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        '${value.toStringAsFixed(1)}%',
                        style: const TextStyle(color: Color(0xFF8A94A6), fontSize: 10),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              barGroups: volatilityData,
            ),
          ),
        ),
      ],
    );
  }
}