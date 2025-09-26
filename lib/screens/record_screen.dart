import 'package:flutter/material.dart';

class RecordScreen extends StatelessWidget {
  const RecordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('旅程紀錄'),
        backgroundColor: Colors.blue.shade50,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.photo_camera, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              '旅程紀錄功能',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '記錄您的美好回憶',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 16),
            Text(
              '功能開發中...',
              style: TextStyle(color: Colors.orange),
            ),
          ],
        ),
      ),
    );
  }
}