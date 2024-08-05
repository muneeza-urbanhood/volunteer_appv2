import 'package:flutter/material.dart';
import 'volunteer_login_screen.dart'; // Import the login screen
import 'volunteer_signup_screen.dart'; // Import the sign-up screen

class VolunteerOptionsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Volunteer Options'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/volunteerLogin');
              },
              child: Text('Volunteer Login'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/volunteerSignUp');
              },
              child: Text('Volunteer Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}
