// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:url_launcher/url_launcher.dart' as launcher;

// class CurrencyNewsScreen extends StatefulWidget {
//   const CurrencyNewsScreen({super.key});

//   @override
//   State<CurrencyNewsScreen> createState() => _CurrencyNewsScreenState();
// }

// class _CurrencyNewsScreenState extends State<CurrencyNewsScreen> with TickerProviderStateMixin {
//   late TabController _tabController;
//   String _selectedCategory = 'All';

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 4, vsync: this);
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF0F0F23),
//       appBar: AppBar(
//         backgroundColor: const Color(0xFF0F0F23),
//         title: const Text(
//           'Currency News & Trends',
//           style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//         ),
//         iconTheme: const IconThemeData(color: Colors.white),
//         elevation: 0,
//         bottom: TabBar(
//           controller: _tabController,
//           indicatorColor: const Color.fromARGB(255, 10, 108, 236),
//           labelColor: const Color.fromARGB(255, 10, 108, 236),
//           unselectedLabelColor: const Color(0xFF8A94A6),
//           labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
//           unselectedLabelStyle: const TextStyle(fontSize: 12),
//           tabs: const [
//             Tab(text: 'News'),
//             Tab(text: 'Trends'),
//             Tab(text: 'Analysis'),
//             Tab(text: 'Charts'),
//           ],
//         ),
//       ),
//       body: TabBarView(
//         controller: _tabController,
//         children: [
//           _buildNewsTab(),
//           _buildTrendsTab(),
//           _buildAnalysisTab(),
//           _buildChartsTab(),
//         ],
//       ),
//     );
//   }

//   Widget _buildNewsTab() {
//     final newsArticles = [
//       {
//         'title': 'USD Strengthens Against Major Currencies',
//         'summary': 'The US Dollar gained ground against major currencies following positive economic data and Federal Reserve policy signals...',
//         'category': 'USD',
//         'time': '2 hours ago',
//         'source': 'Financial Times',
//         'impact': 'High',
//         'imageUrl': '/placeholder.svg?height=120&width=200',
//       },
//       {
//         'title': 'EUR/USD Falls to Monthly Low',
//         'summary': 'European Central Bank signals potential rate cuts amid economic concerns and inflation targets...',
//         'category': 'EUR',
//         'time': '4 hours ago',
//         'source': 'Reuters',
//         'impact': 'Medium',
//         'imageUrl': '/placeholder.svg?height=120&width=200',
//       },
//       {
//         'title': 'Bitcoin Volatility Affects Crypto Markets',
//         'summary': 'Cryptocurrency markets see increased volatility as Bitcoin drops below key support levels...',
//         'category': 'Crypto',
//         'time': '6 hours ago',
//         'source': 'CoinDesk',
//         'impact': 'High',
//         'imageUrl': '/placeholder.svg?height=120&width=200',
//       },
//       {
//         'title': 'GBP Shows Resilience Despite Brexit Concerns',
//         'summary': 'British Pound maintains stability as trade negotiations continue and economic data remains positive...',
//         'category': 'GBP',
//         'time': '8 hours ago',
//         'source': 'BBC Business',
//         'impact': 'Low',
//         'imageUrl': '/placeholder.svg?height=120&width=200',
//       },
//       {
//         'title': 'Asian Markets React to Fed Policy Changes',
//         'summary': 'Asian currencies show mixed reactions to Federal Reserve policy announcements and interest rate decisions...',
//         'category': 'Asia',
//         'time': '12 hours ago',
//         'source': 'Bloomberg',
//         'impact': 'Medium',
//         'imageUrl': '/placeholder.svg?height=120&width=200',
//       },
//       {
//         'title': 'Oil Prices Impact Currency Markets',
//         'summary': 'Rising oil prices affect commodity currencies as energy markets show increased volatility...',
//         'category': 'Commodities',
//         'time': '1 day ago',
//         'source': 'MarketWatch',
//         'impact': 'Medium',
//         'imageUrl': '/placeholder.svg?height=120&width=200',
//       },
//     ];

//     final filteredArticles = _selectedCategory == 'All' 
//         ? newsArticles 
//         : newsArticles.where((article) => article['category'] == _selectedCategory).toList();

