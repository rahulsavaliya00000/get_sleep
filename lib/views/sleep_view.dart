import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sleep_up/views/firebase_upload.dart';
import '../controllers/sleep_controller.dart';

class SleepView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = Get.find<SleepController>();

    return Scaffold(
      appBar: AppBar(title: Text('Google Fit Sleep Sessions')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Obx(() {
          if (c.isLoading.value) {
            return Center(child: CircularProgressIndicator());
          }
          if (c.errorMessage.value != null) {
            return Center(
              child: Text(
                c.errorMessage.value!,
                style: TextStyle(color: Colors.red),
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child:
                    c.dailySessions.isEmpty
                        ? Center(child: Text('No session data found.'))
                        : ListView.builder(
                          itemCount: c.dailySessions.length,
                          itemBuilder: (_, idx) {
                            final day = c.dailySessions[idx];
                            final dateStr =
                                '${day.date.year}-${day.date.month.toString().padLeft(2, '0')}-${day.date.day.toString().padLeft(2, '0')}';
                            return Card(
                              margin: EdgeInsets.symmetric(vertical: 4),
                              child: ListTile(
                                title: Text(dateStr),
                                trailing: Text(
                                  '${day.sessionHours.toStringAsFixed(1)} h',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.purple.shade700,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
              ),
              SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => c.fetchSleepSessions(days: 7),
                icon: Icon(Icons.refresh),
                label: Text('Refresh Sessions'),
              ),
              GestureDetector(
                onTap: () => Get.to(NumberUploadView()),
                child: Container(
                  height: 40,
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                  margin: EdgeInsets.only(top: 16),
                  child: Center(
                    child: Text(
                      'Test',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
