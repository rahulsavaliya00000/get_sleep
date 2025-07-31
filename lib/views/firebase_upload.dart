import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NumberUploadView extends StatelessWidget {
  const NumberUploadView({Key? key}) : super(key: key);

  Future<void> uploadNumbers() async {
    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      WriteBatch batch = firestore.batch();

      // Prepare batch writes
      for (int i = 1; i <= 10; i++) {
        final docRef = firestore.collection('numbers').doc(i.toString());
        batch.set(docRef, {'number': i});
      }

      // Commit the batch
      await batch.commit();

      Get.snackbar(
        '✅ Success',
        'Uploaded numbers 1 to 10 successfully.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        '❌ Error',
        'Failed to upload numbers: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Numbers')),
      body: Center(
        child: ElevatedButton(
          onPressed: uploadNumbers,
          child: const Text('Upload 1 to 10'),
        ),
      ),
    );
  }
}
