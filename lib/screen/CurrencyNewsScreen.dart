import 'package:currency_converter/model/article_model.dart';
import 'package:currency_converter/model/trend_model.dart';
import 'package:currency_converter/model/analysis_model.dart';
import 'package:currency_converter/model/chart_model.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import '../../services/firebase_service.dart';
import '../utils/sample_data.dart';

class CurrencyNewsScreen extends StatefulWidget {
  const CurrencyNewsScreen({super.key});

  @override
  State<CurrencyNewsScreen> createState() => _CurrencyNewsScreenState();
}

class _CurrencyNewsScreenState extends State<CurrencyNewsScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedCategory = 'All';
  String _selectedTimeframe = '1D';
  String _selectedAnalysisType = 'All';
  String _selectedChartType = 'All';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F23),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F23),
        title: const Text(
          'Currency News & Trends',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _generateSampleData,
            icon: const Icon(Icons.add_chart, color: Colors.white),
            tooltip: 'Generate Sample Data',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color.fromARGB(255, 10, 108, 236),
          labelColor: const Color.fromARGB(255, 10, 108, 236),
          unselectedLabelColor: const Color(0xFF8A94A6),
          labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          tabs: const [
            Tab(text: 'News'),
            Tab(text: 'Trends'),
            Tab(text: 'Analysis'),
            Tab(text: 'Charts'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildNewsTab(),
          _buildTrendsTab(),
          _buildAnalysisTab(),
          _buildChartsTab(),
        ],
      ),
    );
  }

  Widget _buildNewsTab() {
    return Column(
      children: [
        // Category Filter
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: ['All', 'USD', 'EUR', 'GBP', 'Asia', 'Crypto', 'Commodities'].map((category) {
              final isSelected = _selectedCategory == category;
              return Container(
                margin: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                  backgroundColor: const Color(0xFF1A1A2E),
                  selectedColor: const Color.fromARGB(255, 10, 108, 236).withOpacity(0.2),
                  labelStyle: TextStyle(
                    color: isSelected ? const Color.fromARGB(255, 10, 108, 236) : Colors.white,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  side: BorderSide(
                    color: isSelected ? const Color.fromARGB(255, 10, 108, 236) : Colors.transparent,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        // News List
        Expanded(
          child: StreamBuilder<List<Article>>(
            stream: _selectedCategory == 'All'
                ? FirebaseService.getArticles()
                : FirebaseService.getArticlesByCategory(_selectedCategory),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Color.fromARGB(255, 10, 108, 236),
                  ),
                );
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error loading news: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }
              final articles = snapshot.data ?? [];
              if (articles.isEmpty) {
                return _buildEmptyNewsState();
              }
              return RefreshIndicator(
                onRefresh: () async {
                  setState(() {}); // Trigger rebuild
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: articles.length,
                  itemBuilder: (context, index) {
                    return _buildNewsCard(articles[index]);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTrendsTab() {
    return Column(
      children: [
        // Timeframe Filter
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: ['1D', '1W', '1M', '3M', '1Y'].map((timeframe) {
              final isSelected = _selectedTimeframe == timeframe;
              return Container(
                margin: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(timeframe),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedTimeframe = timeframe;
                    });
                  },
                  backgroundColor: const Color(0xFF1A1A2E),
                  selectedColor: const Color.fromARGB(255, 10, 108, 236).withOpacity(0.2),
                  labelStyle: TextStyle(
                    color: isSelected ? const Color.fromARGB(255, 10, 108, 236) : Colors.white,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  side: BorderSide(
                    color: isSelected ? const Color.fromARGB(255, 10, 108, 236) : Colors.transparent,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        // Trends List
        Expanded(
          child: StreamBuilder<List<Trend>>(
            stream: FirebaseService.getTrends(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Color.fromARGB(255, 10, 108, 236),
                  ),
                );
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error loading trends: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }
              final trends = snapshot.data ?? [];
              final filteredTrends = trends.where((trend) => 
                _selectedTimeframe == 'All' || trend.timeframe == _selectedTimeframe
              ).toList();
              
              if (filteredTrends.isEmpty) {
                return _buildEmptyTrendsState();
              }
              return RefreshIndicator(
                onRefresh: () async {
                  setState(() {}); // Trigger rebuild
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredTrends.length,
                  itemBuilder: (context, index) {
                    return _buildTrendCard(filteredTrends[index]);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAnalysisTab() {
    return Column(
      children: [
        // Analysis Type Filter
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: ['All', 'Technical', 'Fundamental', 'Sentiment'].map((type) {
              final isSelected = _selectedAnalysisType == type;
              return Container(
                margin: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(type),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedAnalysisType = type;
                    });
                  },
                  backgroundColor: const Color(0xFF1A1A2E),
                  selectedColor: const Color.fromARGB(255, 10, 108, 236).withOpacity(0.2),
                  labelStyle: TextStyle(
                    color: isSelected ? const Color.fromARGB(255, 10, 108, 236) : Colors.white,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  side: BorderSide(
                    color: isSelected ? const Color.fromARGB(255, 10, 108, 236) : Colors.transparent,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        // Analysis List
        Expanded(
          child: StreamBuilder<List<Analysis>>(
            stream: FirebaseService.getAnalysis(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Color.fromARGB(255, 10, 108, 236),
                  ),
                );
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error loading analysis: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }
              final analysisList = snapshot.data ?? [];
              final filteredAnalysis = analysisList.where((analysis) => 
                _selectedAnalysisType == 'All' || 
                analysis.analysisType.toLowerCase() == _selectedAnalysisType.toLowerCase()
              ).toList();
              
              if (filteredAnalysis.isEmpty) {
                return _buildEmptyAnalysisState();
              }
              return RefreshIndicator(
                onRefresh: () async {
                  setState(() {}); // Trigger rebuild
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredAnalysis.length,
                  itemBuilder: (context, index) {
                    return _buildAnalysisCard(filteredAnalysis[index]);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildChartsTab() {
    return Column(
      children: [
        // Chart Type Filter
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: ['All', 'Line', 'Candlestick', 'Bar', 'Area'].map((type) {
              final isSelected = _selectedChartType == type;
              return Container(
                margin: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(type),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedChartType = type;
                    });
                  },
                  backgroundColor: const Color(0xFF1A1A2E),
                  selectedColor: const Color.fromARGB(255, 10, 108, 236).withOpacity(0.2),
                  labelStyle: TextStyle(
                    color: isSelected ? const Color.fromARGB(255, 10, 108, 236) : Colors.white,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  side: BorderSide(
                    color: isSelected ? const Color.fromARGB(255, 10, 108, 236) : Colors.transparent,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        // Charts List
        Expanded(
          child: StreamBuilder<List<ChartData>>(
            stream: FirebaseService.getCharts(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Color.fromARGB(255, 10, 108, 236),
                  ),
                );
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error loading charts: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }
              final charts = snapshot.data ?? [];
              final filteredCharts = charts.where((chart) => 
                _selectedChartType == 'All' || 
                chart.chartType.toLowerCase() == _selectedChartType.toLowerCase()
              ).toList();
              
              if (filteredCharts.isEmpty) {
                return _buildEmptyChartsState();
              }
              return RefreshIndicator(
                onRefresh: () async {
                  setState(() {}); // Trigger rebuild
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredCharts.length,
                  itemBuilder: (context, index) {
                    return _buildChartCard(filteredCharts[index]);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Empty State Widgets
  Widget _buildEmptyNewsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.article_outlined,
            size: 80,
            color: const Color(0xFF8A94A6).withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'No news articles yet',
            style: TextStyle(
              color: Color(0xFF8A94A6),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Check back later for updates',
            style: TextStyle(
              color: Color(0xFF8A94A6),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyTrendsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.trending_up,
            size: 80,
            color: const Color(0xFF8A94A6).withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'No trends available',
            style: TextStyle(
              color: Color(0xFF8A94A6),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Market trends will appear here',
            style: TextStyle(
              color: Color(0xFF8A94A6),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyAnalysisState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 80,
            color: const Color(0xFF8A94A6).withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'No analysis available',
            style: TextStyle(
              color: Color(0xFF8A94A6),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Market analysis will appear here',
            style: TextStyle(
              color: Color(0xFF8A94A6),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyChartsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.show_chart,
            size: 80,
            color: const Color(0xFF8A94A6).withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'No charts available',
            style: TextStyle(
              color: Color(0xFF8A94A6),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Market charts will appear here',
            style: TextStyle(
              color: Color(0xFF8A94A6),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // Card Widgets
  Widget _buildNewsCard(Article article) {
    Color impactColor;
    switch (article.impact) {
      case 'High':
        impactColor = Colors.red;
        break;
      case 'Medium':
        impactColor = Colors.orange;
        break;
      default:
        impactColor = Colors.green;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color.fromARGB(255, 10, 108, 236).withOpacity(0.3),
        ),
      ),
      child: InkWell(
        onTap: () => _showNewsDetails(article),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image if available
              if (article.imageUrl.isNotEmpty) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(
                    base64Decode(article.imageUrl),
                    width: double.infinity,
                    height: 150,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: double.infinity,
                        height: 150,
                        color: const Color(0xFF2A2A3E),
                        child: const Icon(
                          Icons.image_not_supported,
                          color: Color(0xFF8A94A6),
                          size: 40,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
              ],
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 10, 108, 236).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      article.category,
                      style: const TextStyle(
                        color: Color.fromARGB(255, 10, 108, 236),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: impactColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${article.impact} Impact',
                      style: TextStyle(
                        color: impactColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                article.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                article.summary,
                style: const TextStyle(
                  color: Color(0xFF8A94A6),
                  fontSize: 14,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    Icons.access_time,
                    color: Color(0xFF8A94A6),
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _getTimeAgo(article.createdAt),
                    style: const TextStyle(
                      color: Color(0xFF8A94A6),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Icon(
                    Icons.source,
                    color: Color(0xFF8A94A6),
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    article.source,
                    style: const TextStyle(
                      color: Color(0xFF8A94A6),
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => _shareNews(article),
                    icon: const Icon(
                      Icons.share,
                      color: Color(0xFF8A94A6),
                      size: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrendCard(Trend trend) {
    Color trendColor;
    IconData trendIcon;
    switch (trend.direction) {  // Changed from trendType to direction
      case 'up':
        trendColor = Colors.green;
        trendIcon = Icons.trending_up;
        break;
      case 'down':
        trendColor = Colors.red;
        trendIcon = Icons.trending_down;
        break;
      default:
        trendColor = Colors.orange;
        trendIcon = Icons.trending_flat;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: trendColor.withOpacity(0.3),
        ),
      ),
      child: InkWell(
        onTap: () => _showTrendDetails(trend),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: trendColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      trendIcon,
                      color: trendColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          trend.currency,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          trend.timeframe,
                          style: const TextStyle(
                            color: Color(0xFF8A94A6),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${trend.percentage > 0 ? '+' : ''}${trend.percentage.toStringAsFixed(2)}%',
                    style: TextStyle(
                      color: trendColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                trend.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                trend.description,
                style: const TextStyle(
                  color: Color(0xFF8A94A6),
                  fontSize: 14,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    Icons.access_time,
                    color: Color(0xFF8A94A6),
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _getTimeAgo(trend.createdAt),
                    style: const TextStyle(
                      color: Color(0xFF8A94A6),
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'By ${trend.authorName}',
                    style: const TextStyle(
                      color: Color(0xFF8A94A6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnalysisCard(Analysis analysis) {
    Color recommendationColor;
    IconData recommendationIcon;
    switch (analysis.recommendation.toLowerCase()) {  // Added toLowerCase()
      case 'buy':
        recommendationColor = Colors.green;
        recommendationIcon = Icons.arrow_upward;
        break;
      case 'sell':
        recommendationColor = Colors.red;
        recommendationIcon = Icons.arrow_downward;
        break;
      default:
        recommendationColor = Colors.orange;
        recommendationIcon = Icons.remove;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color.fromARGB(255, 10, 108, 236).withOpacity(0.3),
        ),
      ),
      child: InkWell(
        onTap: () => _showAnalysisDetails(analysis),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Remove the image section completely
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 10, 108, 236).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      analysis.analysisType.toUpperCase(),
                      style: const TextStyle(
                        color: Color.fromARGB(255, 10, 108, 236),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: recommendationColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          recommendationIcon,
                          color: recommendationColor,
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          analysis.recommendation.toUpperCase(),
                          style: TextStyle(
                            color: recommendationColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    analysis.currency,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                analysis.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                analysis.summary,
                style: const TextStyle(
                  color: Color(0xFF8A94A6),
                  fontSize: 14,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    Icons.visibility,
                    color: Color(0xFF8A94A6),
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${analysis.views} views',
                    style: const TextStyle(
                      color: Color(0xFF8A94A6),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Icon(
                    Icons.access_time,
                    color: Color(0xFF8A94A6),
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _getTimeAgo(analysis.createdAt),
                    style: const TextStyle(
                      color: Color(0xFF8A94A6),
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'By ${analysis.authorName}',
                    style: const TextStyle(
                      color: Color(0xFF8A94A6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChartCard(ChartData chart) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color.fromARGB(255, 10, 108, 236).withOpacity(0.3),
        ),
      ),
      child: InkWell(
        onTap: () => _showChartDetails(chart),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Remove the image section completely
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 10, 108, 236).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      chart.chartType.toUpperCase(),
                      style: const TextStyle(
                        color: Color.fromARGB(255, 10, 108, 236),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      chart.timeframe,
                      style: const TextStyle(
                        color: Colors.orange,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    chart.currency,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                chart.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                chart.description,
                style: const TextStyle(
                  color: Color(0xFF8A94A6),
                  fontSize: 14,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    Icons.data_usage,
                    color: Color(0xFF8A94A6),
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${chart.dataPoints.length} data points',
                    style: const TextStyle(
                      color: Color(0xFF8A94A6),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Icon(
                    Icons.access_time,
                    color: Color(0xFF8A94A6),
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _getTimeAgo(chart.createdAt),
                    style: const TextStyle(
                      color: Color(0xFF8A94A6),
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'By ${chart.authorName}',
                    style: const TextStyle(
                      color: Color(0xFF8A94A6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Detail Dialog Methods
  void _showNewsDetails(Article article) {
  showDialog(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: const Color(0xFF0F0F23),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 500,
          maxHeight: 600,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFF1A1A2E),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      article.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image if available
                    if (article.imageUrl.isNotEmpty) ...[
                      Container(
                        constraints: const BoxConstraints(
                          maxHeight: 200,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.memory(
                            base64Decode(article.imageUrl),
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: double.infinity,
                                height: 150,
                                color: const Color(0xFF2A2A3E),
                                child: const Icon(
                                  Icons.image_not_supported,
                                  color: Color(0xFF8A94A6),
                                  size: 40,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    // Category and Impact
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 10, 108, 236).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            article.category,
                            style: const TextStyle(
                              color: Color.fromARGB(255, 10, 108, 236),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: (article.impact == 'High' ? Colors.red : 
                                   article.impact == 'Medium' ? Colors.orange : Colors.green)
                                   .withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${article.impact} Impact',
                            style: TextStyle(
                              color: article.impact == 'High' ? Colors.red : 
                                     article.impact == 'Medium' ? Colors.orange : Colors.green,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Source and Time
                    Row(
                      children: [
                        const Icon(
                          Icons.source,
                          color: Color(0xFF8A94A6),
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Source: ${article.source}',
                          style: const TextStyle(
                            color: Color(0xFF8A94A6),
                            fontSize: 12,
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.access_time,
                          color: Color(0xFF8A94A6),
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getTimeAgo(article.createdAt),
                          style: const TextStyle(
                            color: Color(0xFF8A94A6),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Summary
                    Text(
                      'Summary:',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      article.summary,
                      style: const TextStyle(
                        color: Color(0xFF8A94A6),
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Content
                    Text(
                      'Full Article:',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      article.content,
                      style: const TextStyle(
                        color: Color(0xFF8A94A6),
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Actions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFF1A1A2E),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _shareNews(article);
                    },
                    child: const Text(
                      'Share',
                      style: TextStyle(color: Color.fromARGB(255, 10, 108, 236)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 10, 108, 236),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  void _showTrendDetails(Trend trend) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0F0F23),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          trend.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(
                    '${trend.currency} - ${trend.timeframe}',
                    style: const TextStyle(
                      color: Color.fromARGB(255, 10, 108, 236),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${trend.percentage > 0 ? '+' : ''}${trend.percentage.toStringAsFixed(2)}%',
                    style: TextStyle(
                      color: trend.percentage > 0 ? Colors.green : Colors.red,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Description:',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                trend.description,
                style: const TextStyle(
                  color: Color(0xFF8A94A6),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Analysis:',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                trend.analysis,
                style: const TextStyle(
                  color: Color(0xFF8A94A6),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Close',
              style: TextStyle(color: Color.fromARGB(255, 10, 108, 236)),
            ),
          ),
        ],
      ),
    );
  }

  void _showAnalysisDetails(Analysis analysis) {
  // Increment views when opening analysis
  FirebaseService.incrementAnalysisViews(analysis.id!);
  
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: const Color(0xFF0F0F23),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        analysis.title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(
                  '${analysis.currency} - ${analysis.analysisType}',
                  style: const TextStyle(
                    color: Color.fromARGB(255, 10, 108, 236),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  analysis.recommendation.toUpperCase(),
                  style: TextStyle(
                    color: analysis.recommendation.toLowerCase() == 'buy' ? Colors.green : 
                           analysis.recommendation.toLowerCase() == 'sell' ? Colors.red : Colors.orange,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text(
                  'Risk Level: ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  analysis.riskLevel,
                  style: TextStyle(
                    color: analysis.riskLevel.toLowerCase() == 'high' ? Colors.red :
                           analysis.riskLevel.toLowerCase() == 'medium' ? Colors.orange : Colors.green,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text(
                  'Confidence: ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${analysis.confidenceScore.toStringAsFixed(1)}%',
                  style: const TextStyle(
                    color: Color.fromARGB(255, 10, 108, 236),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              analysis.content,
              style: const TextStyle(
                color: Color(0xFF8A94A6),
                fontSize: 14,
                height: 1.5,
              ),
            ),
            if (analysis.keyPoints.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Key Points:',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...analysis.keyPoints.map((point) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '• ',
                      style: TextStyle(
                        color: Color.fromARGB(255, 10, 108, 236),
                        fontSize: 14,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        point,
                        style: const TextStyle(
                          color: Color(0xFF8A94A6),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              )).toList(),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Close',
            style: TextStyle(color: Color.fromARGB(255, 10, 108, 236)),
          ),
        ),
      ],
    ),
  );
}

  void _showChartDetails(ChartData chart) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: const Color(0xFF0F0F23),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        chart.title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(
                  '${chart.currency} - ${chart.chartType}',
                  style: const TextStyle(
                    color: Color.fromARGB(255, 10, 108, 236),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  chart.timeframe,
                  style: const TextStyle(
                    color: Colors.orange,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              chart.description,
              style: const TextStyle(
                color: Color(0xFF8A94A6),
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Data Points: ${chart.dataPoints.length}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (chart.technicalIndicators.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                'Technical Indicators:',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...chart.technicalIndicators.map((indicator) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    const Text(
                      '• ',
                      style: TextStyle(
                        color: Color.fromARGB(255, 10, 108, 236),
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      indicator,
                      style: const TextStyle(
                        color: Color(0xFF8A94A6),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              )).toList(),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Close',
            style: TextStyle(color: Color.fromARGB(255, 10, 108, 236)),
          ),
        ),
      ],
    ),
  );
}

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  void _shareNews(Article article) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing: ${article.title}'),
        backgroundColor: const Color.fromARGB(255, 10, 108, 236),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _generateSampleData() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        backgroundColor: Color(0xFF0F0F23),
        content: Row(
          children: [
            CircularProgressIndicator(color: Color.fromARGB(255, 10, 108, 236)),
            SizedBox(width: 16),
            Text(
              'Generating sample data...',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );

    try {
      await SampleDataGenerator.generateAllSampleData();
      Navigator.pop(context); // Close loading dialog
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sample data generated successfully!'),
          backgroundColor: Color.fromARGB(255, 10, 108, 236),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error generating sample data: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
