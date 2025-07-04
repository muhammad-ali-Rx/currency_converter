import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../model/Feedback.model.dart';
import '../../../services/Feedback-service.dart';

// Modern Constants with proper color definitions
class ModernConstants {
  static const Color backgroundColor = Color(0xFF0F0F23);
  static const Color cardBackground = Color(0xFF1A1A2E);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color textTertiary = Color(0xFF6B7280);
  static const Color accent = Color(0xFF10B981);
  static const Color accentSecondary = Color(0xFF059669);
  
  // Card gradient
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1A1A2E),
      Color(0xFF16213E),
    ],
  );
  
  // Card shadow
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 20,
      spreadRadius: 0,
      offset: Offset(0, 4),
    ),
  ];
}

// Responsive Helper
class ResponsiveHelper {
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 768;
  }
  
  static EdgeInsets getScreenPadding(BuildContext context) {
    return EdgeInsets.symmetric(
      horizontal: isMobile(context) ? 16 : 24,
      vertical: 16,
    );
  }
  
  static double getTitleFontSize(BuildContext context) {
    return isMobile(context) ? 24 : 28;
  }
  
  static double getSubtitleFontSize(BuildContext context) {
    return isMobile(context) ? 14 : 16;
  }
}

// Loading Widget
class LoadingWidget extends StatelessWidget {
  final String message;
  
