import 'package:get/get.dart';
import 'package:health/health.dart';
import '../models/sleep_day.dart';
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
}
