import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:pdf/widgets.dart' as pw;

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
              downloadReceipt(context, 'user1@example.com', 'donation_receipt_2024-08-28.pdf');
            },
            child: Text('Download Receipt'),
          ),
        ),
      ),
    );
  }

  Future<void> downloadReceipt(BuildContext context, String userEmail, String fileName) async {
    try {
      if (await Permission.storage.request().isGranted) {
        final pdf = pw.Document();
        pdf.addPage(
          pw.Page(
            build: (pw.Context context) => pw.Center(
              child: pw.Text('This is your donation receipt.'),
            ),
          ),
        );

        final downloadsDirectory = Directory('/storage/emulated/0/Download');
        final file = File("${downloadsDirectory.path}/$fileName");

        await file.writeAsBytes(await pdf.save());

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Receipt downloaded successfully to ${file.path}!'),
            backgroundColor: Colors.green,
          ),
        );

        await FirebaseFirestore.instance.collection('downloads').add({
          'email': userEmail,
          'fileName': fileName,
          'timestamp': FieldValue.serverTimestamp(),
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Storage permission is required to download the receipt.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to download receipt. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
