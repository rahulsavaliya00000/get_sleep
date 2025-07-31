import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:health/health.dart';
import 'package:sleep_up/bindings/sleep_binding.dart';
import 'package:sleep_up/firebase_options.dart';
import 'package:sleep_up/views/sleep_view.dart';
import 'package:workmanager/workmanager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const String syncTask = "periodic-sync-46";
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  Workmanager().initialize(callbackDispatcher, isInDebugMode: true);

  runApp(
    GetMaterialApp(
      title: 'Sleep Data Demo',
      initialBinding: SleepBinding(),
      home: SleepView(),
    ),
  );
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    final health = Health();

    if (!await health.isHealthDataInBackgroundAuthorized()) {
      debugPrint(' No background‐read permission: skipping this run');
      return Future.value(true);
    }

    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(Duration(days: 1));
    final extendedStart = startOfDay.subtract(Duration(hours: 8));
    final extendedEnd = endOfDay.add(Duration(hours: 8));

    List<HealthDataPoint> data;
    try {
      data = await health.getHealthDataFromTypes(
        startTime: extendedStart,
        endTime: extendedEnd,
        types: [HealthDataType.SLEEP_SESSION],
      );
      data = health.removeDuplicates(data);
    } catch (e) {
      debugPrint(' Health read failed: $e');
      return Future.value(true);
    }

    double hours = 0.0;
    for (var p in data) {
      final oStart = p.dateFrom.isAfter(startOfDay) ? p.dateFrom : startOfDay;
      final oEnd = p.dateTo.isBefore(endOfDay) ? p.dateTo : endOfDay;
      if (oStart.isBefore(oEnd)) {
        hours += oEnd.difference(oStart).inMinutes / 60.0;
      }
    }
    hours = double.parse(hours.toStringAsFixed(2));
    debugPrint('Today’s sleep hours: $hours');

    // 🔍 2) Only upload non-zero (or always include task markers, up to you)
    if (hours > 0) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc('sleep_summary')
            .set({
              'todaySleepHours': hours,
              'updatedAt': FieldValue.serverTimestamp(),
              'dataPoints': data.length,
              'taskName': taskName,
              'lastTaskRun': FieldValue.serverTimestamp(),
            });
        debugPrint(' Updated todaySleepHours: $hours');
      } catch (e) {
        debugPrint(' Firestore upload failed: $e');
      }
    } else {
      debugPrint(' hours == 0.0; not updating Firestore');
    }

    return Future.value(true);
  });
}
