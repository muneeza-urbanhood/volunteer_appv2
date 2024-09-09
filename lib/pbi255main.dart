import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'admin/admin_update_task_screen.dart';
import 'admin/admin_dashboard_screen.dart';
import 'admin/admin_login_screen.dart';
import 'admin/admin_signup_screen.dart';
import 'admin/admin_home_screen.dart';
import 'volunteer/volunteer_login_screen.dart';
import 'volunteer/volunteer_home_screen.dart';
import 'volunteer/volunteer_signup_screen.dart';
import 'task/add_task_screen.dart';
import 'volunteer/volunteer_dashboard.dart';
import 'task/see_volunteer_progress_screen.dart';
import 'firebase/firebase_options.dart';
import 'donation/donation_history_screen.dart';  // Import the donation screen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Urban Food Alliance',
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
        '/donationHistory': (context) => DonationHistoryScreen(),  // Add the new route
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
