import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'admin_update_task_screen.dart';
import 'admin_dashboard_screen.dart';
import 'admin_login_screen.dart';
import 'admin_signup_screen.dart';
import 'admin_home_screen.dart';
import 'volunteer_login_screen.dart';
import 'volunteer_home_screen.dart';
import 'volunteer_signup_screen.dart';
// import 'volunteer_screen.dart';
import 'add_task_screen.dart';
import 'volunteer_dashboard.dart';
import 'see_volunteer_progress_screen.dart';
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
        '/adminLogin': (context) => AdminLoginScreen(),
        '/adminSignUp': (context) => AdminSignUpScreen(),
        '/adminHome': (context) => AdminHomeScreen(),
        '/adminDashboard': (context) => AdminDashboardScreen(),
        '/addTask': (context) => AddTaskScreen(),
        '/updateTask': (context) => UpdateTaskScreen(),
        '/adminViewVolunteerProgress': (context) => AdminViewVolunteerProgress(),
        '/volunteerLogin': (context) => VolunteerLoginScreen(),
        '/volunteerSignUp': (context) => VolunteerSignUpScreen(),
        '/volunteerHome': (context) => VolunteerHomeScreen(),
        '/volunteerDashboard': (context) => VolunteerDashboard(),
        // '/volunteerscreen': (context) => VolunteerScreen(volunteerId: '')
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
                Navigator.pushNamed(context, '/adminHome');
              },
              child: Text('Admin'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/volunteerHome');
              },
              child: Text('Volunteer'),
            ),
          ],
        ),
      ),
    );
  }
}
