class NotificationSettings {
  final bool rateAlertsEnabled;
  final bool appUpdatesEnabled;
  final bool marketNewsEnabled;
  final bool weeklyReportsEnabled;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final String alertFrequency;
  final double minimumChangeThreshold;
  final bool quietHoursEnabled;
  final List<String> quietHoursStart;
  final List<String> quietHoursEnd;
  final List<String> enabledCurrencies;

  NotificationSettings({
    this.rateAlertsEnabled = true,
    this.appUpdatesEnabled = true,
    this.marketNewsEnabled = false,
    this.weeklyReportsEnabled = false,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.alertFrequency = 'immediate',
    this.minimumChangeThreshold = 0.01,
    this.quietHoursEnabled = false,
    this.quietHoursStart = const ['22', '00'],
    this.quietHoursEnd = const ['08', '00'],
    this.enabledCurrencies = const ['USD', 'EUR', 'GBP'],
  });

  NotificationSettings copyWith({
    bool? rateAlertsEnabled,
    bool? appUpdatesEnabled,
    bool? marketNewsEnabled,
    bool? weeklyReportsEnabled,
    bool? soundEnabled,
    bool? vibrationEnabled,
    String? alertFrequency,
    double? minimumChangeThreshold,
    bool? quietHoursEnabled,
    List<String>? quietHoursStart,
    List<String>? quietHoursEnd,
    List<String>? enabledCurrencies,
  }) {
    return NotificationSettings(
      rateAlertsEnabled: rateAlertsEnabled ?? this.rateAlertsEnabled,
      appUpdatesEnabled: appUpdatesEnabled ?? this.appUpdatesEnabled,
      marketNewsEnabled: marketNewsEnabled ?? this.marketNewsEnabled,
      weeklyReportsEnabled: weeklyReportsEnabled ?? this.weeklyReportsEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      alertFrequency: alertFrequency ?? this.alertFrequency,
      minimumChangeThreshold: minimumChangeThreshold ?? this.minimumChangeThreshold,
      quietHoursEnabled: quietHoursEnabled ?? this.quietHoursEnabled,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
      enabledCurrencies: enabledCurrencies ?? this.enabledCurrencies,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rateAlertsEnabled': rateAlertsEnabled,
      'appUpdatesEnabled': appUpdatesEnabled,
      'marketNewsEnabled': marketNewsEnabled,
      'weeklyReportsEnabled': weeklyReportsEnabled,
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
      'alertFrequency': alertFrequency,
      'minimumChangeThreshold': minimumChangeThreshold,
      'quietHoursEnabled': quietHoursEnabled,
      'quietHoursStart': quietHoursStart,
      'quietHoursEnd': quietHoursEnd,
      'enabledCurrencies': enabledCurrencies,
    };
  }

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      rateAlertsEnabled: json['rateAlertsEnabled'] ?? true,
      appUpdatesEnabled: json['appUpdatesEnabled'] ?? true,
      marketNewsEnabled: json['marketNewsEnabled'] ?? false,
      weeklyReportsEnabled: json['weeklyReportsEnabled'] ?? false,
      soundEnabled: json['soundEnabled'] ?? true,
      vibrationEnabled: json['vibrationEnabled'] ?? true,
      alertFrequency: json['alertFrequency'] ?? 'immediate',
      minimumChangeThreshold: json['minimumChangeThreshold']?.toDouble() ?? 0.01,
      quietHoursEnabled: json['quietHoursEnabled'] ?? false,
      quietHoursStart: List<String>.from(json['quietHoursStart'] ?? ['22', '00']),
      quietHoursEnd: List<String>.from(json['quietHoursEnd'] ?? ['08', '00']),
      enabledCurrencies: List<String>.from(json['enabledCurrencies'] ?? ['USD', 'EUR', 'GBP']),
    );
  }
}