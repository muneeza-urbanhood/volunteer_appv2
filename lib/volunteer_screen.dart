import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'firebase_service.dart';

class VolunteerScreen extends StatelessWidget {
  final FirebaseService _firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Volunteer Tasks'),
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: _firebaseService.getTasksStream(),
        builder: (context, snapshot) {
          if (snapshot.hasData && !snapshot.hasError && snapshot.data!.snapshot.value != null) {
            // Safely cast the snapshot data to Map
            Map<dynamic, dynamic> data = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
            List<Task> tasks = [];
            data.forEach((index, data) => tasks.add(Task.fromJson(Map<String, dynamic>.from(data))));
            return ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(tasks[index].title),
                  subtitle: Text(tasks[index].description),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
