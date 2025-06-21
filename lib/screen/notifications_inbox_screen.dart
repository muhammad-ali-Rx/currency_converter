import 'package:flutter/material.dart';
import 'package:currency_converter/model/app_notification.dart';
import 'package:currency_converter/services/Enhanced_Notification.dart';

class NotificationsInboxScreen extends StatefulWidget {
  const NotificationsInboxScreen({super.key});

  @override
  State<NotificationsInboxScreen> createState() => _NotificationsInboxScreenState();
}

class _NotificationsInboxScreenState extends State<NotificationsInboxScreen> {
  final EnhancedNotificationService _notificationService = EnhancedNotificationService();
  List<AppNotification> _notifications = [];
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadNotifications();
    _notificationService.notificationStream.listen((notifications) {
      if (mounted) {
        setState(() => _notifications = notifications);
      }
    });
  }

  void _loadNotifications() {
    _notifications = _notificationService.getNotifications();
  }

  List<AppNotification> get _filteredNotifications {
    switch (_selectedFilter) {
      case 'unread':
        return _notifications.where((n) => !n.isRead).toList();
      case 'alerts':
        return _notifications.where((n) => n.type == NotificationType.rateAlert).toList();
      case 'updates':
        return _notifications.where((n) => n.type == NotificationType.appUpdate).toList();
      case 'news':
        return _notifications.where((n) => n.type == NotificationType.marketNews).toList();
      default:
        return _notifications;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F23),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F23),
        title: const Text(
          'Notifications',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            color: const Color(0xFF1A1A2E),
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'mark_all_read',
                child: Row(
                  children: [
                    Icon(Icons.mark_email_read, color: Color(0xFF8A94A6), size: 20),
                    SizedBox(width: 8),
                    Text('Mark All Read', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clear_all',
                child: Row(
                  children: [
                    Icon(Icons.clear_all, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Text('Clear All', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterTabs(),
          Expanded(
            child: _filteredNotifications.isEmpty
                ? _buildEmptyState()
                : _buildNotificationsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    final filters = [
      {'key': 'all', 'label': 'All', 'count': _notifications.length},
      {'key': 'unread', 'label': 'Unread', 'count': _notifications.where((n) => !n.isRead).length},
      {'key': 'alerts', 'label': 'Alerts', 'count': _notifications.where((n) => n.type == NotificationType.rateAlert).length},
      {'key': 'updates', 'label': 'Updates', 'count': _notifications.where((n) => n.type == NotificationType.appUpdate).length},
    ];

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedFilter == filter['key'];
          
          return Container(
            margin: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
            child: FilterChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(filter['label'] as String),
                  if ((filter['count'] as int) > 0) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : const Color.fromARGB(255, 10, 108, 236),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${filter['count']}',
                        style: TextStyle(
                          color: isSelected ? const Color.fromARGB(255, 10, 108, 236) : Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() => _selectedFilter = filter['key'] as String);
              },
              backgroundColor: const Color(0xFF1A1A2E),
              selectedColor: const Color.fromARGB(255, 10, 108, 236).withOpacity(0.3),
              labelStyle: TextStyle(
                color: isSelected ? const Color.fromARGB(255, 10, 108, 236) : Colors.white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              side: BorderSide(
                color: isSelected 
                    ? const Color.fromARGB(255, 10, 108, 236)
                    : const Color(0xFF8A94A6).withOpacity(0.3),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 10, 108, 236).withOpacity(0.1),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              _getEmptyStateIcon(),
              size: 64,
              color: const Color.fromARGB(255, 10, 108, 236),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _getEmptyStateTitle(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _getEmptyStateSubtitle(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF8A94A6),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getEmptyStateIcon() {
    switch (_selectedFilter) {
      case 'unread':
        return Icons.mark_email_read;
      case 'alerts':
        return Icons.notifications_off;
      case 'updates':
        return Icons.system_update;
      case 'news':
        return Icons.article;
      default:
        return Icons.inbox;
    }
  }

  String _getEmptyStateTitle() {
    switch (_selectedFilter) {
      case 'unread':
        return 'All Caught Up!';
      case 'alerts':
        return 'No Rate Alerts';
      case 'updates':
        return 'No App Updates';
      case 'news':
        return 'No Market News';
      default:
        return 'No Notifications';
    }
  }

  String _getEmptyStateSubtitle() {
    switch (_selectedFilter) {
      case 'unread':
        return 'You\'ve read all your notifications.\nGreat job staying informed!';
      case 'alerts':
        return 'Rate alert notifications will\nappear here when triggered.';
      case 'updates':
        return 'App update notifications will\nappear here when available.';
      case 'news':
        return 'Market news notifications will\nappear here when enabled.';
      default:
        return 'Your notifications will appear here.\nStay tuned for important updates!';
    }
  }

  Widget _buildNotificationsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredNotifications.length,
      itemBuilder: (context, index) {
        final notification = _filteredNotifications[index];
        return _buildNotificationCard(notification);
      },
    );
  }

  Widget _buildNotificationCard(AppNotification notification) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: notification.isRead ? const Color(0xFF1A1A2E) : const Color(0xFF1A1A2E).withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: notification.isRead 
              ? Colors.transparent
              : const Color.fromARGB(255, 10, 108, 236).withOpacity(0.3),
          width: notification.isRead ? 0 : 1,
        ),
      ),
      child: InkWell(
        onTap: () => _handleNotificationTap(notification),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getNotificationColor(notification.type).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getNotificationIcon(notification.type),
                      color: _getNotificationColor(notification.type),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                notification.title,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.bold,
                                ),
                              ),
                            ),
                            if (!notification.isRead)
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color.fromARGB(255, 10, 108, 236),
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          notification.body,
                          style: const TextStyle(
                            color: Color(0xFF8A94A6),
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              _formatTimestamp(notification.timestamp),
                              style: const TextStyle(
                                color: Color(0xFF8A94A6),
                                fontSize: 12,
                              ),
                            ),
                            const Spacer(),
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert, color: Color(0xFF8A94A6), size: 16),
                              color: const Color(0xFF1A1A2E),
                              onSelected: (value) => _handleNotificationAction(value, notification),
                              itemBuilder: (context) => [
                                if (!notification.isRead)
                                  const PopupMenuItem(
                                    value: 'mark_read',
                                    child: Row(
                                      children: [
                                        Icon(Icons.mark_email_read, color: Color(0xFF8A94A6), size: 16),
                                        SizedBox(width: 8),
                                        Text('Mark as Read', style: TextStyle(color: Colors.white, fontSize: 14)),
                                      ],
                                    ),
                                  ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete, color: Colors.red, size: 16),
                                      SizedBox(width: 8),
                                      Text('Delete', style: TextStyle(color: Colors.red, fontSize: 14)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
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

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.rateAlert:
        return Icons.trending_up;
      case NotificationType.appUpdate:
        return Icons.system_update;
      case NotificationType.marketNews:
        return Icons.article;
      case NotificationType.weeklyReport:
        return Icons.assessment;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.rateAlert:
        return Colors.orange;
      case NotificationType.appUpdate:
        return const Color.fromARGB(255, 10, 108, 236);
      case NotificationType.marketNews:
        return Colors.green;
      case NotificationType.weeklyReport:
        return Colors.purple;
      default:
        return const Color(0xFF8A94A6);
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  void _handleNotificationTap(AppNotification notification) async {
    if (!notification.isRead) {
      await _notificationService.markAsRead(notification.id);
    }
    
    if (notification.actionUrl != null) {
      print('Navigate to: ${notification.actionUrl}');
    }
  }

  void _handleNotificationAction(String action, AppNotification notification) async {
    switch (action) {
      case 'mark_read':
        await _notificationService.markAsRead(notification.id);
        break;
      case 'delete':
        await _notificationService.deleteNotification(notification.id);
        break;
    }
  }

  void _handleMenuAction(String action) async {
    switch (action) {
      case 'mark_all_read':
        await _notificationService.markAllAsRead();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('All notifications marked as read'),
              backgroundColor: Color.fromARGB(255, 10, 108, 236),
            ),
          );
        }
        break;
      case 'clear_all':
        _showClearAllDialog();
        break;
    }
  }

  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0F0F23),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text(
          'Clear All Notifications',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Are you sure you want to delete all notifications? This action cannot be undone.',
          style: TextStyle(color: Color(0xFF8A94A6)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF8A94A6))),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _notificationService.clearAllNotifications();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All notifications cleared'),
                    backgroundColor: Color.fromARGB(255, 10, 108, 236),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}