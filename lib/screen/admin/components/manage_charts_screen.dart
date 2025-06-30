import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../auth/auth_provider.dart';
import '../../../utils/modern_constants.dart';
import '../../../utils/responsive_helper.dart';
import '../../../widgets/common/loading_widget.dart';
import '../../../widgets/common/empty_state_widget.dart';

class ManageChartsScreen extends StatefulWidget {
  const ManageChartsScreen({super.key});

  @override
  State<ManageChartsScreen> createState() => _ManageChartsScreenState();
}

class _ManageChartsScreenState extends State<ManageChartsScreen> {
  List<Map<String, dynamic>> charts = [];
  bool isLoading = true;
  String searchQuery = '';
  String selectedFilter = 'All';
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCharts();
  }

  String _formatTimestamp(dynamic timestamp) {
    try {
      DateTime dateTime;
      
      if (timestamp == null) {
        return 'Not available';
      }
      
      if (timestamp.runtimeType.toString().contains('Timestamp')) {
        dateTime = timestamp.toDate();
      } else if (timestamp is String) {
        dateTime = DateTime.parse(timestamp);
      } else if (timestamp is int) {
        dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      } else if (timestamp is DateTime) {
        dateTime = timestamp;
      } else if (timestamp is Map && timestamp.containsKey('seconds')) {
        final seconds = timestamp['seconds'] as int;
        dateTime = DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
      } else {
        return 'Invalid date format';
      }
      
      return DateFormat('MMM dd, yyyy • hh:mm a').format(dateTime);
    } catch (e) {
      print('Error formatting timestamp: $e');
      return 'Date format error';
    }
  }

  String _getRelativeTime(dynamic timestamp) {
    try {
      DateTime dateTime;
      
      if (timestamp == null) return 'Unknown';
      
      if (timestamp.runtimeType.toString().contains('Timestamp')) {
        dateTime = timestamp.toDate();
      } else if (timestamp is String) {
        dateTime = DateTime.parse(timestamp);
      } else if (timestamp is int) {
        dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      } else if (timestamp is DateTime) {
        dateTime = timestamp;
      } else if (timestamp is Map && timestamp.containsKey('seconds')) {
        final seconds = timestamp['seconds'] as int;
        dateTime = DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
      } else {
        return 'Unknown';
      }
      
      final now = DateTime.now();
      final difference = now.difference(dateTime);
      
      if (difference.inDays > 365) {
        final years = (difference.inDays / 365).floor();
        return '$years year${years > 1 ? 's' : ''} ago';
      } else if (difference.inDays > 30) {
        final months = (difference.inDays / 30).floor();
        return '$months month${months > 1 ? 's' : ''} ago';
      } else if (difference.inDays > 0) {
        return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Unknown';
    }
  }

  Future<void> _loadCharts() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });
      
      final querySnapshot = await FirebaseFirestore.instance
          .collection('charts')
          .orderBy('createdAt', descending: true)
          .get();
      
      setState(() {
        charts = querySnapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'title': data['title'] ?? '',
            'currency': data['currency'] ?? '',
            'chartType': data['chartType'] ?? '',
            'timeframe': data['timeframe'] ?? '',
            'dataPoints': data['dataPoints'] ?? [],
            'description': data['description'] ?? '',
            'technicalIndicators': List<String>.from(data['technicalIndicators'] ?? []),
            'chartSettings': Map<String, dynamic>.from(data['chartSettings'] ?? {}),
            'isActive': data['isActive'] ?? true,
            'createdAt': data['createdAt'],
            'updatedAt': data['updatedAt'],
            'authorId': data['authorId'] ?? '',
            'authorName': data['authorName'] ?? '',
          };
        }).toList();
        
        isLoading = false;
        print('✅ Loaded ${charts.length} charts successfully');
      });
    } catch (e) {
      print('❌ Error loading charts: $e');
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load charts: ${e.toString()}';
        charts = [];
      });
    }
  }

  List<Map<String, dynamic>> get filteredCharts {
    if (charts.isEmpty) return [];
    try {
      var filtered = List<Map<String, dynamic>>.from(charts);
      if (searchQuery.isNotEmpty) {
        filtered = filtered.where((chart) {
          final title = (chart['title'] ?? '').toString().toLowerCase();
          final currency = (chart['currency'] ?? '').toString().toLowerCase();
          final query = searchQuery.toLowerCase();
          return title.contains(query) || currency.contains(query);
        }).toList();
      }
      if (selectedFilter != 'All') {
        filtered = filtered.where((chart) {
          switch (selectedFilter) {
            case 'Active':
              return chart['isActive'] == true;
            case 'Inactive':
              return chart['isActive'] == false;
            case 'Line':
              return chart['chartType'] == 'Line';
            case 'Candlestick':
              return chart['chartType'] == 'Candlestick';
            case 'Bar':
              return chart['chartType'] == 'Bar';
            case 'Area':
              return chart['chartType'] == 'Area';
            default:
              return true;
          }
        }).toList();
      }
      return filtered;
    } catch (e) {
      print('Error filtering charts: $e');
      return [];
    }
  }

  Widget _buildChartIcon(String chartType) {
    IconData icon;
    Color color;
    
    switch (chartType.toLowerCase()) {
      case 'line':
        icon = Icons.show_chart_rounded;
        color = Colors.blue;
        break;
      case 'candlestick':
        icon = Icons.candlestick_chart_rounded;
        color = Colors.green;
        break;
      case 'bar':
        icon = Icons.bar_chart_rounded;
        color = Colors.orange;
        break;
      case 'area':
        icon = Icons.area_chart_rounded;
        color = Colors.purple;
        break;
      default:
        icon = Icons.insert_chart_rounded;
        color = Colors.grey;
    }
    
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    return Scaffold(
      backgroundColor: ModernConstants.backgroundColor,
      appBar: AppBar(
        backgroundColor: ModernConstants.backgroundColor,
        elevation: 0,
        title: const Text(
          'Manage Charts',
          style: TextStyle(
            color: ModernConstants.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: ModernConstants.primaryPurple),
            onPressed: () => _showAddEditDialog(),
            tooltip: 'Add New Chart',
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: ModernConstants.textSecondary),
            onPressed: _loadCharts,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Padding(
        padding: ResponsiveHelper.getScreenPadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            SizedBox(height: isMobile ? 16 : 20),
            if (isMobile) _buildMobileFilters() else _buildDesktopFilters(),
            SizedBox(height: isMobile ? 16 : 20),
            Expanded(child: _buildChartsList()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: ModernConstants.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: ModernConstants.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.insert_chart_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Charts Management',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${charts.length} total charts',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileFilters() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search charts...',
              prefixIcon: const Icon(Icons.search_rounded),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: ModernConstants.cardBackground,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            ),
            onChanged: (value) {
              setState(() {
                searchQuery = value;
              });
            },
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: ModernConstants.cardBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButton<String>(
            value: selectedFilter,
            underline: const SizedBox(),
            items: const [
              DropdownMenuItem(value: 'All', child: Text('All')),
              DropdownMenuItem(value: 'Active', child: Text('Active')),
              DropdownMenuItem(value: 'Inactive', child: Text('Inactive')),
              DropdownMenuItem(value: 'Line', child: Text('Line')),
              DropdownMenuItem(value: 'Candlestick', child: Text('Candlestick')),
              DropdownMenuItem(value: 'Bar', child: Text('Bar')),
              DropdownMenuItem(value: 'Area', child: Text('Area')),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  selectedFilter = value;
                });
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopFilters() {
    return Row(
      children: [
        SizedBox(
          width: 300,
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search charts...',
              prefixIcon: const Icon(Icons.search_rounded),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: ModernConstants.cardBackground,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            ),
            onChanged: (value) {
              setState(() {
                searchQuery = value;
              });
            },
          ),
        ),
        const SizedBox(width: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: ModernConstants.cardBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButton<String>(
            value: selectedFilter,
            underline: const SizedBox(),
            items: const [
              DropdownMenuItem(value: 'All', child: Text('All')),
              DropdownMenuItem(value: 'Active', child: Text('Active')),
              DropdownMenuItem(value: 'Inactive', child: Text('Inactive')),
              DropdownMenuItem(value: 'Line', child: Text('Line')),
              DropdownMenuItem(value: 'Candlestick', child: Text('Candlestick')),
              DropdownMenuItem(value: 'Bar', child: Text('Bar')),
              DropdownMenuItem(value: 'Area', child: Text('Area')),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  selectedFilter = value;
                });
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildChartsList() {
    if (isLoading) {
      return const LoadingWidget();
    }
    if (errorMessage != null) {
      return Center(child: Text(errorMessage!, style: const TextStyle(color: Colors.red)));
    }
    if (filteredCharts.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.insert_chart_outlined,
        title: 'No charts found',
        message: 'Try adjusting your search or filters.',
      );
    }

    final isMobile = ResponsiveHelper.isMobile(context);
    if (isMobile) {
      return ListView.builder(
        itemCount: filteredCharts.length,
        itemBuilder: (context, index) {
          return _buildMobileChartCard(filteredCharts[index]);
        },
      );
    } else {
      return _buildDesktopChartsTable();
    }
  }

  Widget _buildMobileChartCard(Map<String, dynamic> chart) {
    final dataPointsCount = (chart['dataPoints'] as List?)?.length ?? 0;
    final indicatorsCount = (chart['technicalIndicators'] as List<String>?)?.length ?? 0;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: ModernConstants.cardGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: ModernConstants.cardShadow,
        border: Border.all(
          color: ModernConstants.textTertiary.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildChartIcon(chart['chartType'] ?? ''),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      chart['title'] ?? 'Untitled Chart',
                      style: const TextStyle(
                        color: ModernConstants.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${chart['currency']} • ${chart['chartType']} • ${chart['timeframe']}',
                      style: const TextStyle(
                        color: ModernConstants.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: chart['isActive'] == true
                      ? Colors.green.withOpacity(0.2)
                      : Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  chart['isActive'] == true ? 'ACTIVE' : 'INACTIVE',
                  style: TextStyle(
                    color: chart['isActive'] == true ? Colors.green : Colors.red,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            chart['description'] ?? 'No description available',
            style: const TextStyle(
              color: ModernConstants.textSecondary,
              fontSize: 13,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: ModernConstants.primaryBlue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$dataPointsCount Data Points',
                  style: const TextStyle(
                    color: ModernConstants.primaryBlue,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (indicatorsCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: ModernConstants.primaryPurple.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$indicatorsCount Indicators',
                    style: const TextStyle(
                      color: ModernConstants.primaryPurple,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const Spacer(),
              Text(
                _getRelativeTime(chart['createdAt']),
                style: const TextStyle(
                  color: ModernConstants.textTertiary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () => _showChartDetails(chart),
                icon: const Icon(
                  Icons.visibility_rounded,
                  color: ModernConstants.primaryBlue,
                  size: 20,
                ),
              ),
              IconButton(
                onPressed: () => _showAddEditDialog(chart: chart),
                icon: const Icon(
                  Icons.edit_rounded,
                  color: ModernConstants.primaryPurple,
                  size: 20,
                ),
              ),
              IconButton(
                onPressed: () => _deleteChart(chart),
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.red,
                  size: 20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopChartsTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        decoration: BoxDecoration(
          color: ModernConstants.cardBackground,
          borderRadius: BorderRadius.circular(16),
          boxShadow: ModernConstants.cardShadow,
        ),
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(
            ModernConstants.textTertiary.withOpacity(0.1),
          ),
          columns: const [
            DataColumn(label: Text('Chart', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Currency', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Type', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Timeframe', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Data Points', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Indicators', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Created', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: filteredCharts.map((chart) {
            final dataPointsCount = (chart['dataPoints'] as List?)?.length ?? 0;
            final indicatorsCount = (chart['technicalIndicators'] as List<String>?)?.length ?? 0;
            
            return DataRow(
              cells: [
                DataCell(
                  Row(
                    children: [
                      _buildChartIcon(chart['chartType'] ?? ''),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          chart['title'] ?? 'Untitled Chart',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
                DataCell(Text(chart['currency'] ?? 'N/A')),
                DataCell(Text(chart['chartType'] ?? 'N/A')),
                DataCell(Text(chart['timeframe'] ?? 'N/A')),
                DataCell(Text('$dataPointsCount')),
                DataCell(Text('$indicatorsCount')),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: chart['isActive'] == true
                          ? Colors.green.withOpacity(0.2)
                          : Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      chart['isActive'] == true ? 'Active' : 'Inactive',
                      style: TextStyle(
                        color: chart['isActive'] == true ? Colors.green : Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _formatTimestamp(chart['createdAt']),
                        style: const TextStyle(fontSize: 12),
                      ),
                      Text(
                        _getRelativeTime(chart['createdAt']),
                        style: const TextStyle(
                          fontSize: 10,
                          color: ModernConstants.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.visibility_rounded, color: ModernConstants.primaryBlue),
                        onPressed: () => _showChartDetails(chart),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_rounded, color: ModernConstants.primaryPurple),
                        onPressed: () => _showAddEditDialog(chart: chart),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                        onPressed: () => _deleteChart(chart),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showChartDetails(Map<String, dynamic> chart) {
    final dataPointsCount = (chart['dataPoints'] as List?)?.length ?? 0;
    final indicators = (chart['technicalIndicators'] as List<String>?) ?? [];
    final settings = (chart['chartSettings'] as Map<String, dynamic>?) ?? {};
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ModernConstants.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            _buildChartIcon(chart['chartType'] ?? ''),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                chart['title'] ?? 'Chart Details',
                style: const TextStyle(
                  color: ModernConstants.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Container(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailCard('Currency', chart['currency'] ?? 'N/A', Icons.currency_exchange_rounded),
                _buildDetailCard('Chart Type', chart['chartType'] ?? 'N/A', Icons.insert_chart_rounded),
                _buildDetailCard('Timeframe', chart['timeframe'] ?? 'N/A', Icons.schedule_rounded),
                _buildDetailCard('Data Points', '$dataPointsCount', Icons.data_usage_rounded),
                _buildDetailCard('Status', chart['isActive'] == true ? 'Active' : 'Inactive', Icons.circle,
                  color: chart['isActive'] == true ? Colors.green : Colors.red),
                _buildDetailCard('Author', chart['authorName'] ?? 'Unknown', Icons.person_rounded),
                _buildDetailCard(
                  'Created', 
                  _formatTimestamp(chart['createdAt']), 
                  Icons.calendar_today_rounded,
                  subtitle: _getRelativeTime(chart['createdAt']),
                ),
                if (chart['updatedAt'] != null)
                  _buildDetailCard(
                    'Last Updated', 
                    _formatTimestamp(chart['updatedAt']), 
                    Icons.update_rounded,
                    subtitle: _getRelativeTime(chart['updatedAt']),
                  ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: ModernConstants.textTertiary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Description',
                        style: TextStyle(
                          color: ModernConstants.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        chart['description'] ?? 'No description available',
                        style: const TextStyle(
                          color: ModernConstants.textPrimary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                if (indicators.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: ModernConstants.textTertiary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Technical Indicators',
                          style: TextStyle(
                            color: ModernConstants.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: indicators.map((indicator) => 
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: ModernConstants.primaryPurple.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                indicator,
                                style: const TextStyle(
                                  color: ModernConstants.primaryPurple,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                if (settings.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: ModernConstants.textTertiary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Chart Settings',
                          style: TextStyle(
                            color: ModernConstants.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...settings.entries.map((entry) => 
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              children: [
                                Text(
                                  '${entry.key}: ',
                                  style: const TextStyle(
                                    color: ModernConstants.textSecondary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    entry.value.toString(),
                                    style: const TextStyle(
                                      color: ModernConstants.textPrimary,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ).toList(),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Close',
              style: TextStyle(color: ModernConstants.primaryBlue),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard(String label, String value, IconData icon, {String? subtitle, Color? color}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ModernConstants.textTertiary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: ModernConstants.textTertiary.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (color ?? ModernConstants.primaryBlue).withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              icon,
              color: color ?? ModernConstants.primaryBlue,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: ModernConstants.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: ModernConstants.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: ModernConstants.textTertiary,
                      fontSize: 10,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddEditDialog({Map<String, dynamic>? chart}) {
    final isEditing = chart != null;
    final titleController = TextEditingController(text: chart?['title'] ?? '');
    final currencyController = TextEditingController(text: chart?['currency'] ?? '');
    final timeframeController = TextEditingController(text: chart?['timeframe'] ?? '');
    final descriptionController = TextEditingController(text: chart?['description'] ?? '');
    final indicatorsController = TextEditingController(text: (chart?['technicalIndicators'] as List<String>?)?.join(', ') ?? '');
    
    String selectedChartType = chart?['chartType'] ?? 'Line';
    bool isActive = chart?['isActive'] ?? true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: ModernConstants.cardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            isEditing ? 'Edit Chart' : 'Add New Chart',
            style: const TextStyle(
              color: ModernConstants.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Container(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: currencyController,
                    decoration: const InputDecoration(
                      labelText: 'Currency',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedChartType,
                    decoration: const InputDecoration(
                      labelText: 'Chart Type',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Line', child: Text('Line')),
                      DropdownMenuItem(value: 'Candlestick', child: Text('Candlestick')),
                      DropdownMenuItem(value: 'Bar', child: Text('Bar')),
                      DropdownMenuItem(value: 'Area', child: Text('Area')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedChartType = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: timeframeController,
                    decoration: const InputDecoration(
                      labelText: 'Timeframe (e.g., 1H, 4H, 1D)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: indicatorsController,
                    decoration: const InputDecoration(
                      labelText: 'Technical Indicators (comma separated)',
                      border: OutlineInputBorder(),
                      hintText: 'RSI, MACD, SMA, EMA',
                    ),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Active'),
                    value: isActive,
                    onChanged: (value) {
                      setState(() {
                        isActive = value;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => _saveChart(
                isEditing: isEditing,
                chartId: chart?['id'],
                title: titleController.text,
                currency: currencyController.text,
                chartType: selectedChartType,
                timeframe: timeframeController.text,
                description: descriptionController.text,
                technicalIndicators: indicatorsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
                isActive: isActive,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: ModernConstants.primaryPurple,
                foregroundColor: Colors.white,
              ),
              child: Text(isEditing ? 'Update' : 'Add'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveChart({
    required bool isEditing,
    String? chartId,
    required String title,
    required String currency,
    required String chartType,
    required String timeframe,
    required String description,
    required List<String> technicalIndicators,
    required bool isActive,
  }) async {
    if (title.isEmpty || currency.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userData = authProvider.userData;
      
      final chartData = {
        'title': title,
        'currency': currency,
        'chartType': chartType,
        'timeframe': timeframe,
        'description': description,
        'technicalIndicators': technicalIndicators,
        'chartSettings': <String, dynamic>{}, // Empty for now, can be expanded
        'isActive': isActive,
        'updatedAt': FieldValue.serverTimestamp(),
        'authorId': userData?['id'] ?? '',
        'authorName': userData?['name'] ?? 'Admin',
      };

      if (isEditing && chartId != null) {
        await FirebaseFirestore.instance
            .collection('charts')
            .doc(chartId)
            .update(chartData);
      } else {
        chartData['createdAt'] = FieldValue.serverTimestamp();
        chartData['dataPoints'] = []; // Empty data points for new charts
        await FirebaseFirestore.instance
            .collection('charts')
            .add(chartData);
      }

      Navigator.of(context).pop();
      _loadCharts();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditing ? 'Chart updated successfully' : 'Chart added successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteChart(Map<String, dynamic> chart) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ModernConstants.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Delete Chart',
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to delete "${chart['title'] ?? 'this chart'}"? This action cannot be undone.',
          style: const TextStyle(color: ModernConstants.textPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await FirebaseFirestore.instance
            .collection('charts')
            .doc(chart['id'])
            .delete();
        
        _loadCharts();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${chart['title'] ?? 'Chart'} deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting chart: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
