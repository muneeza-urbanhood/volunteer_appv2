import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class AddTaskScreen extends StatefulWidget {
  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dueDateController = TextEditingController();

  String? _selectedVolunteerName;
  String? _status = 'New';
  List<String> _volunteers = [];

  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  @override
  void initState() {
    super.initState();
    _dueDateController.text = ''; // Initialize the due date text field
    _fetchVolunteers();
  }

  Future<void> _fetchVolunteers() async {
    try {
      DataSnapshot snapshot = await _database.child('volunteers').get();
      if (snapshot.exists) {
        final List<String> volunteerList = [];
        Map<dynamic, dynamic>? volunteersData = snapshot.value as Map<dynamic, dynamic>?;
        if (volunteersData != null) {
          volunteersData.forEach((key, value) {
            if (value is Map) {
              final String name = value['name'] as String? ?? '';
              if (name.isNotEmpty) {
                volunteerList.add(name);
              }
            }
          });
        }
        print('Volunteers fetched: $volunteerList'); // Debugging line
        setState(() {
          _volunteers = volunteerList;
        });
      } else {
        print('No volunteers found.'); // Debugging line
      }
    } catch (e) {
      print('Failed to fetch volunteers: $e');
    }
  }

  Future<void> _selectDueDate(BuildContext context) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (selectedDate != null) {
      setState(() {
        _dueDateController.text = '${selectedDate.toLocal()}'.split(' ')[0];
      });
    }
  }

  void _saveTask() async {
    final taskData = {
      'title': _titleController.text,
      'description': _descriptionController.text,
      'assignedVolunteer': _selectedVolunteerName,
      'dueDate': _dueDateController.text,
      'status': _status,
    };

    try {
      await _database.child('tasks').push().set(taskData);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Task saved successfully!')),
      );
      // Navigate to the confirmation screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => TaskAssignedScreen()),
      );
    } catch (e) {
      print('Failed to save task: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save task: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Task'),
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
            // Dropdown for selecting assigned volunteer
            DropdownButtonFormField<String>(
              value: _selectedVolunteerName,
              decoration: InputDecoration(labelText: 'Assigned Volunteer'),
              items: _volunteers.isNotEmpty
                  ? _volunteers.map((volunteer) {
                return DropdownMenuItem<String>(
                  value: volunteer,
                  child: Text(volunteer),
                );
              }).toList()
                  : [DropdownMenuItem<String>(value: null, child: Text('No volunteers available'))],
              onChanged: (String? newValue) {
                setState(() {
                  _selectedVolunteerName = newValue;
                });
              },
            ),
            TextField(
              controller: _dueDateController,
              decoration: InputDecoration(
                labelText: 'Due Date',
                suffixIcon: IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () => _selectDueDate(context),
                ),
              ),
              readOnly: true, // Make text field read-only
            ),
            DropdownButtonFormField<String>(
              value: _status,
              decoration: InputDecoration(labelText: 'Status'),
              items: <String>['New', 'Active', 'Complete', 'Bug'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _status = newValue!;
                });
              },
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

class TaskAssignedScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task Assigned'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Task Assigned!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/adminDashboard');
              },
              child: Text('Back to Admin Dashboard'),
            ),
          ],
        ),
      ),
    );
  }
}