  const LoadingWidget({super.key, required this.message});
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(ModernConstants.accent),
            strokeWidth: 3,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              color: ModernConstants.textSecondary,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

// Empty State Widget
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionText;
  final VoidCallback? onAction;
  
  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionText,
    this.onAction,
  });
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: ModernConstants.textTertiary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                icon,
                size: 64,
                color: ModernConstants.textTertiary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                color: ModernConstants.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(
                color: ModernConstants.textSecondary,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(actionText!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ModernConstants.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ManageFeedbackScreen extends StatefulWidget {
  const ManageFeedbackScreen({super.key});

  @override
  State<ManageFeedbackScreen> createState() => _ManageFeedbackScreenState();
}

class _ManageFeedbackScreenState extends State<ManageFeedbackScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'All';
  String _selectedPriority = 'All';
  bool _isLoading = false;
  Map<String, dynamic> _stats = {};
  String searchQuery = '';
  String? errorMessage;
  
  // Store the feedback data to avoid re-fetching
  List<FeedbackModel> _allFeedbackData = [];
  bool _dataLoaded = false;

  // Updated Tab data with correct category mapping
  final List<Map<String, dynamic>> _tabs = [
    {
      'title': 'All',
      'icon': Icons.dashboard_rounded,
      'color': ModernConstants.accent,
      'category': 'all',
    },
    {
      'title': 'General',
      'icon': Icons.feedback_rounded,
      'color': const Color(0xFF3B82F6),
      'category': 'feedback',
    },
    {
      'title': 'Issues',
      'icon': Icons.bug_report_rounded,
      'color': const Color(0xFFEF4444),
      'category': 'issue',
    },
    {
      'title': 'Ratings',
      'icon': Icons.star_rounded,
      'color': const Color(0xFFF59E0B),
      'category': 'rating',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadAllData();
    
    // Add listener to tab controller
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {}); // Refresh UI when tab changes
        print('Tab changed to: ${_tabs[_tabController.index]['category']}');
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadAllData() async {
    setState(() {
      _isLoading = true;
      errorMessage = null;
    });
    
    try {
      // Load stats
      final stats = await FeedbackService.getFeedbackStats();
      
      // Load all feedback data
      final feedbackStream = FeedbackService.getFeedbackStream();
      feedbackStream.listen((feedbackList) {
        if (mounted) {
          setState(() {
            _allFeedbackData = feedbackList;
            _dataLoaded = true;
            _isLoading = false;
            _stats = stats;
          });
          print('Loaded ${feedbackList.length} feedback items');
          
          // Debug: Print categories and types
          if (feedbackList.isNotEmpty) {
            print('Categories: ${feedbackList.map((e) => e.category).toSet().toList()}');
            print('Types: ${feedbackList.map((e) => e.type).toSet().toList()}');
            print('Ratings: ${feedbackList.where((e) => e.rating != null).map((e) => '${e.type}: ${e.rating}').toList()}');
          }
        }
      }, onError: (error) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            errorMessage = 'Failed to load feedback: ${error.toString()}';
          });
          print('Error loading feedback: $error');
        }
      });
      
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          errorMessage = 'Failed to load data: ${e.toString()}';
        });
        print('Error loading data: $e');
      }
    }
  }

  List<FeedbackModel> _getFilteredData(String category) {
    if (!_dataLoaded || _allFeedbackData.isEmpty) {
      return [];
    }

    List<FeedbackModel> filteredData = List.from(_allFeedbackData);

    // Filter by category
    if (category != 'all') {
      filteredData = filteredData.where((item) {
        switch (category) {
          case 'feedback':
            return item.category.toLowerCase() == 'feedback' || 
                   item.type.toLowerCase().contains('feedback') ||
                   item.type.toLowerCase().contains('general') ||
                   item.type.toLowerCase().contains('suggestion');
          case 'issue':
            return item.category.toLowerCase() == 'issue' || 
                   item.type.toLowerCase().contains('bug') ||
                   item.type.toLowerCase().contains('crash') ||
                   item.type.toLowerCase().contains('problem') ||
                   item.type.toLowerCase().contains('issue');
          case 'rating':
            return item.category.toLowerCase() == 'rating' || 
                   item.type.toLowerCase().contains('rating') ||
                   item.rating != null;
          default:
            return item.category.toLowerCase() == category.toLowerCase();
        }
      }).toList();
    }

    print('Filtered data for category "$category": ${filteredData.length} items');

    // Filter by status
    if (_selectedFilter != 'All') {
      filteredData = filteredData.where((item) => item.status == _selectedFilter).toList();
    }

    // Filter by priority
    if (_selectedPriority != 'All') {
      filteredData = filteredData.where((item) => item.priority == _selectedPriority).toList();
    }

    // Filter by search query
    if (searchQuery.isNotEmpty) {
      filteredData = filteredData.where((item) {
        final query = searchQuery.toLowerCase();
        return item.name.toLowerCase().contains(query) ||
               item.email.toLowerCase().contains(query) ||
               item.type.toLowerCase().contains(query) ||
               item.message.toLowerCase().contains(query);
      }).toList();
    }

    return filteredData;
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    
    return Scaffold(
      backgroundColor: ModernConstants.backgroundColor,
      appBar: AppBar(
        backgroundColor: ModernConstants.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: ModernConstants.textPrimary,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Manage User Feedback',
          style: TextStyle(
            color: ModernConstants.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _loadAllData,
            icon: const Icon(
              Icons.refresh_rounded,
              color: ModernConstants.textSecondary,
            ),
            tooltip: 'Refresh',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Fixed Header Section
          Container(
            color: ModernConstants.backgroundColor,
            child: Column(
              children: [
                Padding(
                  padding: ResponsiveHelper.getScreenPadding(context),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      SizedBox(height: isMobile ? 16 : 20),
                      _buildSearchBar(),
                      SizedBox(height: isMobile ? 16 : 20),
                      _buildFilters(),
                      const SizedBox(height: 16),
                      _buildStats(),
                      const SizedBox(height: 20),
                      _buildTabBar(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Scrollable Content
          Expanded(
            child: _buildTabContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Feedback Management',
          style: TextStyle(
            color: ModernConstants.textPrimary,
            fontSize: ResponsiveHelper.getTitleFontSize(context),
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Manage and respond to user feedback',
          style: TextStyle(
            color: ModernConstants.textSecondary,
            fontSize: ResponsiveHelper.getSubtitleFontSize(context),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        gradient: ModernConstants.cardGradient,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ModernConstants.textTertiary.withOpacity(0.2),
        ),
      ),
      child: TextField(
        onChanged: (value) => setState(() => searchQuery = value),
        style: const TextStyle(color: ModernConstants.textPrimary),
        decoration: InputDecoration(
          hintText: 'Search feedback, users, types...',
          hintStyle: const TextStyle(color: ModernConstants.textTertiary),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: ModernConstants.textSecondary,
          ),
          suffixIcon: searchQuery.isNotEmpty
              ? IconButton(
                  onPressed: () => setState(() => searchQuery = ''),
                  icon: const Icon(
                    Icons.clear_rounded,
                    color: ModernConstants.textSecondary,
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Row(
      children: [
        Expanded(
          child: _buildFilterDropdown(
            'Status',
            _selectedFilter,
            ['All', 'New', 'In Progress', 'Resolved', 'Closed'],
            (value) => setState(() => _selectedFilter = value!),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildFilterDropdown(
            'Priority',
            _selectedPriority,
            ['All', 'Low', 'Medium', 'High', 'Critical'],
            (value) => setState(() => _selectedPriority = value!),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterDropdown(
    String label,
    String value,
    List<String> items,
    Function(String?) onChanged,
  ) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        gradient: ModernConstants.cardGradient,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: ModernConstants.textTertiary.withOpacity(0.2),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          style: const TextStyle(
            color: ModernConstants.textPrimary,
            fontSize: 14,
          ),
          dropdownColor: ModernConstants.cardBackground,
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildStats() {
    if (_isLoading && !_dataLoaded) {
      return Container(
        height: 120,
        decoration: BoxDecoration(
          gradient: ModernConstants.cardGradient,
          borderRadius: BorderRadius.circular(12),
          boxShadow: ModernConstants.cardShadow,
          border: Border.all(
            color: ModernConstants.textTertiary.withOpacity(0.2),
          ),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(ModernConstants.accent),
            strokeWidth: 3,
          ),
        ),
      );
    }

    final totalFeedback = _stats['total'] ?? _allFeedbackData.length;
    final newFeedback = _stats['new'] ?? _allFeedbackData.where((f) => f.status == 'New').length;
    final highPriority = _stats['highPriority'] ?? _allFeedbackData.where((f) => f.priority == 'High').length;
    final avgRating = _stats['averageRating'] ?? (_allFeedbackData.where((f) => f.rating != null).isNotEmpty 
        ? _allFeedbackData.where((f) => f.rating != null).map((f) => f.rating!).reduce((a, b) => a + b) / _allFeedbackData.where((f) => f.rating != null).length 
        : 0.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: ModernConstants.cardGradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: ModernConstants.cardShadow,
        border: Border.all(
          color: ModernConstants.textTertiary.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Expanded(child: _buildStatCard('Total', totalFeedback.toString(), Icons.feedback_rounded, ModernConstants.accent)),
          Expanded(child: _buildStatCard('New', newFeedback.toString(), Icons.fiber_new_rounded, const Color(0xFF10B981))),
          Expanded(child: _buildStatCard('High Priority', highPriority.toString(), Icons.priority_high_rounded, const Color(0xFFEF4444))),
          Expanded(child: _buildStatCard('Avg Rating', avgRating.toStringAsFixed(1), Icons.star_rounded, const Color(0xFFF59E0B))),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: ModernConstants.backgroundColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
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
            label,
            style: const TextStyle(
              color: ModernConstants.textSecondary,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    final isMobile = ResponsiveHelper.isMobile(context);
    
    return Container(
      height: 50,
      decoration: BoxDecoration(
        gradient: ModernConstants.cardGradient,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ModernConstants.textTertiary.withOpacity(0.2),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: false,
        indicator: BoxDecoration(
          gradient: const LinearGradient(
            colors: [ModernConstants.accent, ModernConstants.accentSecondary],
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: ModernConstants.textSecondary,
        labelStyle: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: isMobile ? 11 : 13,
        ),
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: isMobile ? 11 : 13,
        ),
        indicatorPadding: const EdgeInsets.all(4),
        tabs: _tabs.map((tab) {
          return Tab(
            height: 42,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    tab['icon'],
                    size: isMobile ? 16 : 18,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      tab['title'],
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTabContent() {
    if (errorMessage != null) {
      return EmptyStateWidget(
        icon: Icons.error_outline,
        title: 'Error loading feedback',
        message: errorMessage!,
        actionText: 'Retry',
        onAction: _loadAllData,
      );
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _buildFeedbackList('all'),
        _buildFeedbackList('feedback'),
        _buildFeedbackList('issue'),
        _buildFeedbackList('rating'),
      ],
    );
  }

  Widget _buildFeedbackList(String category) {
    // Show loading only if data is not loaded yet
    if (_isLoading && !_dataLoaded) {
      return const LoadingWidget(message: 'Loading feedback...');
    }

    // Get filtered data
    final filteredData = _getFilteredData(category);

    if (filteredData.isEmpty) {
      String emptyMessage;
      if (_allFeedbackData.isEmpty) {
        emptyMessage = 'No feedback has been submitted yet';
      } else if (searchQuery.isNotEmpty) {
        emptyMessage = 'No feedback matches your search criteria';
      } else {
        emptyMessage = 'No ${category == 'all' ? 'feedback' : category} found';
      }

      return EmptyStateWidget(
        icon: _tabs.firstWhere((tab) => tab['category'] == category)['icon'],
        title: 'No feedback found',
        message: emptyMessage,
        actionText: searchQuery.isNotEmpty ? 'Clear Search' : (_allFeedbackData.isEmpty ? 'Refresh' : null),
        onAction: searchQuery.isNotEmpty 
            ? () => setState(() => searchQuery = '') 
            : (_allFeedbackData.isEmpty ? _loadAllData : null),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        _loadAllData();
      },
      color: ModernConstants.accent,
      backgroundColor: ModernConstants.cardBackground,
      child: ListView.builder(
        padding: ResponsiveHelper.getScreenPadding(context).copyWith(top: 16),
        itemCount: filteredData.length,
        itemBuilder: (context, index) {
          return _buildFeedbackCard(filteredData[index]);
        },
      ),
    );
  }

  Widget _buildFeedbackCard(FeedbackModel feedback) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final priorityColor = _getPriorityColor(feedback.priority);
    final statusColor = _getStatusColor(feedback.status);

    return InkWell(
      onTap: () => _viewDetails(feedback),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(isMobile ? 16 : 18),
        decoration: BoxDecoration(
          gradient: ModernConstants.cardGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: ModernConstants.cardShadow,
          border: Border.all(color: priorityColor.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: priorityColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getTypeIcon(feedback.type),
                    color: priorityColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        feedback.type,
                        style: const TextStyle(
                          color: ModernConstants.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        DateFormat('MMM dd, yyyy • HH:mm').format(feedback.timestamp),
                        style: const TextStyle(
                          color: ModernConstants.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(feedback.status, statusColor),
                const SizedBox(width: 8),
                _buildPriorityChip(feedback.priority, priorityColor),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Content
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: priorityColor,
                  child: Text(
                    feedback.name.isNotEmpty ? feedback.name[0].toUpperCase() : 'U',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        feedback.name,
                        style: const TextStyle(
                          color: ModernConstants.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        feedback.email,
                        style: const TextStyle(
                          color: ModernConstants.textSecondary,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (feedback.rating != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star,
                          color: Color(0xFFF59E0B),
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${feedback.rating}',
                          style: const TextStyle(
                            color: Color(0xFFF59E0B),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Message preview
            Text(
              feedback.message,
              style: const TextStyle(
                color: ModernConstants.textPrimary,
                fontSize: 14,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            
            const SizedBox(height: 12),
            
            // Action buttons
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 14,
                  color: ModernConstants.textTertiary,
                ),
                const SizedBox(width: 4),
                Text(
                  DateFormat('MMM dd, yyyy').format(feedback.timestamp),
                  style: const TextStyle(
                    color: ModernConstants.textTertiary,
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                _buildActionButtons(feedback),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildPriorityChip(String priority, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        priority,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildActionButtons(FeedbackModel feedback) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: () => _updateStatus(feedback.id),
          icon: const Icon(Icons.edit_rounded, size: 16),
          color: ModernConstants.accent,
          tooltip: 'Update Status',
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          padding: const EdgeInsets.all(4),
        ),
        IconButton(
          onPressed: () => _deleteFeedback(feedback.id),
          icon: const Icon(Icons.delete_rounded, size: 16),
          color: const Color(0xFFEF4444),
          tooltip: 'Delete',
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          padding: const EdgeInsets.all(4),
        ),
      ],
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'Low':
        return const Color(0xFF10B981);
      case 'Medium':
        return const Color(0xFFF59E0B);
      case 'High':
        return const Color(0xFFEF4444);
      case 'Critical':
        return const Color(0xFF8B5CF6);
      default:
        return ModernConstants.textTertiary;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'New':
        return const Color(0xFF3B82F6);
      case 'In Progress':
        return const Color(0xFFF59E0B);
      case 'Resolved':
        return const Color(0xFF10B981);
      case 'Closed':
        return ModernConstants.textTertiary;
      default:
        return ModernConstants.textTertiary;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'Bug Report':
      case 'App Crash':
      case 'Login Issue':
      case 'Data Sync':
      case 'UI Problem':
        return Icons.bug_report_rounded;
      case 'Feature Request':
        return Icons.lightbulb_rounded;
      case 'App Rating':
        return Icons.star_rounded;
      case 'Performance':
        return Icons.speed_rounded;
      case 'UI/UX Feedback':
        return Icons.design_services_rounded;
      case 'General Feedback':
      case 'Suggestion':
      default:
        return Icons.feedback_rounded;
    }
  }

  void _updateStatus(String id) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            gradient: ModernConstants.cardGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Color(0x4D000000),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [ModernConstants.accent, ModernConstants.accentSecondary],
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.edit_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Update Status',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded, color: Colors.white),
                    ),
                  ],
                ),
              ),
              
              // Content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: ['New', 'In Progress', 'Resolved', 'Closed'].map((status) {
                    final color = _getStatusColor(status);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            _getStatusIcon(status),
                            color: color,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          status,
                          style: const TextStyle(
                            color: ModernConstants.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        tileColor: ModernConstants.backgroundColor.withOpacity(0.5),
                        onTap: () async {
                          Navigator.pop(context);
                          final success = await FeedbackService.updateFeedbackStatus(id, status);
                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    const Icon(Icons.check_circle, color: Colors.white),
                                    const SizedBox(width: 8),
                                    Text('Status updated to $status'),
                                  ],
                                ),
                                backgroundColor: ModernConstants.accent,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            _loadAllData(); // Refresh data
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Row(
                                  children: [
                                    Icon(Icons.error, color: Colors.white),
                                    SizedBox(width: 8),
                                    Text('Failed to update status'),
                                  ],
                                ),
                                backgroundColor: Colors.red,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'New':
        return Icons.fiber_new_rounded;
      case 'In Progress':
        return Icons.hourglass_empty_rounded;
      case 'Resolved':
        return Icons.check_circle_rounded;
      case 'Closed':
        return Icons.close_rounded;
      default:
        return Icons.help_rounded;
    }
  }

  void _viewDetails(FeedbackModel feedback) {
    showDialog(
      context: context,
      builder: (context) => FeedbackDetailsDialog(
        feedback: feedback,
        onUpdate: () {
          _loadAllData();
        },
        onDelete: () {
          _loadAllData();
        },
      ),
    );
  }

  void _deleteFeedback(String id) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            gradient: ModernConstants.cardGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Color(0x4D000000),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.warning_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Delete Feedback',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded, color: Colors.white),
                    ),
                  ],
                ),
              ),
              
              // Content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text(
                      'Are you sure you want to delete this feedback? This action cannot be undone.',
                      style: TextStyle(
                        color: ModernConstants.textSecondary,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: ModernConstants.textSecondary,
                              side: const BorderSide(color: ModernConstants.textSecondary),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              Navigator.pop(context);
                              final success = await FeedbackService.deleteFeedback(id);
                              if (success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Row(
                                      children: [
                                        Icon(Icons.check_circle, color: Colors.white),
                                        SizedBox(width: 8),
                                        Text('Feedback deleted successfully'),
                                      ],
                                    ),
                                    backgroundColor: ModernConstants.accent,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                                _loadAllData(); // Refresh data
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Row(
                                      children: [
                                        Icon(Icons.error, color: Colors.white),
                                        SizedBox(width: 8),
                                        Text('Failed to delete feedback'),
                                      ],
                                    ),
                                    backgroundColor: Colors.red,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFEF4444),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text('Delete'),
                          ),
                        ),
                      ],
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
}

// Feedback Details Dialog (keeping the same as before)
class FeedbackDetailsDialog extends StatefulWidget {
  final FeedbackModel feedback;
  final VoidCallback onUpdate;
  final VoidCallback onDelete;

  const FeedbackDetailsDialog({
    super.key,
    required this.feedback,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  State<FeedbackDetailsDialog> createState() => _FeedbackDetailsDialogState();
}

class _FeedbackDetailsDialogState extends State<FeedbackDetailsDialog> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        decoration: BoxDecoration(
          gradient: ModernConstants.cardGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Color(0x4D000000),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: _buildContent(),
              ),
            ),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final priorityColor = _getPriorityColor(widget.feedback.priority);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [priorityColor, priorityColor.withOpacity(0.8)],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getTypeIcon(widget.feedback.type),
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Feedback Details',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.feedback.type,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close_rounded, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailSection(
          'Feedback Information',
          Icons.feedback_rounded,
          [
            _buildDetailRow('ID', widget.feedback.id),
            _buildDetailRow('Type', widget.feedback.type),
            _buildDetailRow('Status', widget.feedback.status),
            _buildDetailRow('Priority', widget.feedback.priority),
            _buildDetailRow('Category', widget.feedback.category),
            _buildDetailRow('Date', DateFormat('MMM dd, yyyy • HH:mm:ss').format(widget.feedback.timestamp)),
          ],
        ),
        const SizedBox(height: 20),
        _buildDetailSection(
          'User Information',
          Icons.person_rounded,
          [
            _buildDetailRow('Name', widget.feedback.name),
            _buildDetailRow('Email', widget.feedback.email),
          ],
        ),
        const SizedBox(height: 20),
        _buildDetailSection(
          'Message',
          Icons.message_rounded,
          [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ModernConstants.backgroundColor.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                widget.feedback.message,
                style: const TextStyle(
                  color: ModernConstants.textPrimary,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        if (widget.feedback.steps != null && widget.feedback.steps!.isNotEmpty) ...[
          const SizedBox(height: 20),
          _buildDetailSection(
            'Steps to Reproduce',
            Icons.list_alt_rounded,
            [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: ModernConstants.backgroundColor.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.feedback.steps!,
                  style: const TextStyle(
                    color: ModernConstants.textPrimary,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ],
        if (widget.feedback.rating != null) ...[
          const SizedBox(height: 20),
          _buildDetailSection(
            'Rating',
            Icons.star_rounded,
            [
              Row(
                children: [
                  ...List.generate(5, (index) {
                    return Icon(
                      index < widget.feedback.rating! ? Icons.star : Icons.star_border,
                      color: const Color(0xFFF59E0B),
                      size: 24,
                    );
                  }),
                  const SizedBox(width: 8),
                  Text(
                    '${widget.feedback.rating}/5 stars',
                    style: const TextStyle(
                      color: ModernConstants.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildDetailSection(String title, IconData icon, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ModernConstants.backgroundColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ModernConstants.textTertiary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: ModernConstants.accent, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: ModernConstants.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                color: ModernConstants.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: ModernConstants.textPrimary,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ModernConstants.backgroundColor.withOpacity(0.5),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: isLoading ? null : () {
                Navigator.pop(context);
                // Update status functionality can be added here
              },
              icon: const Icon(Icons.edit_rounded, size: 18),
              label: const Text('Update Status'),
              style: OutlinedButton.styleFrom(
                foregroundColor: ModernConstants.accent,
                side: const BorderSide(color: ModernConstants.accent),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: isLoading ? null : () {
                Navigator.pop(context);
                // Delete functionality will be handled by parent
              },
              icon: const Icon(Icons.delete_rounded, size: 18),
              label: const Text('Delete'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFEF4444),
                side: const BorderSide(color: Color(0xFFEF4444)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'Low':
        return const Color(0xFF10B981);
      case 'Medium':
        return const Color(0xFFF59E0B);
      case 'High':
        return const Color(0xFFEF4444);
      case 'Critical':
        return const Color(0xFF8B5CF6);
      default:
        return ModernConstants.textTertiary;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'Bug Report':
      case 'App Crash':
      case 'Login Issue':
      case 'Data Sync':
      case 'UI Problem':
        return Icons.bug_report_rounded;
      case 'Feature Request':
        return Icons.lightbulb_rounded;
      case 'App Rating':
        return Icons.star_rounded;
      case 'Performance':
        return Icons.speed_rounded;
      case 'UI/UX Feedback':
        return Icons.design_services_rounded;
      case 'General Feedback':
      case 'Suggestion':
      default:
        return Icons.feedback_rounded;
    }
  }
}