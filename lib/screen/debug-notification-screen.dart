import 'package:currency_converter/services/alert-service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class DebugNotificationScreen extends StatefulWidget {
  const DebugNotificationScreen({super.key});

  @override
  State<DebugNotificationScreen> createState() => _DebugNotificationScreenState();
}

class _DebugNotificationScreenState extends State<DebugNotificationScreen> {
  final _alertService = SimpleAlertService();
  String _status = 'Checking...';
  bool _hasPermissions = false;
  bool _isInitialized = false;
  String _platform = 'Unknown';

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    try {
      final permissions = await _alertService.hasNotificationPermissions();
      final initialized = _alertService.isInitialized;
      final platform = _alertService.platformInfo;
      
      setState(() {
        _hasPermissions = permissions;
        _isInitialized = initialized;
        _platform = platform;
        _status = 'Platform: $platform, Permissions: $permissions, Initialized: $initialized';
      });
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F23),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F23),
        title: const Text('Debug Notifications', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Platform Info Card
            Card(
              color: const Color(0xFF1A1A2E),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          kIsWeb ? Icons.web : Icons.phone_android,
                          color: kIsWeb ? Colors.blue : Colors.green,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Platform Information',
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Platform: $_platform',
                      style: const TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Environment: ${kIsWeb ? "Web Browser" : "Native Mobile"}',
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Status Card
            Card(
              color: const Color(0xFF1A1A2E),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Notification Status',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Status: $_status',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          _hasPermissions ? Icons.check_circle : Icons.error,
                          color: _hasPermissions ? Colors.green : Colors.orange,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Permissions: ${_hasPermissions ? "Granted" : (kIsWeb ? "Web Default" : "Denied")}',
                          style: TextStyle(
                            color: _hasPermissions ? Colors.green : Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          _isInitialized ? Icons.check_circle : Icons.error,
                          color: _isInitialized ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Initialized: ${_isInitialized ? "Yes" : "No"}',
                          style: TextStyle(
                            color: _isInitialized ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                    if (kIsWeb) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.withOpacity(0.3)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.info, color: Colors.blue, size: 16),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Web notifications work differently than mobile. Test notifications will appear in console.',
                                style: TextStyle(color: Colors.blue, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Action buttons
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _checkStatus,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                child: const Text('Refresh Status', style: TextStyle(color: Colors.white)),
              ),
            ),
            
            const SizedBox(height: 12),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _reinitialize,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                child: const Text('Reinitialize', style: TextStyle(color: Colors.white)),
              ),
            ),
            
            const SizedBox(height: 12),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _testNotification,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: Text(
                  kIsWeb ? 'Test Notification (Console)' : 'Test Notification',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
            
            const SizedBox(height: 12),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _openSettings,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                child: Text(
                  kIsWeb ? 'Browser Settings Info' : 'Open Settings',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _reinitialize() async {
    try {
      setState(() => _status = 'Reinitializing...');
      
      final success = await _alertService.reinitialize();
      
      setState(() {
        _status = 'Reinitialization: ${success ? "Success" : "Failed"}';
      });
      
      await _checkStatus();
    } catch (e) {
      setState(() => _status = 'Reinitialization error: $e');
    }
  }

  Future<void> _testNotification() async {
    try {
      setState(() => _status = 'Sending test notification...');
      
      final success = await _alertService.testNotification();
      
      setState(() {
        _status = 'Test notification: ${success ? "Sent" : "Failed"}';
      });
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              kIsWeb 
                ? 'Test notification sent! Check browser console for details.'
                : 'Test notification sent!',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => _status = 'Test notification error: $e');
    }
  }

  Future<void> _openSettings() async {
    if (kIsWeb) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A2E),
          title: const Row(
            children: [
              Icon(Icons.web, color: Colors.blue),
              SizedBox(width: 8),
              Text('Web Notifications', style: TextStyle(color: Colors.white)),
            ],
          ),
          content: const Text(
            'For web notifications:\n\n'
            '1. Click the lock icon in your browser address bar\n'
            '2. Allow notifications for this site\n'
            '3. Refresh the page\n\n'
            'Note: Web notifications work differently than mobile notifications.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK', style: TextStyle(color: Colors.blue)),
            ),
          ],
        ),
      );
    } else {
      await _alertService.openNotificationSettings();
    }
  }
}
