import 'package:flutter/material.dart';
import 'datamodel.dart';
import 'firebase_service.dart';

// Define the ConfirmationScreen widget
class ConfirmationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Confirmation'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Task Assigned!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.popUntil(context, ModalRoute.withName('/home'));
              },
              child: Text('Back to Home Screen'),
            ),
          ],
        ),
      ),
    );
  }
}

// Define the AdminScreen widget
class AdminScreen extends StatefulWidget {
  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dueDateController = TextEditingController();
  String _status = 'New'; // Default value
  String? _selectedVolunteerName;

  final FirebaseService _firebaseService = FirebaseService();
  List<Map<String, String>> _volunteers = []; // List of volunteer names and emails

  @override
  void initState() {
    super.initState();
    _fetchVolunteers(); // Fetch volunteers when the screen is initialized
  }

  Future<void> _fetchVolunteers() async {
    try {
      final volunteers = await _firebaseService.getVolunteers();
      print("Volunteers fetched: $volunteers"); // Debug log
      setState(() {
        _volunteers = volunteers;
        if (_volunteers.isNotEmpty) {
          _selectedVolunteerName = _volunteers[0]['name']; // Default selection by name
        }
      });
    } catch (e) {
      print("Failed to fetch volunteers: $e");
    }
  }

  Future<void> _selectDueDate(BuildContext context) async {
    DateTime initialDate = DateTime.now();

    // Show date picker
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (selectedDate != null) {
      setState(() {
        _dueDateController.text = "${selectedDate.toLocal()}".split(' ')[0]; // Format date as YYYY-MM-DD
      });
    }
  }

  void _saveTask() async {
    String title = _titleController.text;
    String description = _descriptionController.text;
    String assignedVolunteer = _selectedVolunteerName ?? '';
    String dueDate = _dueDateController.text;
    String status = _status;

    Task task = Task(
      title,
      description,
      assignedVolunteer,
      dueDate,
      status,
    );

    try {
      await _firebaseService.addTask(task);
      Navigator.pushNamedAndRemoveUntil(context, '/adminDashboard', (route) => false);
    } catch (e) {
      print("Failed to save task: $e");
    }
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
            // Dropdown for selecting assigned volunteer
            DropdownButtonFormField<String>(
              value: _selectedVolunteerName,
              decoration: InputDecoration(labelText: 'Assigned Volunteer'),
              items: _volunteers.map((volunteer) {
                return DropdownMenuItem<String>(
                  value: volunteer['name'],
                  child: Text(volunteer['name']!),
                );
              }).toList(),
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