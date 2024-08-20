import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import '../task/gmail_signup_service.dart';

class VolunteerSignUpScreen extends StatefulWidget {
  @override
  _VolunteerSignUpScreenState createState() => _VolunteerSignUpScreenState();
}

class _VolunteerSignUpScreenState extends State<VolunteerSignUpScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final _signUpService = GmailSignUpService();
  bool _isSignedUp = false;

  void _signUp() async {
    final email = _emailController.text;
    final password = _passwordController.text;
    final name = _nameController.text;

    try {
      // Create a new user in Firebase Authentication
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save user information to Firebase Realtime Database
      await _database.child('volunteers').child(userCredential.user!.uid).set({
        'email': email,
        'name': name,
      });

      // Update the state to show the confirmation message
      setState(() {
        _isSignedUp = true;
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sign Up Failed: $error')));
    }
  }

  void _signUpWithGoogle() async {
    final name = _nameController.text;
    final user = await _signUpService.signUpWithGoogle(role: 'volunteers', name: name);

    if (user != null) {
      setState(() {
        _isSignedUp = true;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Google Sign-Up Failed')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Volunteer Sign Up'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: _isSignedUp
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'You are signed up!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/home',
                        (Route<dynamic> route) => false,
                  );
                },
                child: Text('Back to Home Screen'),
              ),
            ],
          ),
        )
            : Column(
          children: <Widget>[
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Create Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _signUp,
              child: Text('Sign Up'),
            ),
            ElevatedButton(
              onPressed: _signUpWithGoogle,
              child: Text('Sign Up with Gmail'),
            ),
          ],
        ),
      ),
    );
  }
}
