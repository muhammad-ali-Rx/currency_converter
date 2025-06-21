import 'package:currency_converter/model/notifications.dart';
import 'package:currency_converter/services/Enhanced_Notification.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  late EnhancedNotificationService _notificationService;
  late NotificationSettings _settings;
  bool _isLoading = true;

  final List<String> _currencies = [
    'USD', 'EUR', 'GBP', 'JPY', 'AUD', 'CAD', 'CHF', 'CNY', 'SEK', 'NZD'
  ];

  final List<String> _alertFrequencies = ['immediate', 'hourly', 'daily'];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _notificationService = EnhancedNotificationService();
    _settings = _notificationService.getSettings();
    setState(() => _isLoading = false);
  }

  Future<void> _updateSettings(NotificationSettings newSettings) async {
    await _notificationService.updateSettings(newSettings);
    setState(() => _settings = newSettings);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFF0F0F23),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0F0F23),
          title: const Text('Notification Settings', style: TextStyle(color: Colors.white)),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: const Center(
          child: CircularProgressIndicator(color: Color.fromARGB(255, 10, 108, 236)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F23),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F23),
        title: const Text(
          'Notification Settings',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildNotificationTypesSection(),
          const SizedBox(height: 24),
          _buildAlertSettingsSection(),
          const SizedBox(height: 24),
          _buildQuietHoursSection(),
          const SizedBox(height: 24),
          _buildCurrencyPreferencesSection(),
          const SizedBox(height: 24),
          _buildAdvancedSettingsSection(),
        ],
      ),
    );
  }

  Widget _buildNotificationTypesSection() {
    return _buildSection(
      title: 'Notification Types',
      icon: Icons.notifications,
      children: [
        _buildSwitchTile(
          title: 'Rate Alerts',
          subtitle: 'Get notified when your rate alerts are triggered',
          value: _settings.rateAlertsEnabled,
          onChanged: (value) => _updateSettings(_settings.copyWith(rateAlertsEnabled: value)),
        ),
        _buildSwitchTile(
          title: 'App Updates',
          subtitle: 'Important app updates and new features',
          value: _settings.appUpdatesEnabled,
          onChanged: (value) => _updateSettings(_settings.copyWith(appUpdatesEnabled: value)),
        ),
        _buildSwitchTile(
          title: 'Market News',
          subtitle: 'Currency market news and insights',
          value: _settings.marketNewsEnabled,
          onChanged: (value) => _updateSettings(_settings.copyWith(marketNewsEnabled: value)),
        ),
        _buildSwitchTile(
          title: 'Weekly Reports',
          subtitle: 'Weekly currency performance summaries',
          value: _settings.weeklyReportsEnabled,
          onChanged: (value) => _updateSettings(_settings.copyWith(weeklyReportsEnabled: value)),
        ),
      ],
    );
  }

  Widget _buildAlertSettingsSection() {
    return _buildSection(
      title: 'Alert Settings',
      icon: Icons.tune,
      children: [
        _buildSwitchTile(
          title: 'Sound',
          subtitle: 'Play sound for notifications',
          value: _settings.soundEnabled,
          onChanged: (value) => _updateSettings(_settings.copyWith(soundEnabled: value)),
        ),
        _buildSwitchTile(
          title: 'Vibration',
          subtitle: 'Vibrate for notifications',
          value: _settings.vibrationEnabled,
          onChanged: (value) => _updateSettings(_settings.copyWith(vibrationEnabled: value)),
        ),
        _buildDropdownTile(
          title: 'Alert Frequency',
          subtitle: 'How often to check for rate changes',
          value: _settings.alertFrequency,
          items: _alertFrequencies,
          onChanged: (value) => _updateSettings(_settings.copyWith(alertFrequency: value)),
        ),
        _buildSliderTile(
          title: 'Minimum Change Threshold',
          subtitle: 'Only alert for changes above ${(_settings.minimumChangeThreshold * 100).toStringAsFixed(1)}%',
          value: _settings.minimumChangeThreshold,
          min: 0.001,
          max: 0.1,
          divisions: 99,
          onChanged: (value) => _updateSettings(_settings.copyWith(minimumChangeThreshold: value)),
        ),
      ],
    );
  }

  Widget _buildQuietHoursSection() {
    return _buildSection(
      title: 'Quiet Hours',
      icon: Icons.bedtime,
      children: [
        _buildSwitchTile(
          title: 'Enable Quiet Hours',
          subtitle: 'Pause non-critical notifications during specified hours',
          value: _settings.quietHoursEnabled,
          onChanged: (value) => _updateSettings(_settings.copyWith(quietHoursEnabled: value)),
        ),
        if (_settings.quietHoursEnabled) ...[
          _buildTimeTile(
            title: 'Start Time',
            time: '${_settings.quietHoursStart[0]}:${_settings.quietHoursStart[1]}',
            onTap: () => _selectTime(true),
          ),
          _buildTimeTile(
            title: 'End Time',
            time: '${_settings.quietHoursEnd[0]}:${_settings.quietHoursEnd[1]}',
            onTap: () => _selectTime(false),
          ),
        ],
      ],
    );
  }

  Widget _buildCurrencyPreferencesSection() {
    return _buildSection(
      title: 'Currency Preferences',
      icon: Icons.currency_exchange,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Get notifications for these currencies',
                style: TextStyle(color: Color(0xFF8A94A6), fontSize: 14),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _currencies.map((currency) {
                  final isSelected = _settings.enabledCurrencies.contains(currency);
                  return FilterChip(
                    label: Text(currency),
                    selected: isSelected,
                    onSelected: (selected) {
                      List<String> newCurrencies = List.from(_settings.enabledCurrencies);
                      if (selected) {
                        newCurrencies.add(currency);
                      } else {
                        newCurrencies.remove(currency);
                      }
                      _updateSettings(_settings.copyWith(enabledCurrencies: newCurrencies));
                    },
                    backgroundColor: const Color(0xFF0F0F23),
                    selectedColor: const Color.fromARGB(255, 10, 108, 236).withOpacity(0.3),
                    labelStyle: TextStyle(
                      color: isSelected ? const Color.fromARGB(255, 10, 108, 236) : Colors.white,
                    ),
                    side: BorderSide(
                      color: isSelected 
                          ? const Color.fromARGB(255, 10, 108, 236)
                          : const Color(0xFF8A94A6),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAdvancedSettingsSection() {
    return _buildSection(
      title: 'Advanced',
      icon: Icons.settings_applications,
      children: [
        _buildActionTile(
          title: 'Test Notification',
          subtitle: 'Send a test notification',
          icon: Icons.send,
          onTap: _sendTestNotification,
        ),
        _buildActionTile(
          title: 'Notification Permissions',
          subtitle: 'Manage system notification permissions',
          icon: Icons.security,
          onTap: _openNotificationPermissions,
        ),
        _buildActionTile(
          title: 'Reset to Defaults',
          subtitle: 'Reset all notification settings to default values',
          icon: Icons.restore,
          onTap: _resetToDefaults,
          isDestructive: true,
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color.fromARGB(255, 10, 108, 236).withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 10, 108, 236).withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: const Color.fromARGB(255, 10, 108, 236), size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF2A2A3E), width: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: Color(0xFF8A94A6), fontSize: 14),
                ),
              ],
            ),
          ),
          CupertinoSwitch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color.fromARGB(255, 10, 108, 236),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownTile({
    required String title,
    required String subtitle,
    required String value,
    required List<String> items,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF2A2A3E), width: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: Color(0xFF8A94A6), fontSize: 14),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF0F0F23),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF8A94A6).withOpacity(0.3)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                onChanged: (newValue) => onChanged(newValue!),
                dropdownColor: const Color(0xFF1A1A2E),
                style: const TextStyle(color: Colors.white),
                icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF8A94A6)),
                items: items.map((item) {
                  return DropdownMenuItem(
                    value: item,
                    child: Text(item.toUpperCase()),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderTile({
    required String title,
    required String subtitle,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF2A2A3E), width: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(color: Color(0xFF8A94A6), fontSize: 14),
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color.fromARGB(255, 10, 108, 236),
              inactiveTrackColor: const Color(0xFF8A94A6).withOpacity(0.3),
              thumbColor: const Color.fromARGB(255, 10, 108, 236),
              overlayColor: const Color.fromARGB(255, 10, 108, 236).withOpacity(0.2),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeTile({
    required String title,
    required String time,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF2A2A3E), width: 0.5)),
      ),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF0F0F23),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF8A94A6).withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    time,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.access_time, color: Color(0xFF8A94A6), size: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF2A2A3E), width: 0.5)),
      ),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (isDestructive ? Colors.red : const Color.fromARGB(255, 10, 108, 236)).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isDestructive ? Colors.red : const Color.fromARGB(255, 10, 108, 236),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isDestructive ? Colors.red : Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Color(0xFF8A94A6), fontSize: 14),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Color(0xFF8A94A6),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectTime(bool isStartTime) async {
    final currentTime = isStartTime ? _settings.quietHoursStart : _settings.quietHoursEnd;
    final initialTime = TimeOfDay(
      hour: int.parse(currentTime[0]),
      minute: int.parse(currentTime[1]),
    );

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color.fromARGB(255, 10, 108, 236),
              surface: Color(0xFF1A1A2E),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final timeList = [picked.hour.toString().padLeft(2, '0'), picked.minute.toString().padLeft(2, '0')];
      
      if (isStartTime) {
        _updateSettings(_settings.copyWith(quietHoursStart: timeList));
      } else {
        _updateSettings(_settings.copyWith(quietHoursEnd: timeList));
      }
    }
  }

  Future<void> _sendTestNotification() async {
    await _notificationService.showAppUpdateNotification(
      '2.1.0',
      'This is a test notification to verify your settings are working correctly.',
    );
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Test notification sent!'),
          backgroundColor: Color.fromARGB(255, 10, 108, 236),
        ),
      );
    }
  }

  Future<void> _openNotificationPermissions() async {
    final hasPermission = await _notificationService.areNotificationsEnabled();
    
    if (!hasPermission) {
      final granted = await _notificationService.requestNotificationPermissions();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(granted ? 'Permissions granted!' : 'Permissions denied'),
            backgroundColor: granted ? const Color.fromARGB(255, 10, 108, 236) : Colors.red,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notifications are already enabled'),
            backgroundColor: Color.fromARGB(255, 10, 108, 236),
          ),
        );
      }
    }
  }

  Future<void> _resetToDefaults() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0F0F23),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text(
          'Reset Settings',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Are you sure you want to reset all notification settings to their default values?',
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
              await _updateSettings(NotificationSettings());
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Settings reset to defaults'),
                    backgroundColor: Color.fromARGB(255, 10, 108, 236),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}