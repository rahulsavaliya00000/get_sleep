import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:health/health.dart';
import 'package:sleep_up/main.dart';
import 'package:sleep_up/models/sleep_day.dart';
import 'package:workmanager/workmanager.dart';
import '../services/sleep_service.dart';


class SleepController extends GetxController {
  final _health = Health();
  var isLoading = false.obs;
  var errorMessage = RxnString();
  var dailySessions = <SleepDay>[].obs;

  Future<void> fetchSleepSessions({int days = 7}) async {
    isLoading.value = true;
    errorMessage.value = null;
    dailySessions.clear();

    try {
      //  Ask for BOTH foreground & background read
      final types = [HealthDataType.SLEEP_SESSION];
      final ok = await _health.requestAuthorization(types);
      if (ok != true) throw Exception('Health authorization failed');

      // Request the background‐read grant too
      await _health.requestHealthDataInBackgroundAuthorization();

      // Permissions are now granted! Schedule your background jobs:
      await _scheduleBackgroundSync();

      final sessions = await SleepService.fetchDailySessions(
        _health,
        days: days,
      );
      dailySessions.value = sessions;
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
  Future<void> _scheduleBackgroundSync() async {
    await Workmanager().cancelAll();

    await Workmanager().registerOneOffTask(
      'debug-run-46', 
      syncTask,
      initialDelay: Duration(seconds: 5),
    );

    await Workmanager().registerPeriodicTask(
      'periodic-sync-46', 
      syncTask,
      frequency: Duration(minutes: 15),
      initialDelay: Duration(seconds: 10),
      constraints: Constraints(
        networkType: NetworkType.connected,
        requiresBatteryNotLow: true,
      ),
    );

    debugPrint('Scheduled background sync tasks');
  }
}
