import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../donation/donation_history_screen.dart';
import 'volunteer_see_task.dart'; // Import the SeeTasksScreen

class VolunteerDashboard extends StatefulWidget {
  @override
  _VolunteerDashboardState createState() => _VolunteerDashboardState();
}

class _VolunteerDashboardState extends State<VolunteerDashboard> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Volunteer Dashboard'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                // Navigate to the See Tasks screen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SeeTasksScreen()),
                );
              },
              child: Text('See Tasks'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                // Navigate to the Donation History screen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DonationHistoryScreen()),
                );
              },
              child: Text('Donation History'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _signOut,
              child: Text('Sign Out'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _signOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut(); // Sign out from Google as well
      print('User signed out successfully');
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false); // Redirect to home screen
    } catch (e) {
      print('Failed to sign out: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to sign out: ${e.toString()}')),
      );
    }
  }
}
