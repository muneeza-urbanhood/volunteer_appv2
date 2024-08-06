import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'admin_screen.dart';
import 'volunteer_login_screen.dart';
import 'admin_login_screen.dart';
import 'admin_signup_screen.dart';
import 'admin_options_screen.dart';
import 'volunteer_options_screen.dart';
import 'volunteer_signup_screen.dart';
import 'volunteer_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/home',
      routes: {
        '/home': (context) => HomeScreen(),
        '/volunteerLogin': (context) => VolunteerLoginScreen(),
        '/volunteerSignUp': (context) => VolunteerSignUpScreen(), // Add this route
        '/adminLogin': (context) => AdminLoginScreen(),
        '/adminSignUp': (context) => AdminSignUpScreen(),
        '/adminOptions': (context) => AdminOptionsScreen(),
        '/volunteerOptions': (context) => VolunteerOptionsScreen(), // Add this route
        '/volunteerDashboard': (context) => VolunteerScreen(volunteerId: '',),
        '/adminDashboard': (context) => AdminScreen(),
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Urban Food Alliance Tasks'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/adminOptions');
              },
              child: Text('Admin'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/volunteerOptions'); // Navigate to Volunteer Options
              },
              child: Text('Volunteer'),
            ),
          ],
        ),
      ),
    );
  }
}
