import 'package:health/health.dart';

class HealthUtils {
  /// Keep only points overlapping [start]–[end]
  static List<HealthDataPoint> filterOverlap(
    List<HealthDataPoint> data,
    DateTime start,
    DateTime end,
  ) {
    return data.where((p) {
      return p.dateFrom.isBefore(end) && p.dateTo.isAfter(start);
    }).toList();
  }

  /// Sum up only SLEEP_SESSION minutes → hours
  static double calculateSessionHours(
    List<HealthDataPoint> data,
    DateTime start,
    DateTime end,
  ) {
    double session = 0.0;
    for (var p in data) {
      if (p.type != HealthDataType.SLEEP_SESSION) continue;
      final oStart = p.dateFrom.isAfter(start) ? p.dateFrom : start;
      final oEnd = p.dateTo.isBefore(end) ? p.dateTo : end;
      if (!oStart.isBefore(oEnd)) continue;
      session += oEnd.difference(oStart).inMinutes / 60.0;
    }
    return session;
  }
}
