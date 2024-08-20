import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:volunteer_app/task/gmail_login_service.dart';

class AdminLoginScreen extends StatefulWidget {
  @override
  _AdminLoginScreenState createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final GmailLoginService _loginService = GmailLoginService();

  void _signIn() async {
    try {
      // Sign in using Firebase Authentication
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      final user = userCredential.user;

      // Check if the user exists in the admins section of the Realtime Database
      DataSnapshot snapshot = await _database.child('admins/${user!.uid}').get();

      if (snapshot.exists) {
        // Navigate to the admin dashboard
        Navigator.pushReplacementNamed(
          context,
          '/adminDashboard', // Change this route to your admin dashboard
          arguments: user.uid, // Pass user ID to AdminScreen if needed
        );
      } else {
        // If user is not an admin, sign out and show error
        await _auth.signOut();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('This account is not registered as an admin.')),
        );
      }
    } catch (e) {
      print("Failed to sign in: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign in failed: ${e.toString()}')),
      );
    }
  }

  void _signInWithGoogle() async {
    final user = await _loginService.loginWithGoogle(role: 'admin');

    if (user != null) {
      Navigator.pushReplacementNamed(context, '/adminDashboard');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('This account is not registered as an admin.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Sign In'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _signIn,
              child: Text('Login'),
            ),
            ElevatedButton(
              onPressed: _signInWithGoogle,
              child: Text('Login with Gmail'),
            ),
          ],
        ),
      ),
    );
  }
}
