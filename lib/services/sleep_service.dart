import 'dart:io';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sleep_up/core/health_utils.dart';
import '../models/sleep_day.dart';

class SleepService {
  static Future<List<SleepDay>> fetchDailySessions(
    Health health, {
    int days = 7,
  }) async {
    final types = [HealthDataType.SLEEP_SESSION];

    // On Android, request activity recognition
    if (Platform.isAndroid) {
      final status = await Permission.activityRecognition.status;
      if (!status.isGranted) {
        final result = await Permission.activityRecognition.request();
        if (!result.isGranted) {
          throw Exception('Activity Recognition permission denied');
        }
      }
    }

    // Ask Health Connect for session data
    final ok = await health.requestAuthorization(types);
    if (!ok) throw Exception('Health authorization failed');

    final now = DateTime.now();
    final start = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: days));
    final end = DateTime(now.year, now.month, now.day + 1);

    var allData = await health.getHealthDataFromTypes(
      startTime: start,
      endTime: end,
      types: types,
    );
    allData = health.removeDuplicates(allData);

    // Build one SleepDay per calendar day
    final List<SleepDay> result = [];
    for (var i = 0; i < days; i++) {
      final dayStart = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: i));
      final dayEnd = dayStart.add(Duration(days: 1));

      final overlaps = HealthUtils.filterOverlap(allData, dayStart, dayEnd);
      final hours = HealthUtils.calculateSessionHours(
        overlaps,
        dayStart,
        dayEnd,
      );

      result.add(SleepDay(date: dayStart, sessionHours: hours));
    }
    return result;
  }
}
