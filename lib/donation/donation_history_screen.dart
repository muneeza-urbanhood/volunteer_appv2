import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mailer/mailer.dart' as mailer;
import 'package:mailer/smtp_server/gmail.dart';  // For Gmail SMTP

// Function to send a confirmation email when a donation receipt is downloaded
Future<void> sendEmailConfirmation(String recipientEmail, String recipientName, String dateRange) async {
  print("Sending confirmation email...");

  // Set up the SMTP server using Gmail-specific function
  final smtpServer = gmail('ryanthepro38@gmail.com', 'zqms zauu kysc ebyu');

  // Create the email message
  final message = mailer.Message()
    ..from = mailer.Address('ufacareers@urbanhood.org', 'Urban Food Alliance')
    ..recipients.add(recipientEmail)
    ..subject = 'Confirmation: Donation Receipt Downloaded'
    ..text = 'You have downloaded your donation receipt for the date range $dateRange.'
    ..html = """
      <h4>Dear $recipientName,</h4>
      <p>Thank you for choosing Urban Food Alliance! We confirm that you have successfully downloaded your donation receipt.</p>
      <p>Date range: $dateRange</p>
      <br>
      <p>If you have any questions, please contact us at (212) 608-6112 or email us at ufacareers@urbanhood.org.</p>
      <p>Best regards,</p>
      <p>Urban Food Alliance Team</p>
      <p>Office: 3201 NJ 27, Franklin Park, NJ</p>
      <p>Email: ufacareers@urbanhood.org</p>
      <p>Phone: (212) 608-6112</p>
      <p>Registered Charity: 83-2603443501 (C)(3)</p>
      <p><a href="https://www.urbanfoodalliance.org">Urban Food Alliance</a></p>
    """;

  try {
    // Send the email
    final sendReport = await mailer.send(message, smtpServer);
    print('Confirmation email sent: ' + sendReport.toString());
  } on mailer.MailerException catch (e) {
    print('Failed to send confirmation email. ${e.toString()}');
    for (var p in e.problems) {
      print('Problem: ${p.code}: ${p.msg}');
    }
  }
}

class DonationHistoryScreen extends StatefulWidget {
  @override
  _DonationHistoryScreenState createState() => _DonationHistoryScreenState();
}

class _DonationHistoryScreenState extends State<DonationHistoryScreen> {
  String stripeSecretKey = 'sk_test_51PspmY06JHbqqu6brN7Kxjas5TkJGPy77fCeuQYuMQKk6MbmTjlm1JHEbEpQjCwED4uC1Tdp8EB6atTLxVMiEBoO00K62nrUX9';
  List<Map<String, dynamic>> _donations = [];
  List<Map<String, dynamic>> _filteredDonations = [];
  DateTimeRange? _selectedDateRange;
  String? _customerId;
  String? _customerName;  // Added to store Stripe customer name

  @override
  void initState() {
    super.initState();
    _fetchCustomerId();
  }

