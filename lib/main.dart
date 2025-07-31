import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sleep_up/bindings/sleep_binding.dart';
import 'package:sleep_up/firebase_options.dart';
import 'package:sleep_up/views/sleep_view.dart';
import 'package:workmanager/workmanager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// The name you register your task under.
const String syncTask = "syncSleepSessions";
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // :one: Initialize Firebase first
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // :two: Initialize Workmanager

  Workmanager().cancelAll();
  Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: true, // verbose logs during development
    
  );
  // :three: Register a periodic background task:
  await Workmanager().registerPeriodicTask(
    "syncSleepSessions-id",    // a unique string ID
    syncTask,                  // your task name constant
    frequency: const Duration(minutes: 15),
    initialDelay: const Duration(seconds: 10),
    constraints: Constraints(
      networkType: NetworkType.connected,
      requiresBatteryNotLow: true,
    ),
  );


  // :four: Start your app
  runApp(
    GetMaterialApp(
      title: 'Sleep Data Demo',
      debugShowCheckedModeBanner: false,
      initialBinding: SleepBinding(),
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: SleepView(),
    ),
  );
}

/// This is the headless entry-point for Workmanager.
/// Annotate with @pragma so it’s not tree‑shaken.
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    final now = DateTime.now();
    debugPrint('🕵️ [Workmanager] callbackDispatcher fired [$taskName] at $now');

    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('✅ Firebase re-initialized in background isolate');

    try {
      debugPrint('✍️ Writing to Firestore…');
      await FirebaseFirestore.instance.collection('users').add({
        'name': 'rahul',
        'timestamp': FieldValue.serverTimestamp(),
      });
      debugPrint('✅ [Workmanager] wrote rahul to Firestore');
      return true;
    } catch (e) {
      debugPrint('❌ [Workmanager] failed to write: $e');
      return false;
    }
  });
}