import 'dart:convert';
import 'dart:math';
import 'package:currency_converter/model/crypto.dart';
import 'package:http/http.dart' as http;

class CryptoService {
  static const String baseUrl = 'https://api.coingecko.com/api/v3';
  static const String marketsEndpoint = '/coins/markets';
  
  // Get cryptocurrency market data
  static Future<List<Crypto>> getCryptoMarkets({
    String vsCurrency = 'usd',
    String order = 'market_cap_desc',
    int perPage = 100,
    int page = 1,
    bool sparkline = false,
  }) async {
    try {
      final url = Uri.parse(
        '$baseUrl$marketsEndpoint?vs_currency=$vsCurrency&order=$order&per_page=$perPage&page=$page&sparkline=$sparkline'
      );

      print('Fetching data from: $url');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        
        return jsonData.map((json) => Crypto.fromJson(json)).toList();
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to load crypto data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching crypto data: $e');
      // Return mock data if API fails
      return _getMockCryptoData();
    }
  }

  // Get specific cryptocurrency data
  static Future<Crypto?> getCryptoById(String id) async {
    try {
      final url = Uri.parse('$baseUrl/coins/$id');
      
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return Crypto.fromJson(jsonData);
      } else {
        throw Exception('Failed to load crypto data');
      }
    } catch (e) {
      print('Error fetching crypto by ID: $e');
      return null;
    }
  }

  // Search cryptocurrencies
  static Future<List<Crypto>> searchCryptos(String query) async {
    try {
      final cryptos = await getCryptoMarkets(perPage: 250);
      return cryptos.where((crypto) =>
        crypto.name.toLowerCase().contains(query.toLowerCase()) ||
        crypto.symbol.toLowerCase().contains(query.toLowerCase())
      ).toList();
    } catch (e) {
      print('Error searching cryptos: $e');
      return [];
    }
  }

  // Mock data fallback
  static List<Crypto> _getMockCryptoData() {
    final random = Random();
    
    final mockData = [
      {
        'id': 'bitcoin',
        'symbol': 'btc',
        'name': 'Bitcoin',
        'image': 'https://assets.coingecko.com/coins/images/1/large/bitcoin.png',
        'current_price': 64000 + random.nextDouble() * 2000,
        'market_cap': 1200000000000,
        'market_cap_rank': 1,
        'total_volume': 25000000000,
        'high_24h': 66000,
        'low_24h': 62000,
        'price_change_24h': 500 + random.nextDouble() * 1000,
        'price_change_percentage_24h': 1.5 + random.nextDouble() * 2,
      },
      {
        'id': 'ethereum',
        'symbol': 'eth',
        'name': 'Ethereum',
        'image': 'https://assets.coingecko.com/coins/images/279/large/ethereum.png',
        'current_price': 3500 + random.nextDouble() * 200,
        'market_cap': 420000000000,
        'market_cap_rank': 2,
        'total_volume': 15000000000,
        'high_24h': 3600,
        'low_24h': 3400,
        'price_change_24h': -30 + random.nextDouble() * 60,
        'price_change_percentage_24h': -0.8 + random.nextDouble() * 1.6,
      },
      {
        'id': 'solana',
        'symbol': 'sol',
        'name': 'Solana',
        'image': 'https://assets.coingecko.com/coins/images/4128/large/solana.png',
        'current_price': 150 + random.nextDouble() * 20,
        'market_cap': 65000000000,
        'market_cap_rank': 5,
        'total_volume': 2500000000,
        'high_24h': 155,
        'low_24h': 145,
        'price_change_24h': 2 + random.nextDouble() * 4,
        'price_change_percentage_24h': 2.1 + random.nextDouble() * 2,
      },
    ];

    return mockData.map((data) => Crypto.fromJson(data)).toList();
  }

  // Format large numbers
  static String formatLargeNumber(double number) {
    if (number >= 1e12) {
      return '${(number / 1e12).toStringAsFixed(1)}T';
    } else if (number >= 1e9) {
      return '${(number / 1e9).toStringAsFixed(1)}B';
    } else if (number >= 1e6) {
      return '${(number / 1e6).toStringAsFixed(1)}M';
    } else if (number >= 1e3) {
      return '${(number / 1e3).toStringAsFixed(1)}K';
    } else {
      return number.toStringAsFixed(0);
    }
  }

  // Format price
  static String formatPrice(double price) {
    if (price >= 1000) {
      return price.toStringAsFixed(0);
    } else if (price >= 1) {
      return price.toStringAsFixed(2);
    } else if (price >= 0.01) {
      return price.toStringAsFixed(4);
    } else {
      return price.toStringAsFixed(6);
    }
  }
}