import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AdminSignUpScreen extends StatefulWidget {
  @override
  _AdminSignUpScreenState createState() => _AdminSignUpScreenState();
}

class _AdminSignUpScreenState extends State<AdminSignUpScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  bool _isSignedUp = false;

  void _signUp() async {
    try {
      // Sign out of any existing Google accounts
      await _googleSignIn.signOut();

      final email = _emailController.text;
      final password = _passwordController.text;
      final name = _nameController.text;

      // Create a new user in Firebase Authentication
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save user information to Firebase Realtime Database
      await _database.child('admins').child(userCredential.user!.uid).set({
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
    try {
      // Sign out of any existing Google accounts
      await _googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Google Sign-Up Canceled')));
        return;
      }

      //comment

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null) {
        final dbRef = _database.child('admins/${user.uid}');
        final snapshot = await dbRef.get();

        if (!snapshot.exists) {
          await dbRef.set({
            'email': user.email,
            'name': _nameController.text.isNotEmpty ? _nameController.text : user.displayName,
          });
          setState(() {
            _isSignedUp = true;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('User already exists as an admin')));
        }
      }
    } catch (e) {
      print("Error during Google sign up: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Google Sign-Up Failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Sign Up'),
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
