import 'dart:math';
import 'dart:convert';
import 'dart:async';
import 'package:currency_converter/model/currency.dart'; // Make sure this file exists and defines the Currency class
import 'package:currency_converter/screen/CurrencyDetailPage.dart';
import 'package:currency_converter/screen/Stats.dart';
import 'package:currency_converter/screen/convter.dart';
import 'package:currency_converter/screen/edit_profile_screen.dart';
import 'package:currency_converter/widgets/app_drawer.dart';
import 'package:currency_converter/auth/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  // User's preferred currency data
  String _userBaseCurrency = 'USD';
  String _userBaseCurrencyName = 'US Dollar';
  String _userCountryFlag = '🇺🇸';
  String _userCountryName = 'United States';

  // Search functionality
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String selectedSort = 'world Currency';
  String itemLabel = 'Currency';
  List<String> sortingOptions = ['world Currency'];

  // Carousel
  PageController _carouselController = PageController();
  int _currentCarouselIndex = 0;
  Timer? _carouselTimer;
  List<Currency> _randomCarouselItems = [];

  // Bottom navigation
  int _currentIndex = 0;

  List<Currency> get availableCurrencies => currencies.isNotEmpty ? currencies : <Currency>[];

  @override
  void initState() {
    super.initState();
    _loadUserPreferences();
    _searchController.addListener(_onSearchChanged);
    _startRealTimeUpdates();
    _startCarouselAutoSlide();
  }

  @override
  void dispose() {
    _realTimeTimer?.cancel();
    _carouselTimer?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _carouselController.dispose();
    super.dispose();
  }

  // Load user's preferred currency from Firestore
  Future<void> _loadUserPreferences() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.user?.uid;
      
      if (userId != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();
            
        if (userDoc.exists) {
          final userData = userDoc.data();
          if (mounted) {
            setState(() {
              _userBaseCurrency = userData?['preferredCurrency'] ?? 'USD';
              _userBaseCurrencyName = userData?['preferredCurrencyName'] ?? 'US Dollar';
              _userCountryFlag = userData?['countryFlag'] ?? '🇺🇸';
              _userCountryName = userData?['country'] ?? 'United States';
            });
          }
          
          print('Loaded user preferences: $_userBaseCurrency');
        }
      }
    } catch (e) {
      print('Error loading user preferences: $e');
      // Keep default values
    }
    
    _fetchCurrencyData();
  }

  void _startCarouselAutoSlide() {
    _carouselTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_carouselController.hasClients) {
        final topItems = _getTopItems();
        if (topItems.isNotEmpty) {
          _currentCarouselIndex = (_currentCarouselIndex + 1) % topItems.length;
          _carouselController.animateToPage(
            _currentCarouselIndex,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      }
    });
  }

  List<dynamic> _getTopItems() {
    if (currencies.isEmpty) return [];

    if (_randomCarouselItems.isEmpty && currencies.isNotEmpty) {
      _randomCarouselItems = [...currencies];
      _randomCarouselItems.shuffle(Random());
    }

    return _randomCarouselItems.take(5).toList();
  }

  void _startRealTimeUpdates() {
    _realTimeTimer?.cancel();
    _realTimeTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_isRealTimeActive) {
        _updateRatesRealTime();
      }
    });
  }

  void _updateRatesRealTime() {
    if (!mounted) return;

    setState(() {
      _lastUpdateTime = DateTime.now();
      for (int i = 0; i < currencies.length; i++) {
        final random = Random();
        final fluctuationPercent = (random.nextDouble() - 0.5) * 0.01;
        final newRate = currencies[i].rate * (1 + fluctuationPercent);
        final newAmount = currencies[i].amount * (1 + fluctuationPercent);
        final percentChange =
            currencies[i].percentChange + (random.nextDouble() - 0.5) * 0.1;

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
      _filterData();
    });
  }

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
    _filterCurrencies();
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

  // Fetch currency data based on user's preferred currency
  Future<void> _fetchCurrencyData() async {
    final apiUrl = 'https://v6.exchangerate-api.com/v6/f23f645526cd179f30906490/latest/$_userBaseCurrency';
    
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
            {'code': 'BRL', 'name': 'Brazilian Real'},
            {'code': 'RUB', 'name': 'Russian Ruble'},
            {'code': 'ZAR', 'name': 'South African Rand'},
            {'code': 'AED', 'name': 'UAE Dirham'},
            {'code': 'SAR', 'name': 'Saudi Riyal'},
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
            
            // Skip if it's the same as user's base currency
            if (code == _userBaseCurrency) continue;
            
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

          filteredCurrencies.addAll(currencies);
        }
      }
    } catch (e) {
      print('Error fetching currency data: $e');
      _addMockCurrencyData();
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _addMockCurrencyData() {
    final random = Random();
    final List<Map<String, String>> currencyData = [
      {'code': 'USD', 'name': 'US Dollar'},
      {'code': 'EUR', 'name': 'Euro'},
      {'code': 'GBP', 'name': 'British Pound'},
      {'code': 'JPY', 'name': 'Japanese Yen'},
    ];

    final List<Color> colors = [
      Colors.blue,
      Colors.purple,
      Colors.orange,
      Colors.green,
    ];

    currencies.clear();
    for (var data in currencyData) {
      // Skip user's base currency
      if (data['code'] == _userBaseCurrency) continue;
      
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

  Widget _buildTopCurrenciesCarousel() {
    final topItems = _getTopItems();
    if (topItems.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Featured Currencies',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      if (_carouselController.hasClients && topItems.isNotEmpty) {
                        _currentCarouselIndex =
                            (_currentCarouselIndex - 1 + topItems.length) % topItems.length;
                        _carouselController.animateToPage(
                          _currentCarouselIndex,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    icon: const Icon(Icons.chevron_left, color: Colors.white54),
                  ),
                  IconButton(
                    onPressed: () {
                      if (_carouselController.hasClients && topItems.isNotEmpty) {
                        _currentCarouselIndex = (_currentCarouselIndex + 1) % topItems.length;
                        _carouselController.animateToPage(
                          _currentCarouselIndex,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    icon: const Icon(Icons.chevron_right, color: Colors.white54),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: PageView.builder(
              controller: _carouselController,
              onPageChanged: (index) {
                setState(() {
                  _currentCarouselIndex = index;
                });
              },
              itemCount: topItems.length,
              itemBuilder: (context, index) {
                final item = topItems[index];
                return _buildCarouselCard(item);
              },
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: topItems.asMap().entries.map((entry) {
              return Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentCarouselIndex == entry.key ? Colors.blue : Colors.white38,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCarouselCard(dynamic item) {
    final currency = item as Currency;
    final isPositive = currency.percentChange >= 0;
    final price = currency.rate;
    final change = currency.percentChange;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F0F23), Color(0xFF1A1A2E)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isPositive ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: currency.color,
                    child: Text(
                      currency.code[0],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
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
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _isRealTimeActive
                      ? Colors.green.withOpacity(0.2)
                      : Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _isRealTimeActive ? Colors.green : Colors.orange,
                    width: 1,
                  ),
                ),
                child: Text(
                  _isRealTimeActive ? 'LIVE' : 'PAUSED',
                  style: TextStyle(
                    color: _isRealTimeActive ? Colors.green : Colors.orange,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$_userBaseCurrency ${price.toStringAsFixed(4)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Updated: ${_lastUpdateTime.toString().substring(11, 19)}',
                    style: const TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isPositive
                          ? Colors.green.withOpacity(0.2)
                          : Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isPositive ? Colors.green : Colors.red,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isPositive ? Icons.trending_up : Icons.trending_down,
                          size: 14,
                          color: isPositive ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${isPositive ? '+' : ''}${change.toStringAsFixed(2)}%',
                          style: TextStyle(
                            color: isPositive ? Colors.green : Colors.red,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildChart(currency),
                ],
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
        color: const Color(0xFF0F0F23),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search currencies...',
          hintStyle: const TextStyle(color: Colors.white38),
          prefixIcon: const Icon(Icons.search, color: Colors.white38),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.white38),
                  onPressed: () => _searchController.clear(),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
      ),
    );
  }

  Widget _buildSearchResultsHeader() {
    if (_searchQuery.isEmpty) return const SizedBox.shrink();

    int resultCount = filteredCurrencies.length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F23),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.blue.withOpacity(0.5), width: 1),
            ),
            child: Icon(
              Icons.search_rounded,
              color: Colors.blue[300],
              size: 22,
            ),
          ),
          Expanded(
            child: Text(
              'Found $resultCount result${resultCount != 1 ? 's' : ''} for "$_searchQuery"',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
          if (_searchQuery.isNotEmpty)
            GestureDetector(
              onTap: () => _searchController.clear(),
              child: Container(
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(left: 8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.blue.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.close_rounded,
                  color: Colors.blue[300],
                  size: 18,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _sortCurrencies(String criteria) async {
    setState(() {
      selectedSort = criteria;
      _searchController.clear();
      _searchQuery = '';
      itemLabel = 'Currency';
      _filterCurrencies();
    });
  }

  Widget _buildSortingHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // User's base currency info
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [const Color(0xFF4ECDC4).withOpacity(0.2), const Color(0xFF44A08D).withOpacity(0.2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF4ECDC4).withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Text(
                _userCountryFlag,
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your Base Currency',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF8A94A6),
                      ),
                    ),
                    Text(
                      '$_userBaseCurrencyName ($_userBaseCurrency)',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                        color: Color(0xFF4ECDC4),
                      ),
                    ),
                    Text(
                      'All rates shown against $_userBaseCurrency',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF8A94A6),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF4ECDC4).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF4ECDC4).withOpacity(0.5)),
                ),
                child: Text(
                  _userCountryName,
                  style: const TextStyle(
                    color: Color(0xFF4ECDC4),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Exchange rates header
        const Text(
          'Exchange Rates',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildChart(Currency currency) {
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
            gridData: const FlGridData(show: false),
            titlesData: const FlTitlesData(show: false),
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
                    return FlDotCirclePainter(
                      radius: 0,
                      color: Colors.transparent,
                    );
                  },
                ),
                belowBarData: BarAreaData(
                  show: true,
                  color: chartColor.withOpacity(0.1),
                ),
                isStrokeCapRound: true,
                barWidth: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrencyItem(Currency currency) {
  final isPositive = currency.percentChange >= 0;
  
  return GestureDetector(
    onTap: () {
      // ✅ FIXED: Correct base currency pass karo
      
      // Create base currency object from user preferences
      final baseCurrency = Currency(
        code: _userBaseCurrency,
        name: _userBaseCurrencyName,
        rate: 1.0, // Base currency ka rate hamesha 1.0 hota hai
        amount: 1.0,
        percentChange: 0.0,
        ratePerUsd: 1.0,
        color: Colors.blue, // Default color for base currency
      );
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CurrencyDetailPage(
            currency: currency,        // ✅ Selected currency (PKR)
            baseCurrency: baseCurrency, // ✅ User's base currency (USD)
          ),
        ),
      );
    },
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F23),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isPositive
              ? Colors.green.withOpacity(0.3)
              : Colors.red.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            child: CircleAvatar(
              backgroundColor: currency.color,
              child: Text(
                currency.code[0],
                style: const TextStyle(
                  color: Colors.white,
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
                Row(
                  children: [
                    Text(
                      currency.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _isRealTimeActive
                            ? Colors.green.withOpacity(0.2)
                            : Colors.orange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _isRealTimeActive ? Colors.green : Colors.orange,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        _isRealTimeActive ? 'LIVE' : 'PAUSED',
                        style: TextStyle(
                          color: _isRealTimeActive ? Colors.green : Colors.orange,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 300),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: isPositive ? Colors.green : Colors.red,
                  ),
                  child: Text(
                    '${currency.amount.toStringAsFixed(4)} ${currency.code}',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '1 $_userBaseCurrency = ${currency.rate.toStringAsFixed(4)} ${currency.code}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Updated: ${_lastUpdateTime.toString().substring(11, 19)}',
                  style: TextStyle(
                    color: Colors.green.withOpacity(0.8),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: isPositive ? Colors.green : Colors.red,
                ),
                child: Text(
                  '$_userBaseCurrency ${(1 / currency.rate).toStringAsFixed(4)}',
                ),
              ),
              const SizedBox(height: 4),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isPositive
                      ? Colors.green.withOpacity(0.2)
                      : Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: isPositive ? Colors.green : Colors.red,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPositive ? Icons.trending_up : Icons.trending_down,
                      size: 12,
                      color: isPositive ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 2),
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

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      backgroundColor: const Color(0xFF0A0A1A),
      selectedItemColor: const Color(0xFF4ECDC4),
      unselectedItemColor: const Color(0xFF8A94A6),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.wallet), label: 'Wallet'),
        BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: 'Stats'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
        switch (index) {
          case 0:
            break;
          case 1:
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => StatsScreen(currencies: currencies),
              ),
            );
            break;
          case 2:
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const EditProfileScreen(),
              ),
            );
            break;
        }
      },
    );
  }

  Widget _buildNoResultsWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'No results found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try searching with different keywords',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _searchController.clear(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear Search'),
          ),
        ],
      ),
    );
  }

  Widget _buildConverterButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: ElevatedButton.icon(
        onPressed: () {
          if (currencies.isNotEmpty) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CurrencyConverterScreen(
                availableCurrencies: currencies,
              )),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please wait, currencies are loading...')),
            );
          }
        },
        icon: const Icon(Icons.swap_horiz, size: 24),
        label: const Text(
          'Currency Converter',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4ECDC4),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 8,
          shadowColor: const Color(0xFF4ECDC4).withOpacity(0.3),
        ),
      ),
    );
  }

  // Simple drawer fallback if FixedOverflowDrawer doesn't exist
  

  @override
  Widget build(BuildContext context) {
    final currentList = filteredCurrencies;
    final showNoResults = _searchQuery.isNotEmpty && currentList.isEmpty && !isLoading;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A1A),
        elevation: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'CurrenSee',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _userCountryFlag,
              style: const TextStyle(fontSize: 20),
            ),
          ],
        ),
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(
              Icons.menu,
              color: Color(0xFF8A94A6),
              size: 28,
            ),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isRealTimeActive ? Icons.pause : Icons.play_arrow,
              color: _isRealTimeActive ? Colors.green : Colors.red,
              size: 28,
            ),
            onPressed: _toggleRealTimeUpdates,
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF8A94A6), size: 28),
            onPressed: _fetchCurrencyData,
          ),
        ],
      ),
      // Use fallback drawer if FixedOverflowDrawer doesn't exist
      drawer: FixedOverflowDrawer(),
      body: (isLoading)
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchCurrencyData,
              child: showNoResults
                  ? _buildNoResultsWidget()
                  : ListView.builder(
                      itemCount: currentList.length + 5,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 80, top: 20),
                      itemBuilder: (context, index) {
                        if (index == 0) return _buildTopCurrenciesCarousel();
                        if (index == 1) return _buildConverterButton();
                        if (index == 2) return _buildSearchBar();
                        if (index == 3) return _buildSearchResultsHeader();
                        if (index == 4) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            child: _buildSortingHeader(),
                          );
                        }
                        final itemIndex = index - 5;
                        if (itemIndex < filteredCurrencies.length) {
                          final currency = filteredCurrencies[itemIndex];
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            child: _buildCurrencyItem(currency),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
            ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }
}
