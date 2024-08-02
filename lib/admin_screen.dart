import 'package:flutter/material.dart';
import 'pbi255main.dart';
import 'firebase_service.dart';  // Ensure to import the Firebase service

class AdminScreen extends StatefulWidget {
  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _assignedVolunteerController = TextEditingController();
  final TextEditingController _dueDateController = TextEditingController();
  final TextEditingController _statusController = TextEditingController();
  final FirebaseService _firebaseService = FirebaseService();

  void _saveTask() {
    String title = _titleController.text;
    String description = _descriptionController.text;
    String assignedVolunteer = _assignedVolunteerController.text;
    String dueDate = _dueDateController.text;
    String status = _statusController.text;

    Task task = Task(title, description, assignedVolunteer, dueDate, status);
    _firebaseService.addTask(task);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Screen'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            TextField(
              controller: _assignedVolunteerController,
              decoration: InputDecoration(labelText: 'Assigned Volunteer'),
            ),
            TextField(
              controller: _dueDateController,
              decoration: InputDecoration(labelText: 'Due Date'),
            ),
            TextField(
              controller: _statusController,
              decoration: InputDecoration(labelText: 'Status'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveTask,
              child: Text('Save Task'),
            ),
          ],
        ),
      ),
    );
  }
}
