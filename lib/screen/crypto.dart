import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class Crypto {
  final String name;
  final String symbol;
  final double currentPrice;
  final double priceChangePercentage24h;
  final String image;
  final int marketCapRank;
  final double marketCap;
  final double totalVolume;
  final List<double> sparklineData;

  Crypto({
    required this.name,
    required this.symbol,
    required this.currentPrice,
    required this.priceChangePercentage24h,
    required this.image,
    required this.marketCapRank,
    required this.marketCap,
    required this.totalVolume,
    required this.sparklineData,
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crypto Wallet',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Color(0xFF0A0E21),
        cardColor: Color(0xFF1D1E33),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF0A0E21),
        ),
      ),
      home: CryptoWalletScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}


class CryptoWalletScreen extends StatefulWidget {
  const CryptoWalletScreen({super.key});

  @override
  _CryptoWalletScreenState createState() => _CryptoWalletScreenState();
}

class _CryptoWalletScreenState extends State<CryptoWalletScreen> {
  int _currentIndex = 0;
  final List<Crypto> cryptoList = [
    Crypto(
      name: 'Bitcoin',
      symbol: 'BTC',
      currentPrice: 50000,
      priceChangePercentage24h: 0.60,
      image: '',
      marketCapRank: 1,
      marketCap: 950000000000,
      totalVolume: 30000000000,
      sparklineData: List.generate(24, (i) => 48000 + Random().nextDouble() * 4000),
    ),
    Crypto(
      name: 'Ethereum',
      symbol: 'ETH',
      currentPrice: 3000,
      priceChangePercentage24h: -0.70,
      image: '',
      marketCapRank: 2,
      marketCap: 350000000000,
      totalVolume: 20000000000,
      sparklineData: List.generate(24, (i) => 2800 + Random().nextDouble() * 400),
    ),
    Crypto(
      name: 'Tether',
      symbol: 'USDT',
      currentPrice: 1.00,
      priceChangePercentage24h: 0.01,
      image: '',
      marketCapRank: 3,
      marketCap: 80000000000,
      totalVolume: 50000000000,
      sparklineData: List.generate(24, (i) => 1.0),
    ),
    Crypto(
      name: 'XRP',
      symbol: 'XRP',
      currentPrice: 0.50,
      priceChangePercentage24h: 0.47,
      image: '',
      marketCapRank: 4,
      marketCap: 25000000000,
      totalVolume: 2000000000,
      sparklineData: List.generate(24, (i) => 0.45 + Random().nextDouble() * 0.1),
    ),
    Crypto(
      name: 'BNB',
      symbol: 'BNB',
      currentPrice: 400,
      priceChangePercentage24h: 2.54,
      image: '',
      marketCapRank: 5,
      marketCap: 60000000000,
      totalVolume: 1500000000,
      sparklineData: List.generate(24, (i) => 380 + Random().nextDouble() * 40),
    ),
  ];

Widget _buildChart(Crypto crypto) {
  final isPositive = crypto.priceChangePercentage24h >= 0;
  final lineColor = isPositive ? Colors.greenAccent : Colors.redAccent;

  return SizedBox(
    width: 90,
    height: 40,
    child: LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineTouchData: LineTouchData(enabled: false),
        minX: 0,
        maxX: crypto.sparklineData.length.toDouble() - 1,
        minY: crypto.sparklineData.reduce((a, b) => a < b ? a : b) * 0.997,
        maxY: crypto.sparklineData.reduce((a, b) => a > b ? a : b) * 1.003,
        lineBarsData: [
          LineChartBarData(
            spots: crypto.sparklineData
                .asMap()
                .entries
                .map((entry) => FlSpot(entry.key.toDouble(), entry.value))
                .toList(),
            isCurved: true,
            curveSmoothness: 0.3,
            color: lineColor,
            barWidth: 2.5,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(show: false),
          ),
        ],
      ),
    ),
  );
}




  Widget _buildCryptoItem(Crypto crypto) {
    final isPositive = crypto.priceChangePercentage24h >= 0;
    final color = isPositive ? Colors.green : Colors.red;
    final icon = isPositive ? Icons.trending_up : Icons.trending_down;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF1D1E33),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Left side - Name and Symbol
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  crypto.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  crypto.symbol,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            flex: 4,
            child: _buildChart(crypto),
          ),
          
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${crypto.currentPrice.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(icon, size: 16, color: color),
                    SizedBox(width: 4),
                    Text(
                      '${isPositive ? '+' : ''}${crypto.priceChangePercentage24h.toStringAsFixed(2)}%',
                      style: TextStyle(
                        fontSize: 14,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalBalanceCard() {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFF1D1E33),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Balance',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '\$10,789.12',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Unlock 100 USD welcome rewards!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCryptoList() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Crypto',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              Text(
                'Stock',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        Divider(height: 1, color: Colors.grey.withOpacity(0.3)),
        Expanded(
          child: ListView.builder(
            itemCount: cryptoList.length,
            itemBuilder: (context, index) {
              return _buildCryptoItem(cryptoList[index]);
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crypto Wallet'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildTotalBalanceCard(),
          Expanded(child: _buildCryptoList()),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up),
            label: 'Trade',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Wallet',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Account',
          ),
        ],
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        backgroundColor: Color(0xFF1D1E33),
      ),
    );
  }
}