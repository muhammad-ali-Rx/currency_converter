import 'package:currency_converter/model/rate-alert.dart';
import 'package:currency_converter/services/alert-service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SimpleCreateAlertScreen extends StatefulWidget {
  const SimpleCreateAlertScreen({super.key});

  @override
  State<SimpleCreateAlertScreen> createState() => _SimpleCreateAlertScreenState();
}

class _SimpleCreateAlertScreenState extends State<SimpleCreateAlertScreen> {
  final _formKey = GlobalKey<FormState>();
  final _targetRateController = TextEditingController();
  final _alertService = SimpleAlertService();
  final _auth = FirebaseAuth.instance;

  String _fromCurrency = 'USD';
  String _toCurrency = 'PKR';
  String _condition = 'above';
  bool _isLoading = false;
  
  final List<String> _currencies = [
    'USD', 'EUR', 'GBP', 'JPY', 'CAD', 'AUD', 'CHF', 'CNY', 'INR', 'PKR'
  ];

  @override
  void initState() {
    super.initState();
    _checkNotificationPermissions();
    _checkUserAuthentication();
  }

  Future<void> _checkUserAuthentication() async {
    final user = _auth.currentUser;
    if (user == null) {
      print('⚠️ No user logged in - alerts will be created anonymously');
    } else {
      print('✅ User logged in: ${user.email} (${user.uid})');
    }
  }

  Future<void> _checkNotificationPermissions() async {
    final hasPermissions = await _alertService.hasNotificationPermissions();
    if (!hasPermissions && mounted) {
      _showPermissionDialog();
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Row(
          children: [
            Icon(Icons.notifications, color: Colors.orange),
            SizedBox(width: 8),
            Text('Enable Notifications', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: const Text(
          'To receive rate alerts, please enable notifications for this app.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Later', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _alertService.openNotificationSettings();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Enable', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _targetRateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F23),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F23),
        title: const Text('Create Alert', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          _buildUserIndicator(),
          IconButton(
            onPressed: _testNotification,
            icon: const Icon(Icons.notifications_active, color: Colors.orange),
            tooltip: 'Test Notification',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildUserStatusCard(),
              const SizedBox(height: 16),
              
              _buildNotificationStatusCard(),
              const SizedBox(height: 20),
              
              // Currency Selection
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A2E),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Currency Pair',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _fromCurrency,
                            decoration: const InputDecoration(
                              labelText: 'From',
                              labelStyle: TextStyle(color: Colors.white70),
                              border: OutlineInputBorder(),
                            ),
                            dropdownColor: const Color(0xFF1A1A2E),
                            style: const TextStyle(color: Colors.white),
                            items: _currencies.map((currency) {
                              return DropdownMenuItem(
                                value: currency,
                                child: Text(currency, style: const TextStyle(color: Colors.white)),
                              );
                            }).toList(),
                            onChanged: (value) => setState(() => _fromCurrency = value!),
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Icon(Icons.arrow_forward, color: Colors.white70),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _toCurrency,
                            decoration: const InputDecoration(
                              labelText: 'To',
                              labelStyle: TextStyle(color: Colors.white70),
                              border: OutlineInputBorder(),
                            ),
                            dropdownColor: const Color(0xFF1A1A2E),
                            style: const TextStyle(color: Colors.white),
                            items: _currencies.map((currency) {
                              return DropdownMenuItem(
                                value: currency,
                                child: Text(currency, style: const TextStyle(color: Colors.white)),
                              );
                            }).toList(),
                            onChanged: (value) => setState(() => _toCurrency = value!),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Condition Selection
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A2E),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Alert Condition',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Above', style: TextStyle(color: Colors.white)),
                            value: 'above',
                            groupValue: _condition,
                            activeColor: const Color.fromARGB(255, 10, 108, 236),
                            onChanged: (value) => setState(() => _condition = value!),
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Below', style: TextStyle(color: Colors.white)),
                            value: 'below',
                            groupValue: _condition,
                            activeColor: const Color.fromARGB(255, 10, 108, 236),
                            onChanged: (value) => setState(() => _condition = value!),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Target Rate Input
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A2E),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Target Rate',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _targetRateController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                      decoration: const InputDecoration(
                        hintText: 'Enter target rate (e.g., 278.50)',
                        hintStyle: TextStyle(color: Colors.white54),
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.trending_up, color: Colors.white70),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter target rate';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter valid number';
                        }
                        if (double.parse(value) <= 0) {
                          return 'Rate must be greater than 0';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Create Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createAlert,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 10, 108, 236),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Create Alert',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserIndicator() {
    final user = _auth.currentUser;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: user != null ? Colors.green.withOpacity(0.2) : Colors.orange.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                user != null ? Icons.person : Icons.person_outline,
                size: 16,
                color: user != null ? Colors.green : Colors.orange,
              ),
              const SizedBox(width: 4),
              Text(
                user != null ? 'Logged In' : 'Anonymous',
                style: TextStyle(
                  color: user != null ? Colors.green : Colors.orange,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserStatusCard() {
    final user = _auth.currentUser;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: user != null ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: user != null ? Colors.green.withOpacity(0.3) : Colors.orange.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            user != null ? Icons.account_circle : Icons.account_circle_outlined,
            color: user != null ? Colors.green : Colors.orange,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user != null ? 'Logged in as ${user.email ?? "User"}' : 'Creating as Anonymous User',
                  style: TextStyle(
                    color: user != null ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  user != null 
                      ? 'Alert will be saved to your account'
                      : 'Alert will be created with anonymous user info',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationStatusCard() {
    return FutureBuilder<bool>(
      future: _alertService.hasNotificationPermissions(),
      builder: (context, snapshot) {
        final hasPermissions = snapshot.data ?? false;
        
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: hasPermissions ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: hasPermissions ? Colors.green.withOpacity(0.3) : Colors.orange.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                hasPermissions ? Icons.notifications_active : Icons.notifications_off,
                color: hasPermissions ? Colors.green : Colors.orange,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasPermissions ? 'Notifications Enabled' : 'Notifications Disabled',
                      style: TextStyle(
                        color: hasPermissions ? Colors.green : Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      hasPermissions 
                          ? 'You will receive alerts when rates are triggered'
                          : 'Enable notifications to receive rate alerts',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
              if (!hasPermissions)
                TextButton(
                  onPressed: () => _alertService.openNotificationSettings(),
                  child: const Text('Enable', style: TextStyle(color: Colors.orange)),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _testNotification() async {
    try {
      await _alertService.testNotification();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Test notification sent!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _createAlert() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    
    try {
      final alert = SimpleRateAlert(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        fromCurrency: _fromCurrency,
        toCurrency: _toCurrency,
        targetRate: double.parse(_targetRateController.text),
        condition: _condition,
        createdAt: DateTime.now(),
      );

      print('🔄 Creating alert: ${alert.fromCurrency}/${alert.toCurrency} ${alert.condition} ${alert.targetRate}');
      
      final alertId = await _alertService.addAlert(alert);
      
      if (alertId != null && mounted) {
        print('✅ Alert created successfully with ID: $alertId');
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('✅ Alert created successfully!'),
                      Text(
                        '${alert.fromCurrency}/${alert.toCurrency} ${alert.condition} ${alert.targetRate}',
                        style: const TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
        
        Navigator.pop(context);
      } else {
        throw Exception('Failed to create alert - no ID returned');
      }
    } catch (e) {
      print('❌ Error creating alert: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('❌ Error: ${e.toString()}')),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
