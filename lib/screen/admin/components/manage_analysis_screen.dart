import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../auth/auth_provider.dart';
import '../../../utils/modern_constants.dart';
import '../../../utils/responsive_helper.dart';
import '../../../widgets/common/loading_widget.dart';
import '../../../widgets/common/empty_state_widget.dart';

class ManageAnalysisScreen extends StatefulWidget {
  const ManageAnalysisScreen({super.key});

  @override
  State<ManageAnalysisScreen> createState() => _ManageAnalysisScreenState();
}

class _ManageAnalysisScreenState extends State<ManageAnalysisScreen> {
  List<Map<String, dynamic>> analyses = [];
  bool isLoading = true;
  String searchQuery = '';
  String selectedFilter = 'All';
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAnalyses();
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

  Future<void> _loadAnalyses() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });
      
      final querySnapshot = await FirebaseFirestore.instance
          .collection('analyses')
          .orderBy('createdAt', descending: true)
          .get();
      
      setState(() {
        analyses = querySnapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'title': data['title'] ?? '',
            'currency': data['currency'] ?? '',
            'analysisType': data['analysisType'] ?? '',
            'content': data['content'] ?? '',
            'summary': data['summary'] ?? '',
            'recommendation': data['recommendation'] ?? '',
            'riskLevel': data['riskLevel'] ?? '',
            'confidenceScore': (data['confidenceScore'] ?? 0.0).toDouble(),
            'keyPoints': List<String>.from(data['keyPoints'] ?? []),
            'timeHorizon': data['timeHorizon'] ?? '',
            'isPublished': data['isPublished'] ?? true,
            'views': data['views'] ?? 0,
            'createdAt': data['createdAt'],
            'updatedAt': data['updatedAt'],
            'authorId': data['authorId'] ?? '',
            'authorName': data['authorName'] ?? '',
          };
        }).toList();
        
        isLoading = false;
        print('✅ Loaded ${analyses.length} analyses successfully');
      });
    } catch (e) {
      print('❌ Error loading analyses: $e');
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load analyses: ${e.toString()}';
        analyses = [];
      });
    }
  }

  List<Map<String, dynamic>> get filteredAnalyses {
    if (analyses.isEmpty) return [];
    try {
      var filtered = List<Map<String, dynamic>>.from(analyses);
      if (searchQuery.isNotEmpty) {
        filtered = filtered.where((analysis) {
          final title = (analysis['title'] ?? '').toString().toLowerCase();
          final currency = (analysis['currency'] ?? '').toString().toLowerCase();
          final query = searchQuery.toLowerCase();
          return title.contains(query) || currency.contains(query);
        }).toList();
      }
      if (selectedFilter != 'All') {
        filtered = filtered.where((analysis) {
          switch (selectedFilter) {
            case 'Published':
              return analysis['isPublished'] == true;
            case 'Draft':
              return analysis['isPublished'] == false;
            case 'Technical':
              return analysis['analysisType'] == 'Technical';
            case 'Fundamental':
              return analysis['analysisType'] == 'Fundamental';
            case 'Market Sentiment':
              return analysis['analysisType'] == 'Market Sentiment';
            default:
              return true;
          }
        }).toList();
      }
      return filtered;
    } catch (e) {
      print('Error filtering analyses: $e');
      return [];
    }
  }

  Widget _buildAnalysisIcon(String analysisType) {
    IconData icon;
    Color color;
    
    switch (analysisType.toLowerCase()) {
      case 'technical':
        icon = Icons.show_chart_rounded;
        color = Colors.blue;
        break;
      case 'fundamental':
        icon = Icons.analytics_rounded;
        color = Colors.green;
        break;
      case 'market sentiment':
        icon = Icons.sentiment_satisfied_rounded;
        color = Colors.orange;
        break;
      default:
        icon = Icons.article_rounded;
        color = Colors.purple;
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

  Color _getRecommendationColor(String recommendation) {
    switch (recommendation.toLowerCase()) {
      case 'buy':
        return Colors.green;
      case 'sell':
        return Colors.red;
      case 'hold':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Color _getRiskLevelColor(String riskLevel) {
    switch (riskLevel.toLowerCase()) {
      case 'low':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'high':
        return Colors.red;
      default:
        return Colors.grey;
    }
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
          'Manage Analysis',
          style: TextStyle(
            color: ModernConstants.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: ModernConstants.primaryPurple),
            onPressed: () => _showAddEditDialog(),
            tooltip: 'Add New Analysis',
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: ModernConstants.textSecondary),
            onPressed: _loadAnalyses,
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
            Expanded(child: _buildAnalysesList()),
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
              Icons.analytics_rounded,
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
                  'Analysis Management',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${analyses.length} total analyses',
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
              hintText: 'Search analyses...',
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
              DropdownMenuItem(value: 'Published', child: Text('Published')),
              DropdownMenuItem(value: 'Draft', child: Text('Draft')),
              DropdownMenuItem(value: 'Technical', child: Text('Technical')),
              DropdownMenuItem(value: 'Fundamental', child: Text('Fundamental')),
              DropdownMenuItem(value: 'Market Sentiment', child: Text('Sentiment')),
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
              hintText: 'Search analyses...',
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
              DropdownMenuItem(value: 'Published', child: Text('Published')),
              DropdownMenuItem(value: 'Draft', child: Text('Draft')),
              DropdownMenuItem(value: 'Technical', child: Text('Technical')),
              DropdownMenuItem(value: 'Fundamental', child: Text('Fundamental')),
              DropdownMenuItem(value: 'Market Sentiment', child: Text('Market Sentiment')),
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

  Widget _buildAnalysesList() {
    if (isLoading) {
      return const LoadingWidget();
    }
    if (errorMessage != null) {
      return Center(child: Text(errorMessage!, style: const TextStyle(color: Colors.red)));
    }
    if (filteredAnalyses.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.analytics_outlined,
        title: 'No analyses found',
        message: 'Try adjusting your search or filters.',
      );
    }

    final isMobile = ResponsiveHelper.isMobile(context);
    if (isMobile) {
      return ListView.builder(
        itemCount: filteredAnalyses.length,
        itemBuilder: (context, index) {
          return _buildMobileAnalysisCard(filteredAnalyses[index]);
        },
      );
    } else {
      return _buildDesktopAnalysesTable();
    }
  }

  Widget _buildMobileAnalysisCard(Map<String, dynamic> analysis) {
    final confidenceScore = (analysis['confidenceScore'] ?? 0.0).toDouble();
    
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
              _buildAnalysisIcon(analysis['analysisType'] ?? ''),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      analysis['title'] ?? 'Untitled Analysis',
                      style: const TextStyle(
                        color: ModernConstants.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${analysis['currency']} • ${analysis['analysisType']}',
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
                  color: _getRecommendationColor(analysis['recommendation'] ?? '').withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  (analysis['recommendation'] ?? 'N/A').toUpperCase(),
                  style: TextStyle(
                    color: _getRecommendationColor(analysis['recommendation'] ?? ''),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            analysis['summary'] ?? 'No summary available',
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
                  color: _getRiskLevelColor(analysis['riskLevel'] ?? '').withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${analysis['riskLevel'] ?? 'N/A'} Risk',
                  style: TextStyle(
                    color: _getRiskLevelColor(analysis['riskLevel'] ?? ''),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: ModernConstants.primaryBlue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${confidenceScore.toStringAsFixed(0)}% Confidence',
                  style: const TextStyle(
                    color: ModernConstants.primaryBlue,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: analysis['isPublished'] == true
                      ? Colors.green.withOpacity(0.2)
                      : Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  analysis['isPublished'] == true ? 'PUBLISHED' : 'DRAFT',
                  style: TextStyle(
                    color: analysis['isPublished'] == true ? Colors.green : Colors.orange,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.visibility_rounded,
                size: 14,
                color: ModernConstants.textTertiary,
              ),
              const SizedBox(width: 4),
              Text(
                '${analysis['views'] ?? 0} views',
                style: const TextStyle(
                  color: ModernConstants.textTertiary,
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              Text(
                _getRelativeTime(analysis['createdAt']),
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
                onPressed: () => _showAnalysisDetails(analysis),
                icon: const Icon(
                  Icons.visibility_rounded,
                  color: ModernConstants.primaryBlue,
                  size: 20,
                ),
              ),
              IconButton(
                onPressed: () => _showAddEditDialog(analysis: analysis),
                icon: const Icon(
                  Icons.edit_rounded,
                  color: ModernConstants.primaryPurple,
                  size: 20,
                ),
              ),
              IconButton(
                onPressed: () => _deleteAnalysis(analysis),
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

  Widget _buildDesktopAnalysesTable() {
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
            DataColumn(label: Text('Analysis', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Currency', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Type', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Recommendation', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Risk', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Confidence', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Views', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Created', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: filteredAnalyses.map((analysis) {
            final confidenceScore = (analysis['confidenceScore'] ?? 0.0).toDouble();
            
            return DataRow(
              cells: [
                DataCell(
                  Row(
                    children: [
                      _buildAnalysisIcon(analysis['analysisType'] ?? ''),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          analysis['title'] ?? 'Untitled Analysis',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
                DataCell(Text(analysis['currency'] ?? 'N/A')),
                DataCell(Text(analysis['analysisType'] ?? 'N/A')),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getRecommendationColor(analysis['recommendation'] ?? '').withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      analysis['recommendation'] ?? 'N/A',
                      style: TextStyle(
                        color: _getRecommendationColor(analysis['recommendation'] ?? ''),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getRiskLevelColor(analysis['riskLevel'] ?? '').withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      analysis['riskLevel'] ?? 'N/A',
                      style: TextStyle(
                        color: _getRiskLevelColor(analysis['riskLevel'] ?? ''),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                DataCell(Text('${confidenceScore.toStringAsFixed(0)}%')),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: analysis['isPublished'] == true
                          ? Colors.green.withOpacity(0.2)
                          : Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      analysis['isPublished'] == true ? 'Published' : 'Draft',
                      style: TextStyle(
                        color: analysis['isPublished'] == true ? Colors.green : Colors.orange,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                DataCell(Text('${analysis['views'] ?? 0}')),
                DataCell(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _formatTimestamp(analysis['createdAt']),
                        style: const TextStyle(fontSize: 12),
                      ),
                      Text(
                        _getRelativeTime(analysis['createdAt']),
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
                        onPressed: () => _showAnalysisDetails(analysis),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_rounded, color: ModernConstants.primaryPurple),
                        onPressed: () => _showAddEditDialog(analysis: analysis),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                        onPressed: () => _deleteAnalysis(analysis),
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

  void _showAnalysisDetails(Map<String, dynamic> analysis) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ModernConstants.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            _buildAnalysisIcon(analysis['analysisType'] ?? ''),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                analysis['title'] ?? 'Analysis Details',
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
                _buildDetailCard('Currency', analysis['currency'] ?? 'N/A', Icons.currency_exchange_rounded),
                _buildDetailCard('Analysis Type', analysis['analysisType'] ?? 'N/A', Icons.category_rounded),
                _buildDetailCard('Recommendation', analysis['recommendation'] ?? 'N/A', Icons.recommend_rounded,
                  color: _getRecommendationColor(analysis['recommendation'] ?? '')),
                _buildDetailCard('Risk Level', analysis['riskLevel'] ?? 'N/A', Icons.warning_rounded,
                  color: _getRiskLevelColor(analysis['riskLevel'] ?? '')),
                _buildDetailCard('Confidence Score', '${(analysis['confidenceScore'] ?? 0.0).toStringAsFixed(1)}%', Icons.percent_rounded),
                _buildDetailCard('Time Horizon', analysis['timeHorizon'] ?? 'N/A', Icons.schedule_rounded),
                _buildDetailCard('Views', '${analysis['views'] ?? 0}', Icons.visibility_rounded),
                _buildDetailCard('Status', analysis['isPublished'] == true ? 'Published' : 'Draft', Icons.circle,
                  color: analysis['isPublished'] == true ? Colors.green : Colors.orange),
                _buildDetailCard('Author', analysis['authorName'] ?? 'Unknown', Icons.person_rounded),
                _buildDetailCard(
                  'Created', 
                  _formatTimestamp(analysis['createdAt']), 
                  Icons.calendar_today_rounded,
                  subtitle: _getRelativeTime(analysis['createdAt']),
                ),
                if (analysis['updatedAt'] != null)
                  _buildDetailCard(
                    'Last Updated', 
                    _formatTimestamp(analysis['updatedAt']), 
                    Icons.update_rounded,
                    subtitle: _getRelativeTime(analysis['updatedAt']),
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
                        'Summary',
                        style: TextStyle(
                          color: ModernConstants.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        analysis['summary'] ?? 'No summary available',
                        style: const TextStyle(
                          color: ModernConstants.textPrimary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                if ((analysis['keyPoints'] as List<String>?)?.isNotEmpty == true) ...[
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
                          'Key Points',
                          style: TextStyle(
                            color: ModernConstants.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...(analysis['keyPoints'] as List<String>).map((point) => 
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('• ', style: TextStyle(color: ModernConstants.primaryBlue)),
                                Expanded(
                                  child: Text(
                                    point,
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
                  const SizedBox(height: 8),
                ],
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
                        'Full Content',
                        style: TextStyle(
                          color: ModernConstants.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        analysis['content'] ?? 'No content available',
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

  void _showAddEditDialog({Map<String, dynamic>? analysis}) {
    final isEditing = analysis != null;
    final titleController = TextEditingController(text: analysis?['title'] ?? '');
    final currencyController = TextEditingController(text: analysis?['currency'] ?? '');
    final summaryController = TextEditingController(text: analysis?['summary'] ?? '');
    final contentController = TextEditingController(text: analysis?['content'] ?? '');
    final confidenceController = TextEditingController(text: analysis?['confidenceScore']?.toString() ?? '');
    final keyPointsController = TextEditingController(text: (analysis?['keyPoints'] as List<String>?)?.join('\n') ?? '');
    
    String selectedAnalysisType = analysis?['analysisType'] ?? 'Technical';
    String selectedRecommendation = analysis?['recommendation'] ?? 'Hold';
    String selectedRiskLevel = analysis?['riskLevel'] ?? 'Medium';
    String selectedTimeHorizon = analysis?['timeHorizon'] ?? 'Medium-term';
    bool isPublished = analysis?['isPublished'] ?? true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: ModernConstants.cardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            isEditing ? 'Edit Analysis' : 'Add New Analysis',
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
                    value: selectedAnalysisType,
                    decoration: const InputDecoration(
                      labelText: 'Analysis Type',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Technical', child: Text('Technical')),
                      DropdownMenuItem(value: 'Fundamental', child: Text('Fundamental')),
                      DropdownMenuItem(value: 'Market Sentiment', child: Text('Market Sentiment')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedAnalysisType = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: summaryController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Summary',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: contentController,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      labelText: 'Full Content',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedRecommendation,
                    decoration: const InputDecoration(
                      labelText: 'Recommendation',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Buy', child: Text('Buy')),
                      DropdownMenuItem(value: 'Sell', child: Text('Sell')),
                      DropdownMenuItem(value: 'Hold', child: Text('Hold')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedRecommendation = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedRiskLevel,
                    decoration: const InputDecoration(
                      labelText: 'Risk Level',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Low', child: Text('Low')),
                      DropdownMenuItem(value: 'Medium', child: Text('Medium')),
                      DropdownMenuItem(value: 'High', child: Text('High')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedRiskLevel = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: confidenceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Confidence Score (0-100)',
                      border: OutlineInputBorder(),
                      suffixText: '%',
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedTimeHorizon,
                    decoration: const InputDecoration(
                      labelText: 'Time Horizon',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Short-term', child: Text('Short-term')),
                      DropdownMenuItem(value: 'Medium-term', child: Text('Medium-term')),
                      DropdownMenuItem(value: 'Long-term', child: Text('Long-term')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedTimeHorizon = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: keyPointsController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Key Points (one per line)',
                      border: OutlineInputBorder(),
                      hintText: 'Enter each key point on a new line',
                    ),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Published'),
                    value: isPublished,
                    onChanged: (value) {
                      setState(() {
                        isPublished = value;
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
              onPressed: () => _saveAnalysis(
                isEditing: isEditing,
                analysisId: analysis?['id'],
                title: titleController.text,
                currency: currencyController.text,
                analysisType: selectedAnalysisType,
                summary: summaryController.text,
                content: contentController.text,
                recommendation: selectedRecommendation,
                riskLevel: selectedRiskLevel,
                confidenceScore: double.tryParse(confidenceController.text) ?? 0.0,
                timeHorizon: selectedTimeHorizon,
                keyPoints: keyPointsController.text.split('\n').where((point) => point.trim().isNotEmpty).toList(),
                isPublished: isPublished,
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

  Future<void> _saveAnalysis({
    required bool isEditing,
    String? analysisId,
    required String title,
    required String currency,
    required String analysisType,
    required String summary,
    required String content,
    required String recommendation,
    required String riskLevel,
    required double confidenceScore,
    required String timeHorizon,
    required List<String> keyPoints,
    required bool isPublished,
  }) async {
    if (title.isEmpty || currency.isEmpty || summary.isEmpty) {
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
      
      final analysisData = {
        'title': title,
        'currency': currency,
        'analysisType': analysisType,
        'content': content,
        'summary': summary,
        'recommendation': recommendation,
        'riskLevel': riskLevel,
        'confidenceScore': confidenceScore,
        'keyPoints': keyPoints,
        'timeHorizon': timeHorizon,
        'isPublished': isPublished,
        'updatedAt': FieldValue.serverTimestamp(),
        'authorId': userData?['id'] ?? '',
        'authorName': userData?['name'] ?? 'Admin',
      };

      if (isEditing && analysisId != null) {
        await FirebaseFirestore.instance
            .collection('analyses')
            .doc(analysisId)
            .update(analysisData);
      } else {
        analysisData['createdAt'] = FieldValue.serverTimestamp();
        analysisData['views'] = 0;
        await FirebaseFirestore.instance
            .collection('analyses')
            .add(analysisData);
      }

      Navigator.of(context).pop();
      _loadAnalyses();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditing ? 'Analysis updated successfully' : 'Analysis added successfully'),
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

  Future<void> _deleteAnalysis(Map<String, dynamic> analysis) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ModernConstants.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Delete Analysis',
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to delete "${analysis['title'] ?? 'this analysis'}"? This action cannot be undone.',
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
            .collection('analyses')
            .doc(analysis['id'])
            .delete();
        
        _loadAnalyses();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${analysis['title'] ?? 'Analysis'} deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting analysis: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
