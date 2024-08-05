import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'admin_screen.dart';
import 'volunteer_login_screen.dart';
import 'admin_login_screen.dart';
import 'volunteer_screen.dart';
import 'firebase_options.dart';
import 'filter_sort_tasks.dart';
import 'storetask.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Volunteer Tasks',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: HomeScreen(),  // Define which screen to show first
//     );
//   }
// }

// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';

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
        '/adminLogin': (context) => AdminLoginScreen(),
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
                Navigator.pushNamed(context, '/adminLogin');
              },
              child: Text('Admin Login'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/volunteerLogin');
              },
              child: Text('Volunteer Login'),
            ),
          ],
        ),
      ),
    );
  }
}




