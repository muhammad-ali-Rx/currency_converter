import 'dart:math';
import 'dart:convert';
import 'dart:async';
import 'package:currency_converter/model/currency.dart';
import 'package:currency_converter/screen/CurrencyDetailPage.dart';
import 'package:currency_converter/widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';

class Crypto {
  final String id;
  final String symbol;
  final String name;
  final String image;
  final double priceUsd;
  final double percentChange24h;
  final double marketCap;
  final double totalVolume;

  Crypto({
    required this.id,
    required this.symbol,
    required this.name,
    required this.image,
    required this.priceUsd,
    required this.percentChange24h,
    required this.marketCap,
    required this.totalVolume,
  });

  factory Crypto.fromJson(Map<String, dynamic> json) {
    return Crypto(
      id: json['id'] ?? '',
      symbol: json['symbol'] ?? '',
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      priceUsd: (json['current_price'] ?? 0).toDouble(),
      percentChange24h: (json['price_change_percentage_24h'] ?? 0).toDouble(),
      marketCap: (json['market_cap'] ?? 0).toDouble(),
      totalVolume: (json['total_volume'] ?? 0).toDouble(),
    );
  }
}

class Mainscreen extends StatelessWidget {
  const Mainscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: WalletScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final List<Currency> currencies = [];
  final List<Currency> filteredCurrencies = [];
  bool isLoading = true;

  Timer? _realTimeTimer;
  DateTime _lastUpdateTime = DateTime.now();
  bool _isRealTimeActive = true;

  // Search functionality
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final bool _isSearchActive = false;

  String selectedSort = 'world Currency';
  String itemLabel = 'Currency';

  List<String> sortingOptions = ['world Currency', 'crypto',];
  List<Crypto> cryptoList = [];
  List<Crypto> filteredCryptoList = [];