  Future<void> _fetchCustomerId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('No user is currently logged in.');
      return;
    }

    final userEmail = user.email;
    try {
      final response = await http.get(
        Uri.parse('https://api.stripe.com/v1/customers?email=$userEmail'),
        headers: {
          'Authorization': 'Bearer $stripeSecretKey',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final customers = data['data'] as List<dynamic>;

        if (customers.isNotEmpty) {
          final customer = customers.first;
          _customerId = customer['id'];
          _customerName = customer['name'];  // Store Stripe customer name
          _fetchDonationsFromStripe(_customerId!);
        } else {
          print('No customer found with email $userEmail');
        }
      } else {
        print('Failed to fetch customer data from Stripe: ${response.body}');
      }
    } catch (e) {
      print('Error fetching customer data from Stripe: $e');
    }
  }

  Future<void> _fetchDonationsFromStripe(String customerId) async {
    try {
      final response = await http.get(
        Uri.parse('https://api.stripe.com/v1/charges?customer=$customerId'),
        headers: {
          'Authorization': 'Bearer $stripeSecretKey',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final charges = data['data'] as List<dynamic>;

        setState(() {
          _donations = charges.map((charge) {
            final createdDate = DateTime.fromMillisecondsSinceEpoch(charge['created'] * 1000);
            return {
              'date': DateFormat('yyyy-MM-dd').format(createdDate),
              'amount': (charge['amount'] / 100).toStringAsFixed(2),
              'purpose': charge['description'] ?? 'No Description',
              'payment_method': charge['payment_method_details']['type'] ?? 'Unknown',
              'fund': charge['metadata']['fund'] ?? 'General Fund',
            };
          }).toList();

          _filteredDonations = _donations;
        });
      } else {
        print('Failed to fetch donations from Stripe: ${response.body}');
      }
    } catch (e) {
      print('Error fetching donations from Stripe: $e');
    }
  }

  // Function to dynamically get the downloads directory
  Future<String> _getDownloadDirectory() async {
    Directory? directory = await getExternalStorageDirectory();
    return directory?.path ?? '/';
  }

  // Function to save PDF to the Downloads directory
  Future<void> _saveFile(String fileName, Uint8List data) async {
    try {
      final directoryPath = await _getDownloadDirectory();
      final file = File('$directoryPath/$fileName');

      await file.writeAsBytes(data);

      print('Receipt downloaded to $directoryPath/$fileName');
    } catch (e) {
      print('Error saving file: $e');
    }
  }

  Future<void> _downloadReceipt(int index) async {
    if (await Permission.storage.request().isGranted) {
      final pdf = pw.Document();
      final user = FirebaseAuth.instance.currentUser;
      final userEmail = user?.email ?? 'User';
      final userName = _customerName ?? user?.displayName ?? userEmail;
      final donation = _filteredDonations[index];

      // Adding timestamp for unique file name
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'donation_receipt_${donation['date']}_$timestamp.pdf';

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Donation Receipt for $userName', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.Text('Date: ${donation['date']}'),
              pw.Text('Amount: \$${donation['amount']}'),
              pw.Text('Purpose: ${donation['purpose']}'),
              pw.Text('Payment Method: ${donation['payment_method']}'),
              pw.Text('Fund: ${donation['fund']}'),
            ],
          ),
        ),
      );

      // Save file
      await _saveFile(fileName, await pdf.save());

      // Send confirmation email
      try {
        await sendEmailConfirmation(userEmail, userName, 'for ${donation['date']}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Receipt downloaded and confirmation email sent to $userEmail.')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send email. Please try again.'), backgroundColor: Colors.red),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Storage permission is required to download the receipt.'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _downloadHistory() async {
    if (await Permission.storage.request().isGranted) {
      final pdf = pw.Document();
      final user = FirebaseAuth.instance.currentUser;
      final userEmail = user?.email ?? 'User';
      final userName = _customerName ?? user?.displayName ?? userEmail;

      final donationsToDownload = _selectedDateRange != null ? _filteredDonations : _donations;
      final dateRangeString = _selectedDateRange != null
          ? '${DateFormat('MM/dd/yyyy').format(_selectedDateRange!.start)} - ${DateFormat('MM/dd/yyyy').format(_selectedDateRange!.end)}'
          : 'Full History';

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Donation History for $userName', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
              pw.Text('Date Range: $dateRangeString', style: pw.TextStyle(fontSize: 16)),
              pw.SizedBox(height: 20),
              ...donationsToDownload.map((donation) {
                return pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 5),
                  child: pw.Text('Date: ${donation['date']} - Amount: \$${donation['amount']} - Purpose: ${donation['purpose']}'),
                );
              }).toList(),
            ],
          ),
        ),
      );

      // Adding timestamp for unique file name
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'donation_history_${_selectedDateRange?.start.toIso8601String() ?? 'full'}_to_${_selectedDateRange?.end.toIso8601String() ?? 'history'}_$timestamp.pdf';

      // Save file
      await _saveFile(fileName, await pdf.save());

      // Send confirmation email
      try {
        await sendEmailConfirmation(userEmail, userName, dateRangeString);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Donation history downloaded and confirmation email sent to $userEmail.')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send email. Please try again.'), backgroundColor: Colors.red),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Storage permission is required to download the history.'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange ?? DateTimeRange(start: DateTime.now().subtract(Duration(days: 30)), end: DateTime.now()),
    );

    if (picked != null && picked != _selectedDateRange) {
      setState(() {
        _selectedDateRange = picked;
      });
      _filterDonationsByDateRange(picked);
    }
  }

  void _filterDonationsByDateRange(DateTimeRange? dateRange) {
    if (dateRange == null) {
      setState(() {
        _filteredDonations = _donations;
      });
      return;
    }

    setState(() {
      _filteredDonations = _donations.where((donation) {
        DateTime donationDate = DateFormat('yyyy-MM-dd').parse(donation['date']);
        return donationDate.isAfter(dateRange.start.subtract(Duration(days: 1))) &&
            donationDate.isBefore(dateRange.end.add(Duration(days: 1)));
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Donations'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () => _selectDateRange(context),
              child: Text(_selectedDateRange == null
                  ? 'Select Date Range'
                  : 'Selected Range: ${DateFormat('MM/dd/yyyy').format(_selectedDateRange!.start)} - ${DateFormat('MM/dd/yyyy').format(_selectedDateRange!.end)}'),
            ),
          ),
          Expanded(
            child: _filteredDonations.isEmpty
                ? Center(child: Text("No donations available"))
                : ListView.builder(
              itemCount: _filteredDonations.length,
              itemBuilder: (context, index) {
                final donation = _filteredDonations[index];
                return ListTile(
                  title: Text('Amount: \$${donation['amount']}'),
                  subtitle: Text('Date: ${donation['date']}\nPurpose: ${donation['purpose']}'),
                  trailing: IconButton(
                    icon: Icon(Icons.download),
                    onPressed: () => _downloadReceipt(index),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _downloadHistory,
              child: Text('Download selected History'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamedAndRemoveUntil('/volunteerDashboard', (route) => false);
                  },
                  child: Text('Return to Volunteer Dashboard'),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
                  },
                  child: Text('Home'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
