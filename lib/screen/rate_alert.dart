import 'package:currency_converter/model/Rate_Alerts.dart';
import 'package:currency_converter/screen/create_alert.dart';
import 'package:currency_converter/services/rate_alert.dart';
import 'package:flutter/material.dart';


class RateAlertsScreen extends StatefulWidget {
  const RateAlertsScreen({super.key});

  @override
  State<RateAlertsScreen> createState() => _RateAlertsScreenState();
}

class _RateAlertsScreenState extends State<RateAlertsScreen> {
  final RateAlertService _alertService = RateAlertService();
  List<RateAlert> _alerts = [];

  @override
  void initState() {
    super.initState();
    _loadAlerts();
  }

  Future<void> _loadAlerts() async {
    await _alertService.loadAlerts();
    setState(() {
      _alerts = _alertService.getAlerts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F23),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F23),
        title: const Text(
          'Rate Alerts',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: _alerts.isEmpty ? _buildEmptyState() : _buildAlertsList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToCreateAlert(),
        backgroundColor: const Color.fromARGB(255, 10, 108, 236),
        child: const Icon(Icons.add, color: Colors.white),
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
            child: const Icon(
              Icons.notifications_off,
              size: 64,
              color: Color.fromARGB(255, 10, 108, 236),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Rate Alerts',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Create your first rate alert to get notified\nwhen exchange rates reach your target',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF8A94A6),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => _navigateToCreateAlert(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 10, 108, 236),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.add),
            label: const Text('Create Alert'),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _alerts.length,
      itemBuilder: (context, index) {
        final alert = _alerts[index];
        return _buildAlertCard(alert);
      },
    );
  }

  Widget _buildAlertCard(RateAlert alert) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: alert.isActive 
            ? const Color.fromARGB(255, 10, 108, 236).withOpacity(0.3)
            : Colors.grey.withOpacity(0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 10, 108, 236).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${alert.fromCurrency}/${alert.toCurrency}',
                        style: const TextStyle(
                          color: Color.fromARGB(255, 10, 108, 236),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: alert.isActive ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        alert.isActive ? 'Active' : 'Triggered',
                        style: TextStyle(
                          color: alert.isActive ? Colors.green : Colors.grey,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Color(0xFF8A94A6)),
                  color: const Color(0xFF1A1A2E),
                  onSelected: (value) => _handleMenuAction(value, alert),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, color: Color(0xFF8A94A6), size: 20),
                          SizedBox(width: 8),
                          Text('Edit', style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red, size: 20),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.trending_up,
                  color: Color(0xFF8A94A6),
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  'Alert when ${alert.condition} ${alert.targetRate.toStringAsFixed(4)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.access_time,
                  color: Color(0xFF8A94A6),
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  'Created ${_formatDate(alert.createdAt)}',
                  style: const TextStyle(
                    color: Color(0xFF8A94A6),
                    fontSize: 12,
                  ),
                ),
                if (alert.triggeredAt != null) ...[
                  const SizedBox(width: 16),
                  const Icon(
                    Icons.notification_important,
                    color: Colors.orange,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Triggered ${_formatDate(alert.triggeredAt!)}',
                    style: const TextStyle(
                      color: Colors.orange,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
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

  void _handleMenuAction(String action, RateAlert alert) {
    switch (action) {
      case 'edit':
        _navigateToCreateAlert(alert: alert);
        break;
      case 'delete':
        _showDeleteDialog(alert);
        break;
    }
  }

  void _showDeleteDialog(RateAlert alert) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0F0F23),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text(
          'Delete Alert',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to delete this rate alert for ${alert.fromCurrency}/${alert.toCurrency}?',
          style: const TextStyle(color: Color(0xFF8A94A6)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF8A94A6))),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _alertService.deleteAlert(alert.id);
              _loadAlerts();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Alert deleted successfully'),
                    backgroundColor: Color.fromARGB(255, 10, 108, 236),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _navigateToCreateAlert({RateAlert? alert}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateAlertScreen(alert: alert),
      ),
    );
    
    if (result == true) {
      _loadAlerts();
    }
  }
}