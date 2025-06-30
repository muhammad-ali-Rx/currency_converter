import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../auth/auth_provider.dart';
import '../../../utils/modern_constants.dart';
import '../../../utils/responsive_helper.dart';
import '../../../widgets/common/loading_widget.dart';
import '../../../widgets/common/empty_state_widget.dart';

class ManageTrendsScreen extends StatefulWidget {
  const ManageTrendsScreen({super.key});

  @override
  State<ManageTrendsScreen> createState() => _ManageTrendsScreenState();
}

class _ManageTrendsScreenState extends State<ManageTrendsScreen> {
  List<Map<String, dynamic>> trends = [];
  bool isLoading = true;
  String searchQuery = '';
  String selectedFilter = 'All';
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTrends();
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

  Future<void> _loadTrends() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });
      
      final querySnapshot = await FirebaseFirestore.instance
          .collection('trends')
          .orderBy('createdAt', descending: true)
          .get();
      
      setState(() {
        trends = querySnapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'title': data['title'] ?? '',
            'currency': data['currency'] ?? '',
            'timeframe': data['timeframe'] ?? '',
            'percentage': (data['percentage'] ?? 0.0).toDouble(),
            'direction': data['direction'] ?? 'neutral',
            'description': data['description'] ?? '',
            'analysis': data['analysis'] ?? '',
            'isActive': data['isActive'] ?? true,
            'createdAt': data['createdAt'],
            'updatedAt': data['updatedAt'],
            'authorId': data['authorId'] ?? '',
            'authorName': data['authorName'] ?? '',
          };
        }).toList();
        
        isLoading = false;
        print('✅ Loaded ${trends.length} trends successfully');
      });
    } catch (e) {
      print('❌ Error loading trends: $e');
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load trends: ${e.toString()}';
        trends = [];
      });
    }
  }

  List<Map<String, dynamic>> get filteredTrends {
    if (trends.isEmpty) return [];
    try {
      var filtered = List<Map<String, dynamic>>.from(trends);
      if (searchQuery.isNotEmpty) {
        filtered = filtered.where((trend) {
          final title = (trend['title'] ?? '').toString().toLowerCase();
          final currency = (trend['currency'] ?? '').toString().toLowerCase();
          final query = searchQuery.toLowerCase();
          return title.contains(query) || currency.contains(query);
        }).toList();
      }
      if (selectedFilter != 'All') {
        filtered = filtered.where((trend) {
          switch (selectedFilter) {
            case 'Active':
              return trend['isActive'] == true;
            case 'Inactive':
              return trend['isActive'] == false;
            case 'Up':
              return trend['direction'] == 'up';
            case 'Down':
              return trend['direction'] == 'down';
            case 'Neutral':
              return trend['direction'] == 'neutral';
            default:
              return true;
          }
        }).toList();
      }
      return filtered;
    } catch (e) {
      print('Error filtering trends: $e');
      return [];
    }
  }

  Widget _buildTrendIcon(String direction, double percentage) {
    IconData icon;
    Color color;
    
    switch (direction.toLowerCase()) {
      case 'up':
        icon = Icons.trending_up_rounded;
        color = Colors.green;
        break;
      case 'down':
        icon = Icons.trending_down_rounded;
        color = Colors.red;
        break;
      default:
        icon = Icons.trending_flat_rounded;
        color = Colors.orange;
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
          'Manage Trends',
          style: TextStyle(
            color: ModernConstants.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: ModernConstants.primaryPurple),
            onPressed: () => _showAddEditDialog(),
            tooltip: 'Add New Trend',
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: ModernConstants.textSecondary),
            onPressed: _loadTrends,
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
            Expanded(child: _buildTrendsList()),
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
              Icons.trending_up_rounded,
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
                  'Trends Management',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${trends.length} total trends',
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
              hintText: 'Search trends...',
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
              DropdownMenuItem(value: 'Up', child: Text('Up Trend')),
              DropdownMenuItem(value: 'Down', child: Text('Down Trend')),
              DropdownMenuItem(value: 'Neutral', child: Text('Neutral')),
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
              hintText: 'Search trends...',
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
              DropdownMenuItem(value: 'Up', child: Text('Up Trend')),
              DropdownMenuItem(value: 'Down', child: Text('Down Trend')),
              DropdownMenuItem(value: 'Neutral', child: Text('Neutral')),
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

  Widget _buildTrendsList() {
    if (isLoading) {
      return const LoadingWidget();
    }
    if (errorMessage != null) {
      return Center(child: Text(errorMessage!, style: const TextStyle(color: Colors.red)));
    }
    if (filteredTrends.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.trending_up_outlined,
        title: 'No trends found',
        message: 'Try adjusting your search or filters.',
      );
    }

    final isMobile = ResponsiveHelper.isMobile(context);
    if (isMobile) {
      return ListView.builder(
        itemCount: filteredTrends.length,
        itemBuilder: (context, index) {
          return _buildMobileTrendCard(filteredTrends[index]);
        },
      );
    } else {
      return _buildDesktopTrendsTable();
    }
  }

  Widget _buildMobileTrendCard(Map<String, dynamic> trend) {
    final direction = trend['direction'] ?? 'neutral';
    final percentage = (trend['percentage'] ?? 0.0).toDouble();
    
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
              _buildTrendIcon(direction, percentage),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trend['title'] ?? 'Untitled Trend',
                      style: const TextStyle(
                        color: ModernConstants.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${trend['currency']} • ${trend['timeframe']}',
                      style: const TextStyle(
                        color: ModernConstants.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${percentage > 0 ? '+' : ''}${percentage.toStringAsFixed(2)}%',
                style: TextStyle(
                  color: direction == 'up' ? Colors.green : 
                         direction == 'down' ? Colors.red : Colors.orange,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            trend['description'] ?? 'No description available',
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
                  color: trend['isActive'] == true
                      ? Colors.green.withOpacity(0.2)
                      : Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  trend['isActive'] == true ? 'ACTIVE' : 'INACTIVE',
                  style: TextStyle(
                    color: trend['isActive'] == true ? Colors.green : Colors.red,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                _getRelativeTime(trend['createdAt']),
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
                onPressed: () => _showTrendDetails(trend),
                icon: const Icon(
                  Icons.visibility_rounded,
                  color: ModernConstants.primaryBlue,
                  size: 20,
                ),
              ),
              IconButton(
                onPressed: () => _showAddEditDialog(trend: trend),
                icon: const Icon(
                  Icons.edit_rounded,
                  color: ModernConstants.primaryPurple,
                  size: 20,
                ),
              ),
              IconButton(
                onPressed: () => _deleteTrend(trend),
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

  Widget _buildDesktopTrendsTable() {
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
            DataColumn(label: Text('Trend', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Currency', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Timeframe', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Change', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Created', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: filteredTrends.map((trend) {
            final direction = trend['direction'] ?? 'neutral';
            final percentage = (trend['percentage'] ?? 0.0).toDouble();
            
            return DataRow(
              cells: [
                DataCell(
                  Row(
                    children: [
                      _buildTrendIcon(direction, percentage),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          trend['title'] ?? 'Untitled Trend',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
                DataCell(Text(trend['currency'] ?? 'N/A')),
                DataCell(Text(trend['timeframe'] ?? 'N/A')),
                DataCell(
                  Text(
                    '${percentage > 0 ? '+' : ''}${percentage.toStringAsFixed(2)}%',
                    style: TextStyle(
                      color: direction == 'up' ? Colors.green : 
                             direction == 'down' ? Colors.red : Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: trend['isActive'] == true
                          ? Colors.green.withOpacity(0.2)
                          : Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      trend['isActive'] == true ? 'Active' : 'Inactive',
                      style: TextStyle(
                        color: trend['isActive'] == true ? Colors.green : Colors.red,
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
                        _formatTimestamp(trend['createdAt']),
                        style: const TextStyle(fontSize: 12),
                      ),
                      Text(
                        _getRelativeTime(trend['createdAt']),
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
                        onPressed: () => _showTrendDetails(trend),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_rounded, color: ModernConstants.primaryPurple),
                        onPressed: () => _showAddEditDialog(trend: trend),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                        onPressed: () => _deleteTrend(trend),
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

  void _showTrendDetails(Map<String, dynamic> trend) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ModernConstants.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            _buildTrendIcon(trend['direction'] ?? 'neutral', (trend['percentage'] ?? 0.0).toDouble()),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                trend['title'] ?? 'Trend Details',
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
                _buildDetailCard('Currency', trend['currency'] ?? 'N/A', Icons.currency_exchange_rounded),
                _buildDetailCard('Timeframe', trend['timeframe'] ?? 'N/A', Icons.schedule_rounded),
                _buildDetailCard('Percentage Change', '${(trend['percentage'] ?? 0.0).toStringAsFixed(2)}%', Icons.percent_rounded),
                _buildDetailCard('Direction', (trend['direction'] ?? 'neutral').toUpperCase(), Icons.trending_up_rounded),
                _buildDetailCard('Status', trend['isActive'] == true ? 'Active' : 'Inactive', Icons.circle,
                  color: trend['isActive'] == true ? Colors.green : Colors.red),
                _buildDetailCard('Author', trend['authorName'] ?? 'Unknown', Icons.person_rounded),
                _buildDetailCard(
                  'Created', 
                  _formatTimestamp(trend['createdAt']), 
                  Icons.calendar_today_rounded,
                  subtitle: _getRelativeTime(trend['createdAt']),
                ),
                if (trend['updatedAt'] != null)
                  _buildDetailCard(
                    'Last Updated', 
                    _formatTimestamp(trend['updatedAt']), 
                    Icons.update_rounded,
                    subtitle: _getRelativeTime(trend['updatedAt']),
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
                        trend['description'] ?? 'No description available',
                        style: const TextStyle(
                          color: ModernConstants.textPrimary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
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
                        'Analysis',
                        style: TextStyle(
                          color: ModernConstants.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        trend['analysis'] ?? 'No analysis available',
                        style: const TextStyle(
                          color: ModernConstants.textPrimary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
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

  void _showAddEditDialog({Map<String, dynamic>? trend}) {
    final isEditing = trend != null;
    final titleController = TextEditingController(text: trend?['title'] ?? '');
    final currencyController = TextEditingController(text: trend?['currency'] ?? '');
    final timeframeController = TextEditingController(text: trend?['timeframe'] ?? '');
    final percentageController = TextEditingController(text: trend?['percentage']?.toString() ?? '');
    final descriptionController = TextEditingController(text: trend?['description'] ?? '');
    final analysisController = TextEditingController(text: trend?['analysis'] ?? '');
    
    String selectedDirection = trend?['direction'] ?? 'neutral';
    bool isActive = trend?['isActive'] ?? true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: ModernConstants.cardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            isEditing ? 'Edit Trend' : 'Add New Trend',
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
                  TextField(
                    controller: timeframeController,
                    decoration: const InputDecoration(
                      labelText: 'Timeframe',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: percentageController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Percentage Change',
                      border: OutlineInputBorder(),
                      suffixText: '%',
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedDirection,
                    decoration: const InputDecoration(
                      labelText: 'Direction',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'up', child: Text('Up')),
                      DropdownMenuItem(value: 'down', child: Text('Down')),
                      DropdownMenuItem(value: 'neutral', child: Text('Neutral')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedDirection = value;
                        });
                      }
                    },
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
                    controller: analysisController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Analysis',
                      border: OutlineInputBorder(),
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
              onPressed: () => _saveTrend(
                isEditing: isEditing,
                trendId: trend?['id'],
                title: titleController.text,
                currency: currencyController.text,
                timeframe: timeframeController.text,
                percentage: double.tryParse(percentageController.text) ?? 0.0,
                direction: selectedDirection,
                description: descriptionController.text,
                analysis: analysisController.text,
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

  Future<void> _saveTrend({
    required bool isEditing,
    String? trendId,
    required String title,
    required String currency,
    required String timeframe,
    required double percentage,
    required String direction,
    required String description,
    required String analysis,
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
      
      final trendData = {
        'title': title,
        'currency': currency,
        'timeframe': timeframe,
        'percentage': percentage,
        'direction': direction,
        'description': description,
        'analysis': analysis,
        'isActive': isActive,
        'updatedAt': FieldValue.serverTimestamp(),
        'authorId': userData?['id'] ?? '',
        'authorName': userData?['name'] ?? 'Admin',
      };

      if (isEditing && trendId != null) {
        await FirebaseFirestore.instance
            .collection('trends')
            .doc(trendId)
            .update(trendData);
      } else {
        trendData['createdAt'] = FieldValue.serverTimestamp();
        await FirebaseFirestore.instance
            .collection('trends')
            .add(trendData);
      }

      Navigator.of(context).pop();
      _loadTrends();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditing ? 'Trend updated successfully' : 'Trend added successfully'),
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

  Future<void> _deleteTrend(Map<String, dynamic> trend) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ModernConstants.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Delete Trend',
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to delete "${trend['title'] ?? 'this trend'}"? This action cannot be undone.',
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
            .collection('trends')
            .doc(trend['id'])
            .delete();
        
        _loadTrends();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${trend['title'] ?? 'Trend'} deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting trend: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
