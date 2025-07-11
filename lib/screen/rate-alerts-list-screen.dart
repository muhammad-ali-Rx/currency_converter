import 'package:currency_converter/model/rate-alert.dart';
import 'package:currency_converter/screen/enhanced-create-alert-screen.dart';
import 'package:currency_converter/services/alert-service.dart';
import 'package:flutter/material.dart';

class SimpleAlertsListScreen extends StatefulWidget {
  const SimpleAlertsListScreen({super.key});

  @override
  State<SimpleAlertsListScreen> createState() => _SimpleAlertsListScreenState();
}

class _SimpleAlertsListScreenState extends State<SimpleAlertsListScreen> {
  final _alertService = SimpleAlertService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F23),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F23),
        title: const Text('My Alerts', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: () => setState(() {}), // Refresh button
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: StreamBuilder<List<SimpleRateAlert>>(
        stream: _alertService.getAlertsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color.fromARGB(255, 10, 108, 236))
            );
          }

          if (snapshot.hasError) {
            print('❌ Stream error: ${snapshot.error}');
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 64),
                  const SizedBox(height: 16),
                  const Text(
                    'Error loading alerts',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${snapshot.error}',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(() {}), // Refresh
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 10, 108, 236),
                    ),
                    child: const Text('Retry', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            );
          }

          final alerts = snapshot.data ?? [];
          
          if (alerts.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {});
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: alerts.length,
              itemBuilder: (context, index) => _buildAlertCard(alerts[index]),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SimpleCreateAlertScreen()),
          );
        },
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
          const Icon(Icons.notifications_off, size: 80, color: Colors.white54),
          const SizedBox(height: 16),
          const Text(
            'No Alerts Yet',
            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Create your first rate alert to get notified\nwhen exchange rates hit your target',
            style: TextStyle(color: Colors.white70, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SimpleCreateAlertScreen()),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Create Alert'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 10, 108, 236),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertCard(SimpleRateAlert alert) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: alert.isActive ? Colors.green.withOpacity(0.3) : Colors.grey.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                alert.isActive ? Icons.notifications_active : Icons.notifications_off,
                color: alert.isActive ? Colors.green : Colors.grey,
              ),
              const SizedBox(width: 8),
              Text(
                '${alert.fromCurrency}/${alert.toCurrency}',
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: alert.isActive ? Colors.green.withOpacity(0.2) : Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  alert.isActive ? 'ACTIVE' : 'INACTIVE',
                  style: TextStyle(
                    color: alert.isActive ? Colors.green : Colors.grey,
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
                alert.condition == 'above' ? Icons.trending_up : Icons.trending_down,
                color: alert.condition == 'above' ? Colors.green : Colors.red,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                'Alert when rate goes ${alert.condition} ${alert.targetRate.toStringAsFixed(4)}',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.access_time, color: Colors.white54, size: 14),
              const SizedBox(width: 4),
              Text(
                'Created: ${_formatDate(alert.createdAt)}',
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => _deleteAlert(alert),
                icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                tooltip: 'Delete Alert',
              ),
            ],
          ),
        ],
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

  Future<void> _deleteAlert(SimpleRateAlert alert) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('Delete Alert', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to delete this ${alert.fromCurrency}/${alert.toCurrency} alert?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final success = await _alertService.deleteAlert(alert.id);
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 8),
                  Text('Alert deleted: ${alert.fromCurrency}/${alert.toCurrency}'),
                ],
              ),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          throw Exception('Failed to delete alert');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error, color: Colors.white),
                  const SizedBox(width: 8),
                  Text('Error deleting alert: $e'),
                ],
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
