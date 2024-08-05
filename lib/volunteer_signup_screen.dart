import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class VolunteerSignUpScreen extends StatefulWidget {
  @override
  _VolunteerSignUpScreenState createState() => _VolunteerSignUpScreenState();
}

class _VolunteerSignUpScreenState extends State<VolunteerSignUpScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();  // Add name field
  final _auth = FirebaseAuth.instance;
  final _database = FirebaseDatabase.instance.ref();
  final _formKey = GlobalKey<FormState>();

  Future<void> _signUp() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        if (_passwordController.text == _confirmPasswordController.text) {
          UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
            email: _emailController.text,
            password: _passwordController.text,
          );

          // Save user information to Firebase Realtime Database
          await _database.child('volunteers').child(userCredential.user!.uid).set({
            'email': _emailController.text,
            'name': _nameController.text,
            'tasks': [], // Initialize with an empty list of tasks
          });

          Navigator.pushReplacementNamed(context, '/volunteerDashboard');
        } else {
          _showErrorDialog('Passwords do not match');
        }
      } catch (e) {
        _showErrorDialog(e.toString());
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('An error occurred'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: Text('Okay'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Volunteer Sign Up'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'Password'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'Confirm Password'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _signUp,
                child: Text('Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
