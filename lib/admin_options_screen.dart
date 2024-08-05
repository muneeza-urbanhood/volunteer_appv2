import 'package:flutter/material.dart';
import 'admin_login_screen.dart';
import 'admin_signup_screen.dart'; // Import the sign-up screen

class AdminOptionsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Options'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/adminLogin');
              },
              child: Text('Admin Login'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/adminSignUp');
              },
              child: Text('Admin Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}
