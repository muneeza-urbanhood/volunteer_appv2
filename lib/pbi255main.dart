import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'admin_dashboard.dart';
import 'admin_login_screen.dart';
import 'admin_home_screen.dart';
import 'admin_signup_screen.dart';
import 'add_task_screen.dart';
import 'update_task_screen.dart';
import 'volunteer_login_screen.dart';
import 'volunteer_home_screen.dart';
import 'volunteer_signup_screen.dart';
import 'volunteer_dashboard.dart';
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
        '/volunteerSignUp': (context) => VolunteerSignUpScreen(),
        '/admin': (context) => AdminScreen(),
        '/adminLogin': (context) => AdminLoginScreen(),
        '/adminSignUp': (context) => AdminSignUpScreen(),
        '/adminDashboard': (context) => AdminDashboardScreen(),
        '/addTask': (context) => AddTaskScreen(),
        '/updateTask': (context) => UpdateTaskScreen(),
        '/volunteerOptions': (context) => VolunteerOptionsScreen(),
        '/volunteerDashboard': (context) => VolunteerDashboard(),
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
                Navigator.pushNamed(context, '/admin'); // Navigate to AdminScreen
              },
              child: Text('Admin'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/volunteerOptions');
              },
              child: Text('Volunteer'),
            ),
          ],
        ),
      ),
    );
  }
}
