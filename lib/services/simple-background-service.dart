import 'dart:async';
import 'package:currency_converter/services/alert-service.dart';
import 'package:workmanager/workmanager.dart';

class SimpleBackgroundService {
  static const String taskName = 'checkSimpleAlerts';
  
  // Initialize background service
  static void initialize() {
    Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
  }
  
  // Start periodic checking
  static void startChecking() {
    Workmanager().registerPeriodicTask(
      taskName,
      taskName,
      frequency: const Duration(minutes: 15),
    );
    print('Background alert checking started');
  }
  
  // Stop checking
  static void stopChecking() {
    Workmanager().cancelByUniqueName(taskName);
    print('Background alert checking stopped');
  }
}

// Background task callback
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      print('Checking alerts in background...');
      
      final alertService = SimpleAlertService();
      await alertService.initNotifications();
      await alertService.checkAlerts();
      
      print('Background alert check completed');
      return Future.value(true);
    } catch (e) {
      print('Background task error: $e');
      return Future.value(false);
    }
  });
}