//     return Column(
//       children: [
//         // Category Filter
//         Container(
//           height: 50,
//           padding: const EdgeInsets.symmetric(vertical: 8),
//           child: ListView(
//             scrollDirection: Axis.horizontal,
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             children: ['All', 'USD', 'EUR', 'GBP', 'Asia', 'Crypto', 'Commodities'].map((category) {
//               final isSelected = _selectedCategory == category;
//               return Container(
//                 margin: const EdgeInsets.only(right: 8),
//                 child: FilterChip(
//                   label: Text(category),
//                   selected: isSelected,
//                   onSelected: (selected) {
//                     setState(() {
//                       _selectedCategory = category;
//                     });
//                   },
//                   backgroundColor: const Color(0xFF1A1A2E),
//                   selectedColor: const Color.fromARGB(255, 10, 108, 236).withOpacity(0.2),
//                   labelStyle: TextStyle(
//                     color: isSelected ? const Color.fromARGB(255, 10, 108, 236) : Colors.white,
//                     fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
//                   ),
//                   side: BorderSide(
//                     color: isSelected ? const Color.fromARGB(255, 10, 108, 236) : Colors.transparent,
//                   ),
//                 ),
//               );
//             }).toList(),
//           ),
//         ),
//         // News List
//         Expanded(
//           child: RefreshIndicator(
//             onRefresh: () async {
//               await Future.delayed(const Duration(seconds: 1));
//               _showSuccessSnackBar('News updated successfully!');
//             },
//             child: ListView.builder(
//               padding: const EdgeInsets.all(16),
//               itemCount: filteredArticles.length,
//               itemBuilder: (context, index) {
//                 final article = filteredArticles[index];
//                 return _buildNewsCard(article);
//               },
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildNewsCard(Map<String, String> article) {
//     Color impactColor;
//     switch (article['impact']) {
//       case 'High':
//         impactColor = Colors.red;
//         break;
//       case 'Medium':
//         impactColor = Colors.orange;
//         break;
//       default:
//         impactColor = Colors.green;
//     }

//     return Container(
//       margin: const EdgeInsets.only(bottom: 16),
//       decoration: BoxDecoration(
//         color: const Color(0xFF1A1A2E),
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(
//           color: const Color.fromARGB(255, 10, 108, 236).withOpacity(0.3),
//         ),
//       ),
//       child: InkWell(
//         onTap: () => _showNewsDetails(article),
//         borderRadius: BorderRadius.circular(16),
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                     decoration: BoxDecoration(
//                       color: const Color.fromARGB(255, 10, 108, 236).withOpacity(0.2),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Text(
//                       article['category']!,
//                       style: const TextStyle(
//                         color: Color.fromARGB(255, 10, 108, 236),
//                         fontSize: 12,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                   const Spacer(),
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                     decoration: BoxDecoration(
//                       color: impactColor.withOpacity(0.2),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Text(
//                       '${article['impact']} Impact',
//                       style: TextStyle(
//                         color: impactColor,
//                         fontSize: 10,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 12),
//               Text(
//                 article['title']!,
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 article['summary']!,
//                 style: const TextStyle(
//                   color: Color(0xFF8A94A6),
//                   fontSize: 14,
//                   height: 1.4,
//                 ),
//                 maxLines: 2,
//                 overflow: TextOverflow.ellipsis,
//               ),
//               const SizedBox(height: 12),
//               Row(
//                 children: [
//                   const Icon(
//                     Icons.access_time,
//                     color: Color(0xFF8A94A6),
//                     size: 16,
//                   ),
//                   const SizedBox(width: 4),
//                   Text(
//                     article['time']!,
//                     style: const TextStyle(
//                       color: Color(0xFF8A94A6),
//                       fontSize: 12,
//                     ),
//                   ),
//                   const SizedBox(width: 16),
//                   const Icon(
//                     Icons.source,
//                     color: Color(0xFF8A94A6),
//                     size: 16,
//                   ),
//                   const SizedBox(width: 4),
//                   Text(
//                     article['source']!,
//                     style: const TextStyle(
//                       color: Color(0xFF8A94A6),
//                       fontSize: 12,
//                     ),
//                   ),
//                   const Spacer(),
//                   IconButton(
//                     onPressed: () => _shareNews(article),
//                     icon: const Icon(
//                       Icons.share,
//                       color: Color(0xFF8A94A6),
//                       size: 16,
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTrendsTab() {
//     final trends = [
//       {
//         'pair': 'USD/EUR',
//         'change': '+0.85%',
//         'value': '1.0892',
//         'trend': 'up',
//         'volume': '2.3B',
//         'high': '1.0920',
//         'low': '1.0845',
//       },
//       {
//         'pair': 'GBP/USD',
//         'change': '-0.42%',
//         'value': '1.2654',
//         'trend': 'down',
//         'volume': '1.8B',
//         'high': '1.2698',
//         'low': '1.2620',
//       },
//       {
//         'pair': 'USD/JPY',
//         'change': '+1.23%',
//         'value': '149.87',
//         'trend': 'up',
//         'volume': '3.1B',
//         'high': '150.12',
//         'low': '148.95',
//       },
//       {
//         'pair': 'AUD/USD',
//         'change': '-0.67%',
//         'value': '0.6543',
//         'trend': 'down',
//         'volume': '1.2B',
//         'high': '0.6587',
//         'low': '0.6521',
//       },
//       {
//         'pair': 'USD/CAD',
//         'change': '+0.34%',
//         'value': '1.3456',
//         'trend': 'up',
//         'volume': '0.9B',
//         'high': '1.3478',
//         'low': '1.3421',
//       },
//       {
//         'pair': 'EUR/GBP',
//         'change': '+0.12%',
//         'value': '0.8612',
//         'trend': 'up',
//         'volume': '1.5B',
//         'high': '0.8634',
//         'low': '0.8598',
//       },
//     ];

//     return RefreshIndicator(
//       onRefresh: () async {
//         await Future.delayed(const Duration(seconds: 1));
//         _showSuccessSnackBar('Market data updated!');
//       },
//       child: ListView(
//         padding: const EdgeInsets.all(16),
//         children: [
//           const Text(
//             'Market Overview',
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 24,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 8),
//           const Text(
//             'Real-time currency exchange rates and market trends',
//             style: TextStyle(
//               color: Color(0xFF8A94A6),
//               fontSize: 14,
//             ),
//           ),
//           const SizedBox(height: 16),
//           ...trends.map((trend) => _buildTrendCard(trend)).toList(),
//           const SizedBox(height: 24),
//           _buildMarketSentiment(),
//           const SizedBox(height: 24),
//           _buildMarketStats(),
//         ],
//       ),
//     );
//   }

//   Widget _buildTrendCard(Map<String, String> trend) {
//     final isPositive = trend['trend'] == 'up';
//     final color = isPositive ? Colors.green : Colors.red;
//     final icon = isPositive ? Icons.trending_up : Icons.trending_down;

//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: const Color(0xFF1A1A2E),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(
//           color: color.withOpacity(0.3),
//         ),
//       ),
//       child: InkWell(
//         onTap: () => _showTrendDetails(trend),
//         child: Column(
//           children: [
//             Row(
//               children: [
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         trend['pair']!,
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         trend['value']!,
//                         style: const TextStyle(
//                           color: Color(0xFF8A94A6),
//                           fontSize: 14,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.end,
//                   children: [
//                     Row(
//                       children: [
//                         Icon(icon, color: color, size: 20),
//                         const SizedBox(width: 4),
//                         Text(
//                           trend['change']!,
//                           style: TextStyle(
//                             color: color,
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       'Vol: ${trend['volume']}',
//                       style: const TextStyle(
//                         color: Color(0xFF8A94A6),
//                         fontSize: 12,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   'High: ${trend['high']}',
//                   style: const TextStyle(
//                     color: Colors.green,
//                     fontSize: 12,
//                   ),
//                 ),
//                 Text(
//                   'Low: ${trend['low']}',
//                   style: const TextStyle(
//                     color: Colors.red,
//                     fontSize: 12,
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildMarketSentiment() {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: const Color(0xFF1A1A2E),
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(
//           color: const Color.fromARGB(255, 10, 108, 236).withOpacity(0.3),
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Market Sentiment',
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 8),
//           const Text(
//             'Current market mood based on trading activity',
//             style: TextStyle(
//               color: Color(0xFF8A94A6),
//               fontSize: 14,
//             ),
//           ),
//           const SizedBox(height: 16),
//           Row(
//             children: [
//               Expanded(
//                 child: _buildSentimentIndicator('Bullish', 65, Colors.green),
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: _buildSentimentIndicator('Bearish', 35, Colors.red),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSentimentIndicator(String label, int percentage, Color color) {
//     return Column(
//       children: [
//         Text(
//           label,
//           style: const TextStyle(
//             color: Colors.white,
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         const SizedBox(height: 8),
//         Stack(
//           children: [
//             Container(
//               height: 8,
//               decoration: BoxDecoration(
//                 color: const Color(0xFF8A94A6).withOpacity(0.3),
//                 borderRadius: BorderRadius.circular(4),
//               ),
//             ),
//             FractionallySizedBox(
//               widthFactor: percentage / 100,
//               child: Container(
//                 height: 8,
//                 decoration: BoxDecoration(
//                   color: color,
//                   borderRadius: BorderRadius.circular(4),
//                 ),
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 4),
//         Text(
//           '$percentage%',
//           style: TextStyle(
//             color: color,
//             fontSize: 14,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildMarketStats() {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: const Color(0xFF1A1A2E),
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(
//           color: const Color.fromARGB(255, 10, 108, 236).withOpacity(0.3),
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Market Statistics',
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 16),
//           Row(
//             children: [
//               Expanded(
//                 child: _buildStatCard('Active Pairs', '156', Icons.currency_exchange, const Color.fromARGB(255, 10, 108, 236)),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: _buildStatCard('Daily Volume', '\$6.2T', Icons.trending_up, Colors.green),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           Row(
//             children: [
//               Expanded(
//                 child: _buildStatCard('Volatility', 'Medium', Icons.show_chart, Colors.orange),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: _buildStatCard('Market Cap', '\$2.4Q', Icons.account_balance, Colors.purple),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatCard(String label, String value, IconData icon, Color color) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: const Color(0xFF0F0F23),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(
//         children: [
//           Icon(icon, color: color, size: 24),
//           const SizedBox(height: 8),
//           Text(
//             value,
//             style: TextStyle(
//               color: color,
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             label,
//             style: const TextStyle(
//               color: Color(0xFF8A94A6),
//               fontSize: 12,
//             ),
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildAnalysisTab() {
//     return RefreshIndicator(
//       onRefresh: () async {
//         await Future.delayed(const Duration(seconds: 1));
//         _showSuccessSnackBar('Analysis updated!');
//       },
//       child: ListView(
//         padding: const EdgeInsets.all(16),
//         children: [
//           const Text(
//             'Market Analysis',
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 24,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 8),
//           const Text(
//             'Expert insights and technical analysis',
//             style: TextStyle(
//               color: Color(0xFF8A94A6),
//               fontSize: 14,
//             ),
//           ),
//           const SizedBox(height: 16),
//           _buildAnalysisCard(
//             'Weekly Market Analysis',
//             'The currency markets showed mixed signals this week with the USD gaining strength against most major currencies. Federal Reserve policy decisions continue to influence global currency movements, while geopolitical tensions add volatility to emerging market currencies.',
//             'Expert Analysis',
//             Icons.analytics,
//             'Dr. Sarah Johnson, Chief Market Analyst',
//           ),
//           _buildAnalysisCard(
//             'Technical Analysis: EUR/USD',
//             'EUR/USD pair is approaching key resistance levels at 1.0950. RSI indicates oversold conditions in the short term, suggesting a potential bounce. Support levels are established at 1.0820 and 1.0780. Traders should watch for breakout patterns.',
//             'Technical Report',
//             Icons.show_chart,
//             'Michael Chen, Technical Analyst',
//           ),
//           _buildAnalysisCard(
//             'Economic Calendar Impact',
//             'Upcoming economic events that could impact currency markets this week include US inflation data, ECB policy meeting, and UK employment figures. These events are expected to create significant volatility in major currency pairs.',
//             'Economic Forecast',
//             Icons.calendar_today,
//             'Economic Research Team',
//           ),
//           _buildAnalysisCard(
//             'Central Bank Policies',
//             'Recent policy changes from major central banks show diverging approaches to inflation control. The Fed maintains hawkish stance while ECB signals dovish policy. This divergence creates opportunities in currency markets.',
//             'Policy Analysis',
//             Icons.account_balance,
//             'Policy Analysis Department',
//           ),
//           _buildAnalysisCard(
//             'Cryptocurrency Market Impact',
//             'Bitcoin and major cryptocurrencies continue to influence traditional currency markets. Institutional adoption and regulatory developments are key factors driving correlation between crypto and forex markets.',
//             'Crypto Analysis',
//             Icons.currency_bitcoin,
//             'Crypto Research Team',
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildAnalysisCard(String title, String content, String type, IconData icon, String author) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 16),
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: const Color(0xFF1A1A2E),
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(
//           color: const Color.fromARGB(255, 10, 108, 236).withOpacity(0.3),
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color: const Color.fromARGB(255, 10, 108, 236).withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Icon(
//                   icon,
//                   color: const Color.fromARGB(255, 10, 108, 236),
//                   size: 20,
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       title,
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     Text(
//                       type,
//                       style: const TextStyle(
//                         color: Color.fromARGB(255, 10, 108, 236),
//                         fontSize: 12,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           Text(
//             content,
//             style: const TextStyle(
//               color: Color(0xFF8A94A6),
//               fontSize: 14,
//               height: 1.5,
//             ),
//           ),
//           const SizedBox(height: 12),
//           Text(
//             'By: $author',
//             style: const TextStyle(
//               color: Color(0xFF8A94A6),
//               fontSize: 12,
//               fontStyle: FontStyle.italic,
//             ),
//           ),
//           const SizedBox(height: 16),
//           Row(
//             children: [
//               Expanded(
//                 child: TextButton(
//                   onPressed: () => _showFullAnalysis(title, content, author),
//                   child: const Text(
//                     'Read More',
//                     style: TextStyle(
//                       color: Color.fromARGB(255, 10, 108, 236),
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ),
//               IconButton(
//                 onPressed: () => _shareAnalysis(title, content),
//                 icon: const Icon(
//                   Icons.share,
//                   color: Color(0xFF8A94A6),
//                   size: 20,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildChartsTab() {
//     return RefreshIndicator(
//       onRefresh: () async {
//         await Future.delayed(const Duration(seconds: 1));
//         _showSuccessSnackBar('Charts updated!');
//       },
//       child: ListView(
//         padding: const EdgeInsets.all(16),
//         children: [
//           const Text(
//             'Currency Charts',
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 24,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 8),
//           const Text(
//             'Interactive charts and technical indicators',
//             style: TextStyle(
//               color: Color(0xFF8A94A6),
//               fontSize: 14,
//             ),
//           ),
//           const SizedBox(height: 16),
//           _buildChartCard('USD/EUR', '1.0892', '+0.85%', true),
//           _buildChartCard('GBP/USD', '1.2654', '-0.42%', false),
//           _buildChartCard('USD/JPY', '149.87', '+1.23%', true),
//           _buildChartCard('AUD/USD', '0.6543', '-0.67%', false),
//           _buildChartCard('USD/CAD', '1.3456', '+0.34%', true),
//           _buildChartCard('EUR/GBP', '0.8612', '+0.12%', true),
//         ],
//       ),
//     );
//   }

//   Widget _buildChartCard(String pair, String value, String change, bool isPositive) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 16),
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: const Color(0xFF1A1A2E),
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(
//           color: const Color.fromARGB(255, 10, 108, 236).withOpacity(0.3),
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 pair,
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.end,
//                 children: [
//                   Text(
//                     value,
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   Text(
//                     change,
//                     style: TextStyle(
//                       color: isPositive ? Colors.green : Colors.red,
//                       fontSize: 14,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           Container(
//             height: 120,
//             decoration: BoxDecoration(
//               color: const Color(0xFF0F0F23),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(
//                     Icons.show_chart,
//                     color: const Color.fromARGB(255, 10, 108, 236),
//                     size: 40,
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     'Interactive Chart for $pair',
//                     style: const TextStyle(
//                       color: Color(0xFF8A94A6),
//                       fontSize: 14,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     'Tap to view full chart',
//                     style: const TextStyle(
//                       color: Color(0xFF8A94A6),
//                       fontSize: 12,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           const SizedBox(height: 12),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: ['1D', '1W', '1M', '3M', '1Y'].map((period) {
//               return TextButton(
//                 onPressed: () => _showChartPeriod(pair, period),
//                 child: Text(
//                   period,
//                   style: const TextStyle(
//                     color: Color.fromARGB(255, 10, 108, 236),
//                     fontSize: 12,
//                   ),
//                 ),
//               );
//             }).toList(),
//           ),
//         ],
//       ),
//     );
//   }

//   // Event Handlers
//   void _showNewsDetails(Map<String, String> article) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         backgroundColor: const Color(0xFF0F0F23),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: Text(
//           article['title']!,
//           style: const TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         content: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Row(
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                     decoration: BoxDecoration(
//                       color: const Color.fromARGB(255, 10, 108, 236).withOpacity(0.2),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Text(
//                       article['category']!,
//                       style: const TextStyle(
//                         color: Color.fromARGB(255, 10, 108, 236),
//                         fontSize: 12,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                   const Spacer(),
//                   Text(
//                     article['time']!,
//                     style: const TextStyle(
//                       color: Color(0xFF8A94A6),
//                       fontSize: 12,
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 12),
//               Text(
//                 'Source: ${article['source']}',
//                 style: const TextStyle(
//                   color: Color(0xFF8A94A6),
//                   fontSize: 12,
//                 ),
//               ),
//               const SizedBox(height: 16),
//               Text(
//                 article['summary']!,
//                 style: const TextStyle(
//                   color: Color(0xFF8A94A6),
//                   fontSize: 14,
//                   height: 1.5,
//                 ),
//               ),
//               const SizedBox(height: 16),
//               const Text(
//                 'This is a sample news article. In a real app, you would fetch actual news content from a financial news API like Alpha Vantage, Finnhub, or Bloomberg API.',
//                 style: TextStyle(
//                   color: Color(0xFF8A94A6),
//                   fontSize: 14,
//                   height: 1.5,
//                   fontStyle: FontStyle.italic,
//                 ),
//               ),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text(
//               'Close',
//               style: TextStyle(color: Color.fromARGB(255, 10, 108, 236)),
//             ),
//           ),
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//               _shareNews(article);
//             },
//             child: const Text(
//               'Share',
//               style: TextStyle(color: Color.fromARGB(255, 10, 108, 236)),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showTrendDetails(Map<String, String> trend) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         backgroundColor: const Color(0xFF0F0F23),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: Text(
//           '${trend['pair']} Details',
//           style: const TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _buildDetailRow('Current Price', trend['value']!),
//             _buildDetailRow('Change', trend['change']!),
//             _buildDetailRow('Volume', trend['volume']!),
//             _buildDetailRow('High', trend['high']!),
//             _buildDetailRow('Low', trend['low']!),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text(
//               'Close',
//               style: TextStyle(color: Color.fromARGB(255, 10, 108, 236)),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDetailRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             label,
//             style: const TextStyle(
//               color: Color(0xFF8A94A6),
//               fontSize: 14,
//             ),
//           ),
//           Text(
//             value,
//             style: const TextStyle(
//               color: Colors.white,
//               fontSize: 14,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showFullAnalysis(String title, String content, String author) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         backgroundColor: const Color(0xFF0F0F23),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: Text(
//           title,
//           style: const TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         content: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text(
//                 'By: $author',
//                 style: const TextStyle(
//                   color: Color.fromARGB(255, 10, 108, 236),
//                   fontSize: 12,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 16),
//               Text(
//                 '$content\n\nThis is a sample analysis. In a real app, you would fetch detailed analysis from financial data providers like Bloomberg, Reuters, or specialized forex analysis services.',
//                 style: const TextStyle(
//                   color: Color(0xFF8A94A6),
//                   fontSize: 14,
//                   height: 1.5,
//                 ),
//               ),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text(
//               'Close',
//               style: TextStyle(color: Color.fromARGB(255, 10, 108, 236)),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showChartPeriod(String pair, String period) {
//     _showSuccessSnackBar('Loading $period chart for $pair...');
//   }

//   void _shareNews(Map<String, String> article) {
//     _showSuccessSnackBar('Sharing: ${article['title']}');
//   }

//   void _shareAnalysis(String title, String content) {
//     _showSuccessSnackBar('Sharing analysis: $title');
//   }

//   void _showSuccessSnackBar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: const Color.fromARGB(255, 10, 108, 236),
//         behavior: SnackBarBehavior.floating,
//       ),
//     );
//   }
// }
