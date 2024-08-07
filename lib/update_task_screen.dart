import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class UpdateTaskScreen extends StatefulWidget {
  @override
  _UpdateTaskScreenState createState() => _UpdateTaskScreenState();
}

class _UpdateTaskScreenState extends State<UpdateTaskScreen> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  List<Map<String, dynamic>> _tasks = [];
  Map<String, dynamic>? _selectedTask;
  String? _selectedTaskKey;
  String? _selectedVolunteerName;
  String? _status;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dueDateController = TextEditingController();

  List<String> _volunteers = [];
  List<Map<String, dynamic>> _filteredTasks = [];

  @override
  void initState() {
    super.initState();
    _fetchVolunteers();
    _fetchTasks();
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
        setState(() {
          _volunteers = volunteerList;
        });
      }
    } catch (e) {
      print('Failed to fetch volunteers: $e');
    }
  }

  Future<void> _fetchTasks() async {
    try {
      DataSnapshot snapshot = await _database.child('tasks').get();
      if (snapshot.exists) {
        final List<Map<String, dynamic>> taskList = [];
        Map<dynamic, dynamic>? tasksData = snapshot.value as Map<dynamic, dynamic>?;
        if (tasksData != null) {
          tasksData.forEach((key, value) {
            if (value is Map) {
              taskList.add({'key': key, ...Map<String, dynamic>.from(value)});
            }
          });
        }
        setState(() {
          _tasks = taskList;
          _filterTasksByVolunteer();
        });
      }
    } catch (e) {
      print('Failed to fetch tasks: $e');
    }
  }

  void _filterTasksByVolunteer() {
    setState(() {
      _filteredTasks = _selectedVolunteerName != null
          ? _tasks.where((task) => task['assignedVolunteer'] == _selectedVolunteerName).toList()
          : [];
    });
  }

  void _onTaskSelected(Map<String, dynamic> selectedTask) {
    setState(() {
      _selectedTask = selectedTask;
      _selectedTaskKey = selectedTask['key'];
      _titleController.text = selectedTask['title'] ?? '';
      _descriptionController.text = selectedTask['description'] ?? '';
      _dueDateController.text = selectedTask['dueDate'] ?? '';
      _status = selectedTask['status'];
    });
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

  void _updateTask() async {
    if (_selectedTaskKey == null) return;

    final updatedTaskData = {
      'title': _titleController.text,
      'description': _descriptionController.text,
      'assignedVolunteer': _selectedVolunteerName,
      'dueDate': _dueDateController.text,
      'status': _status,
    };

    try {
      await _database.child('tasks').child(_selectedTaskKey!).update(updatedTaskData);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Task updated successfully!')),
      );
      Navigator.pop(context);
    } catch (e) {
      print('Failed to update task: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update task: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            DropdownButtonFormField<String>(
              value: _selectedVolunteerName,
              decoration: InputDecoration(labelText: 'Assigned Volunteer'),
              items: _volunteers.map((volunteer) {
                return DropdownMenuItem<String>(
                  value: volunteer,
                  child: Text(volunteer),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedVolunteerName = newValue;
                  _filterTasksByVolunteer();
                  _selectedTask = null; // Clear selected task when volunteer changes
                  _selectedTaskKey = null;
                  _titleController.clear();
                  _descriptionController.clear();
                  _dueDateController.clear();
                  _status = null;
                });
              },
            ),
            DropdownButtonFormField<Map<String, dynamic>>(
              value: _selectedTask,
              decoration: InputDecoration(labelText: 'Select Task'),
              items: _filteredTasks.map((task) {
                return DropdownMenuItem<Map<String, dynamic>>(
                  value: task,
                  child: Text(task['title'] ?? 'No Title'),
                );
              }).toList(),
              onChanged: (Map<String, dynamic>? selectedTask) {
                if (selectedTask != null) {
                  _onTaskSelected(selectedTask);
                }
              },
            ),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
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
              onPressed: _updateTask,
              child: Text('Update Task'),
            ),
          ],
        ),
      ),
    );
  }
}
