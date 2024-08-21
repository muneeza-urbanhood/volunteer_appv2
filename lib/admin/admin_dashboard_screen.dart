import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AdminDashboardScreen extends StatelessWidget {
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<void> _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      await _googleSignIn.signOut(); // Sign out from Google as well
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
    } catch (e) {
      print('Failed to sign out: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to sign out: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/addTask');
                },
                child: Text('Add Task'),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/updateTask');
                },
                child: Text('Update Task'),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/adminViewVolunteerProgress');
                },
                child: Text('View Volunteer Progress'),
              ),
              Spacer(),
              ElevatedButton(
                onPressed: () async {
                  await _signOut(context);
                },
                child: Text('Log Out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
