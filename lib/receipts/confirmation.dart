import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Download Receipt')),
        body: Center(
          child: ElevatedButton(
            onPressed: () {
              // Example: Call the function with the logged-in user's email and receipt URL
              downloadReceipt(context, 'user1@example.com', 'https://example.com/receipt1.pdf');
            },
            child: Text('Download Receipt'),
          ),
        ),
      ),
    );
  }

  void downloadReceipt(BuildContext context, String userEmail, String receiptUrl) async {
    try {
      // Simulate the download process
      await Future.delayed(Duration(seconds: 2));

      // Display confirmation message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Receipt downloaded successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Trigger email notification
      await FirebaseFirestore.instance.collection('downloads').add({
        'email': userEmail,
        'receiptUrl': receiptUrl,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to download receipt. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