  bool isCryptoLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchCurrencyData();
    _searchController.addListener(_onSearchChanged);
    _startRealTimeUpdates(); 
  }

  @override
  void dispose() {
    _realTimeTimer?.cancel(); // Cancel timer
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  // Start real-time updates
  void _startRealTimeUpdates() {
    _realTimeTimer?.cancel();
    _realTimeTimer = Timer.periodic(Duration(seconds: 2), (timer) {
      if (_isRealTimeActive) {
        _updateRatesRealTime();
      }
    });
  }

  // Real-time rate update function
  void _updateRatesRealTime() {
    if (!mounted) return;
    
    setState(() {
      _lastUpdateTime = DateTime.now();
      
      // Update currencies with realistic fluctuations
      for (int i = 0; i < currencies.length; i++) {
        final random = Random();
        
        // Small realistic fluctuation (±0.1% to ±0.5%)
        final fluctuationPercent = (random.nextDouble() - 0.5) * 0.01;
        final newRate = currencies[i].rate * (1 + fluctuationPercent);
        final newAmount = currencies[i].amount * (1 + fluctuationPercent);
        
        // Update percentage change
        final percentChange = currencies[i].percentChange + (random.nextDouble() - 0.5) * 0.1;
        
        currencies[i] = Currency(
          code: currencies[i].code,
          name: currencies[i].name,
          rate: newRate,
          amount: newAmount,
          percentChange: percentChange,
          ratePerUsd: newRate,
          color: currencies[i].color,
        );
      }
      
      // Update crypto prices
      for (int i = 0; i < cryptoList.length; i++) {
        final random = Random();
        
        // Crypto has higher volatility (±0.5% to ±2%)
        final fluctuationPercent = (random.nextDouble() - 0.5) * 0.04;
        final newPrice = cryptoList[i].priceUsd * (1 + fluctuationPercent);
        final newPercentChange = cryptoList[i].percentChange24h + (random.nextDouble() - 0.5) * 0.5;
        
        cryptoList[i] = Crypto(
          id: cryptoList[i].id,
          symbol: cryptoList[i].symbol,
          name: cryptoList[i].name,
          image: cryptoList[i].image,
          priceUsd: newPrice,
          percentChange24h: newPercentChange,
          marketCap: cryptoList[i].marketCap,
          totalVolume: cryptoList[i].totalVolume,
        );
      }
      
      // Refresh filtered data
      _filterData();
    });
  }

  // Toggle real-time updates
  void _toggleRealTimeUpdates() {
    setState(() {
      _isRealTimeActive = !_isRealTimeActive;
      if (_isRealTimeActive) {
        _startRealTimeUpdates();
      } else {
        _realTimeTimer?.cancel();
      }
    });
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
      _filterData();
    });
  }

  void _filterData() {
    if (selectedSort == 'crypto') {
      _filterCryptos();
    } else {
      _filterCurrencies();
    }
  }

  void _filterCurrencies() {
    filteredCurrencies.clear();
    if (_searchQuery.isEmpty) {
      filteredCurrencies.addAll(currencies);
    } else {
      filteredCurrencies.addAll(
        currencies.where(
          (currency) =>
              currency.name.toLowerCase().contains(_searchQuery) ||
              currency.code.toLowerCase().contains(_searchQuery),
        ),
      );
    }
  }

  void _filterCryptos() {
    filteredCryptoList.clear();
    if (_searchQuery.isEmpty) {
      filteredCryptoList.addAll(cryptoList);
    } else {
      filteredCryptoList.addAll(
        cryptoList.where(
          (crypto) =>
              crypto.name.toLowerCase().contains(_searchQuery) ||
              crypto.symbol.toLowerCase().contains(_searchQuery) ||
              crypto.id.toLowerCase().contains(_searchQuery),
        ),
      );
    }
  }

  Future<void> _fetchCurrencyData() async {
    const apiUrl = 'https://v6.exchangerate-api.com/v6/f23f645526cd179f30906490/latest/USD';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        if (jsonResponse['result'] == 'success') {
          final rates = jsonResponse['conversion_rates'] as Map<String, dynamic>;

          final List<Map<String, String>> currencyData = [
            {'code': 'USD', 'name': 'US Dollar'},
            {'code': 'EUR', 'name': 'Euro'},
            {'code': 'GBP', 'name': 'British Pound'},
            {'code': 'JPY', 'name': 'Japanese Yen'},
            {'code': 'CAD', 'name': 'Canadian Dollar'},
            {'code': 'TRY', 'name': 'Turkish Lira'},
            {'code': 'SEK', 'name': 'Swedish Krona'},
            {'code': 'PLN', 'name': 'Polish Zloty'},
            {'code': 'IDR', 'name': 'Indonesian Rupiah'},
            {'code': 'VND', 'name': 'Vietnamese Dong'},
            {'code': 'PKR', 'name': 'Pakistani Rupee'},
            {'code': 'INR', 'name': 'Indian Rupee'},
            {'code': 'AUD', 'name': 'Australian Dollar'},
            {'code': 'CHF', 'name': 'Swiss Franc'},
            {'code': 'CNY', 'name': 'Chinese Yuan'},
            {'code': 'KRW', 'name': 'South Korean Won'},
            {'code': 'SGD', 'name': 'Singapore Dollar'},
            {'code': 'HKD', 'name': 'Hong Kong Dollar'},
            {'code': 'NOK', 'name': 'Norwegian Krone'},
            {'code': 'MXN', 'name': 'Mexican Peso'},
          ];

          final List<Color> colors = [
            Colors.blue, Colors.purple, Colors.orange, Colors.green,
            Colors.red, Colors.teal, Colors.indigo, Colors.pink,
            Colors.amber, Colors.cyan, Colors.deepOrange, Colors.lightGreen,
            Colors.deepPurple, Colors.brown, Colors.blueGrey,
          ];

          final random = Random();
          currencies.clear();

          for (var data in currencyData) {
            final code = data['code']!;
            final rate = rates[code] != null ? (rates[code] as num).toDouble() : 1.0;
            final amount = 1 * rate;
            final percentChange = (random.nextDouble() * 1 * (random.nextBool() ? 1 : -1));
            final color = colors[random.nextInt(colors.length)];

            currencies.add(
              Currency(
                code: code,
                name: data['name']!,
                rate: rate,
                amount: amount,
                percentChange: percentChange,
                ratePerUsd: rate,
                color: color,
              ),
            );
          }
          currencies.sort((a, b) => b.percentChange.compareTo(a.percentChange));
          filteredCurrencies.addAll(currencies);
        }
      }
    } catch (e) {
      print('Error fetching currency data: $e');
      _addMockCurrencyData();
    }

    setState(() {
      isLoading = false;
    });
  }

  void _addMockCurrencyData() {
    final random = Random();
    final List<Map<String, String>> currencyData = [
      {'code': 'USD', 'name': 'US Dollar'},
      {'code': 'EUR', 'name': 'Euro'},
      {'code': 'GBP', 'name': 'British Pound'},
      {'code': 'JPY', 'name': 'Japanese Yen'},
    ];

    final List<Color> colors = [Colors.blue, Colors.purple, Colors.orange, Colors.green];
    currencies.clear();

    for (var data in currencyData) {
      final amount = 1.0;
      final percentChange = (random.nextDouble() * 1 * (random.nextBool() ? 1 : -1));
      final color = colors[random.nextInt(colors.length)];

      currencies.add(
        Currency(
          code: data['code']!,
          name: data['name']!,
          rate: 1.0,
          amount: amount,
          percentChange: percentChange,
          ratePerUsd: 1.0,
          color: color,
        ),
      );
    }
    filteredCurrencies.addAll(currencies);
  }

  Widget _buildTotalBalanceCard() {
    // Calculate total balance dynamically
    double totalBalance = 0.0;
    
    if (selectedSort == 'crypto') {
      totalBalance = filteredCryptoList.fold(0.0, (sum, crypto) => sum + crypto.priceUsd);
    } else {
      totalBalance = filteredCurrencies.fold(0.0, (sum, currency) => sum + (currency.amount / currency.rate));
    }

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [const Color(0xFF3C4858), const Color(0xFF2D3A4B)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Total Balance',
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                      ),
                      SizedBox(width: 8),
                      // Live indicator
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _isRealTimeActive ? Colors.green : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          _isRealTimeActive ? 'LIVE' : 'PAUSED',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Animated balance
                  AnimatedDefaultTextStyle(
                    duration: Duration(milliseconds: 500),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                    ),
                    child: Text('\$${totalBalance.toStringAsFixed(2)}'),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Last updated: ${_lastUpdateTime.toString().substring(11, 19)}',
                    style: const TextStyle(color: Colors.white54, fontSize: 14),
                  ),
                ],
              ),
              // Animated wallet icon
              AnimatedContainer(
                duration: Duration(milliseconds: 500),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Icon(
                  Icons.account_balance_wallet,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: () => print('Transfer pressed'),
                icon: const Icon(Icons.send),
                label: const Text('Transfer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => print('Deposit pressed'),
                icon: const Icon(Icons.account_balance),
                label: const Text('Deposit'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => print('Convert pressed'),
                icon: const Icon(Icons.swap_horiz),
                label: const Text('Convert'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Color(0xFF1F222A),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: selectedSort == 'crypto' ? 'Search cryptocurrencies...' : 'Search currencies...',
          hintStyle: TextStyle(color: Colors.white54),
          prefixIcon: Icon(Icons.search, color: Colors.white54),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: Colors.white54),
                  onPressed: () => _searchController.clear(),
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
      ),
    );
  }

  Widget _buildSearchResultsHeader() {
    if (_searchQuery.isEmpty) return SizedBox.shrink();

    int resultCount = selectedSort == 'crypto' ? filteredCryptoList.length : filteredCurrencies.length;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color(0xFF1F222A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            margin: EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.blue.withOpacity(0.5), width: 1),
            ),
            child: Icon(Icons.search_rounded, color: Colors.blue[300], size: 22),
          ),
          Expanded(
            child: Text(
              'Found $resultCount result${resultCount != 1 ? 's' : ''} for "$_searchQuery"',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ),
          if (_searchQuery.isNotEmpty)
            GestureDetector(
              onTap: () => _searchController.clear(),
              child: Container(
                padding: EdgeInsets.all(8),
                margin: EdgeInsets.only(left: 8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.withOpacity(0.5), width: 1),
                ),
                child: Icon(Icons.close_rounded, color: Colors.blue[300], size: 18),
              ),
            ),
        ],
      ),
    );
  }

  Future<List<Crypto>> _fetchCryptos() async {
    try {
      const apiUrl = 'https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=100&page=1&sparkline=false';
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => Crypto.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load crypto data');
      }
    } catch (e) {
      print('Error fetching crypto data: $e');
      return _getMockCryptoData();
    }
  }

  List<Crypto> _getMockCryptoData() {
    final random = Random();
    return [
      Crypto(
        id: 'bitcoin', symbol: 'btc', name: 'Bitcoin', image: '',
        priceUsd: 64000 + random.nextDouble() * 2000,
        percentChange24h: 1.5 + random.nextDouble() * 2,
        marketCap: 1200000000000, totalVolume: 25000000000,
      ),
      Crypto(
        id: 'ethereum', symbol: 'eth', name: 'Ethereum', image: '',
        priceUsd: 3500 + random.nextDouble() * 200,
        percentChange24h: -0.8 + random.nextDouble() * 1.6,
        marketCap: 420000000000, totalVolume: 15000000000,
      ),
      Crypto(
        id: 'solana', symbol: 'sol', name: 'Solana', image: '',
        priceUsd: 150 + random.nextDouble() * 20,
        percentChange24h: 2.1 + random.nextDouble() * 2,
        marketCap: 65000000000, totalVolume: 2500000000,
      ),
    ];
  }

  void _sortCurrencies(String criteria) async {
    setState(() {
      selectedSort = criteria;
      isCryptoLoading = criteria == 'crypto';
      _searchController.clear();
      _searchQuery = '';
    });

    if (criteria == 'crypto') {
      final fetched = await _fetchCryptos();
      setState(() {
        cryptoList = fetched;
        filteredCryptoList.clear();
        filteredCryptoList.addAll(fetched);
        isCryptoLoading = false;
        itemLabel = 'Crypto';
      });
    } else {
      setState(() {
        cryptoList = [];
        filteredCryptoList = [];
        isCryptoLoading = false;
        itemLabel = criteria == 'stock' ? 'Stock' : 'Currency';
        _filterCurrencies();
      });
    }
  }

  Widget _buildSortingHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Sort by $itemLabel',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18, color: Colors.white),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Color(0xFF1F222A),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.withOpacity(0.5)),
          ),
          child: DropdownButton<String>(
            value: selectedSort,
            underline: SizedBox(),
            dropdownColor: Color(0xFF1F222A),
            icon: Icon(Icons.arrow_drop_down, color: Colors.white),
            style: TextStyle(color: Colors.white, fontSize: 16),
            items: sortingOptions.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value, style: TextStyle(color: Colors.white)),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) _sortCurrencies(newValue);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildChart(currency) {
    final random = Random();
    final bool isPositive = currency.percentChange >= 0;
    final Color chartColor = isPositive ? Colors.green : Colors.red;

    final List<FlSpot> spots = [];
    double baseRate = currency.rate;
    
    for (int i = 0; i < 24; i++) {
      if (i == 0) {
        spots.add(FlSpot(i.toDouble(), baseRate));
      } else {
        double fluctuation = (random.nextDouble() - 0.5) * 0.01;
        double newRate = spots[i - 1].y * (1 + fluctuation);
        spots.add(FlSpot(i.toDouble(), newRate));
      }
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: chartColor.withOpacity(0.3)),
      ),
      child: SizedBox(
        height: 50,
        width: 80,
        child: LineChart(
          LineChartData(
            gridData: FlGridData(show: false),
            titlesData: FlTitlesData(show: false),
            borderData: FlBorderData(show: false),
            minY: spots.map((s) => s.y).reduce(min) * 0.98,
            maxY: spots.map((s) => s.y).reduce(max) * 1.02,
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                color: chartColor,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) {
                    if (index == spots.length - 1) {
                      return FlDotCirclePainter(
                        radius: 3,
                        color: chartColor,
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      );
                    }
                    return FlDotCirclePainter(radius: 0, color: Colors.transparent);
                  },
                ),
                belowBarData: BarAreaData(show: true, color: chartColor.withOpacity(0.1)),
                isStrokeCapRound: true,
                barWidth: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCryptoChart(Crypto crypto) {
    final random = Random();
    final List<FlSpot> spots = List.generate(
      24,
      (index) => FlSpot(
        index.toDouble(),
        crypto.priceUsd + random.nextDouble() * crypto.priceUsd * 0.05,
      ),
    );

    final Color chartColor = crypto.percentChange24h >= 0 ? Colors.green : Colors.red;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: chartColor.withOpacity(0.3)),
      ),
      child: SizedBox(
        height: 50,
        width: 80,
        child: LineChart(
          LineChartData(
            gridData: FlGridData(show: false),
            titlesData: FlTitlesData(show: false),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                color: chartColor,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) {
                    if (index == spots.length - 1) {
                      return FlDotCirclePainter(
                        radius: 3,
                        color: chartColor,
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      );
                    }
                    return FlDotCirclePainter(radius: 0, color: Colors.transparent);
                  },
                ),
                belowBarData: BarAreaData(show: true, color: chartColor.withOpacity(0.1)),
                isStrokeCapRound: true,
                barWidth: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrencyItem( currency) {
  final isPositive = currency.percentChange >= 0;

  return GestureDetector(
    onTap: () {
      // Yahan navigate karein coin ke detail page pe
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CurrencyDetailPage(currency: currency),
        ),
      );
    },
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1F222A),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isPositive ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedContainer(
            duration: Duration(milliseconds: 500),
            child: CircleAvatar(
              backgroundColor: currency.color,
              child: Text(
                currency.code[0],
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
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
                      currency.name,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                    const SizedBox(width: 8),
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
                  ],
                ),
                const SizedBox(height: 4),
                AnimatedDefaultTextStyle(
                  duration: Duration(milliseconds: 300),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: isPositive ? Colors.green : Colors.red,
                  ),
                  child: Text('${currency.amount.toStringAsFixed(4)} ${currency.code}'),
                ),
                const SizedBox(height: 4),
                Text(
                  '1 USD = ${currency.rate.toStringAsFixed(4)} ${currency.code}',
                  style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
                ),
                Text(
                  'Updated: ${_lastUpdateTime.toString().substring(11, 19)}',
                  style: TextStyle(color: Colors.green.withOpacity(0.8), fontSize: 10),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AnimatedDefaultTextStyle(
                duration: Duration(milliseconds: 300),
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: isPositive ? Colors.green : Colors.red,
                ),
                child: Text('\$${(currency.amount / currency.rate).toStringAsFixed(4)}'),
              ),
              const SizedBox(height: 4),
              AnimatedContainer(
                duration: Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isPositive ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: isPositive ? Colors.green : Colors.red, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPositive ? Icons.trending_up : Icons.trending_down,
                      size: 12,
                      color: isPositive ? Colors.green : Colors.red,
                    ),
                    SizedBox(width: 2),
                    Text(
                      '${isPositive ? '+' : ''}${currency.percentChange.toStringAsFixed(2)}%',
                      style: TextStyle(
                        color: isPositive ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              _buildChart(currency),
            ],
          ),
        ],
      ),
    ),
  );
}


  Widget _buildCryptoItem(Crypto crypto) {
    final isPositive = crypto.percentChange24h >= 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1F222A),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isPositive ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedContainer(
            duration: Duration(milliseconds: 500),
            child: CircleAvatar(
              backgroundColor: isPositive ? Colors.green : Colors.red,
              child: Text(
                crypto.symbol.toUpperCase().substring(0, 1),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
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
                      crypto.name,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                    const SizedBox(width: 8),
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
                  ],
                ),
                const SizedBox(height: 4),
                AnimatedDefaultTextStyle(
                  duration: Duration(milliseconds: 300),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: isPositive ? Colors.green : Colors.red,
                  ),
                  child: Text('\$${crypto.priceUsd.toStringAsFixed(2)}'),
                ),
                Text(
                  'Updated: ${_lastUpdateTime.toString().substring(11, 19)}',
                  style: TextStyle(color: Colors.green.withOpacity(0.8), fontSize: 10),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AnimatedDefaultTextStyle(
                duration: Duration(milliseconds: 300),
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: isPositive ? Colors.green : Colors.red,
                ),
                child: Text('\$${crypto.priceUsd.toStringAsFixed(2)}'),
              ),
              const SizedBox(height: 4),
              AnimatedContainer(
                duration: Duration(milliseconds: 300),
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isPositive ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: isPositive ? Colors.green : Colors.red, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPositive ? Icons.trending_up : Icons.trending_down,
                      size: 12,
                      color: isPositive ? Colors.green : Colors.red,
                    ),
                    SizedBox(width: 2),
                    Text(
                      '${isPositive ? '+' : ''}${crypto.percentChange24h.toStringAsFixed(2)}%',
                      style: TextStyle(
                        color: isPositive ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              _buildCryptoChart(crypto),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      backgroundColor: Color(0xFF181A20),
      selectedItemColor: Colors.blueAccent,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.wallet), label: 'Wallet'),
        BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: 'Stats'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
      currentIndex: 0,
      onTap: (index) {},
    );
  }

  Widget _buildNoResultsWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            'No results found',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
          ),
          SizedBox(height: 8),
          Text(
            'Try searching with different keywords',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _searchController.clear(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: Text('Clear Search'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentList = selectedSort == 'crypto' ? filteredCryptoList : filteredCurrencies;
    final showNoResults = _searchQuery.isNotEmpty && currentList.isEmpty && !isLoading && !isCryptoLoading;

    return Scaffold(
      backgroundColor: const Color(0xFF181A20),
      appBar: AppBar(
        backgroundColor: const Color(0xFF181A20),
        elevation: 0,
        title: const Text(
          'Crypto Wallet',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Color(0xFF8A94A6), size: 28),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          // Real-time toggle button
          IconButton(
            icon: Icon(
              _isRealTimeActive ? Icons.pause : Icons.play_arrow,
              color: _isRealTimeActive ? Colors.green : Colors.red,
              size: 28,
            ),
            onPressed: _toggleRealTimeUpdates,
          ),
          IconButton(
            icon: Icon(Icons.search, color: Color(0xFF8A94A6), size: 28),
            onPressed: () => FocusScope.of(context).requestFocus(FocusNode()),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: (isLoading || (selectedSort == 'crypto' && isCryptoLoading))
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: selectedSort == 'crypto'
                  ? () async => _sortCurrencies('crypto')
                  : _fetchCurrencyData,
              child: showNoResults
                  ? _buildNoResultsWidget()
                  : ListView.builder(
                      itemCount: currentList.length + 4,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 80, top: 20),
                      itemBuilder: (context, index) {
                        if (index == 0) return _buildTotalBalanceCard();
                        if (index == 1) return _buildSearchBar();
                        if (index == 2) return _buildSearchResultsHeader();
                        if (index == 3) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            child: _buildSortingHeader(),
                          );
                        }

                        final itemIndex = index - 4;
                        if (selectedSort == 'crypto') {
                          final crypto = filteredCryptoList[itemIndex];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            child: _buildCryptoItem(crypto),
                          );
                        } else {
                          final currency = filteredCurrencies[itemIndex];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            child: _buildCurrencyItem(currency),
                          );
                        }
                      },
                    ),
            ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }
}