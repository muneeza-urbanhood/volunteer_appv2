import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class SeeCurrentStatusScreen extends StatefulWidget {
  @override
  _SeeCurrentStatusScreenState createState() => _SeeCurrentStatusScreenState();
}

class _SeeCurrentStatusScreenState extends State<SeeCurrentStatusScreen> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  List<Map<String, String>> _volunteers = [];
  Map<String, String> _volunteerNames = {};
  String? _selectedVolunteerId = 'All';
  String _selectedStatus = 'All';
  List<Task> _tasks = [];
  bool _loadingTasks = false;

  @override
  void initState() {
    super.initState();
    _fetchVolunteers();
    _fetchTasks(); // Fetch all tasks initially
  }

  Future<void> _fetchVolunteers() async {
    try {
      DataSnapshot snapshot = await _database.child('volunteers').get();
      if (snapshot.exists) {
        final List<Map<String, String>> volunteerList = [];
        Map<dynamic, dynamic>? volunteersData =
        snapshot.value as Map<dynamic, dynamic>?;
        if (volunteersData != null) {
          volunteersData.forEach((key, value) {
            if (value is Map) {
              final String name = value['name'] as String? ?? '';
              if (name.isNotEmpty) {
                volunteerList.add({'id': key, 'name': name});
                _volunteerNames[key] = name;
                print('Volunteer added: $key - $name'); // Debug print
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
    setState(() {
      _loadingTasks = true;
      _tasks = [];
    });

    try {
      DataSnapshot snapshot = await _database.child('tasks').get();
      if (snapshot.exists) {
        final List<Task> taskList = [];
        Map<dynamic, dynamic>? tasksData =
        snapshot.value as Map<dynamic, dynamic>?;
        if (tasksData != null) {
          tasksData.forEach((key, value) {
            if (value is Map) {
              final String assignedVolunteerId = value['assignedVolunteer'];
              final String assignedVolunteerName =
                  _volunteerNames[assignedVolunteerId] ?? 'Unknown';
              print('Task added: $key assigned to $assignedVolunteerName'); // Debug print
              taskList.add(
                  Task.fromMap(value, key, assignedVolunteerName));
            }
          });
        }
        setState(() {
          _tasks = taskList;
        });
      } else {
        setState(() {
          _tasks = [];
        });
      }
    } catch (e) {
      print('Failed to fetch tasks: $e');
    }

    setState(() {
      _loadingTasks = false;
    });
  }

  List<Task> _filterTasks() {
    List<Task> filteredTasks = _tasks;
    if (_selectedVolunteerId != 'All') {
      filteredTasks = filteredTasks
          .where((task) => task.assignedVolunteerId == _selectedVolunteerId)
          .toList();
    }
    if (_selectedStatus != 'All') {
      filteredTasks = filteredTasks
          .where((task) => task.status == _selectedStatus)
          .toList();
    }
    return filteredTasks;
  }

  @override
  Widget build(BuildContext context) {
    final filteredTasks = _filterTasks();

    return Scaffold(
      appBar: AppBar(
        title: Text('See Current Status'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            DropdownButtonFormField<String>(
              value: _selectedVolunteerId,
              decoration: InputDecoration(labelText: 'Filter by Volunteer'),
              items: [
                DropdownMenuItem(value: 'All', child: Text('All')),
                ..._volunteers.map((volunteer) {
                  return DropdownMenuItem<String>(
                    value: volunteer['id'],
                    child: Text(volunteer['name'] ?? 'Unknown'),
                  );
                }).toList(),
              ],
              onChanged: (String? newValue) {
                setState(() {
                  _selectedVolunteerId = newValue;
                });
              },
            ),
            SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedStatus,
              decoration: InputDecoration(labelText: 'Filter by Status'),
              items: [
                DropdownMenuItem(value: 'All', child: Text('All')),
                DropdownMenuItem(value: 'New', child: Text('New')),
                DropdownMenuItem(value: 'Active', child: Text('Active')),
                DropdownMenuItem(value: 'Complete', child: Text('Complete')),
                DropdownMenuItem(value: 'Bug', child: Text('Bug')),
              ],
              onChanged: (String? newValue) {
                setState(() {
                  _selectedStatus = newValue!;
                });
              },
            ),
            SizedBox(height: 20),
            _loadingTasks
                ? CircularProgressIndicator()
                : filteredTasks.isEmpty
                ? Text('No tasks have been assigned.')
                : Expanded(
              child: ListView.builder(
                itemCount: filteredTasks.length,
                itemBuilder: (context, index) {
                  final task = filteredTasks[index];
                  return ListTile(
                    title: Text(task.title),
                    subtitle: Text(
                      '${task.description}\nDue Date: ${task.dueDate.toLocal().toShortDateString()}\nStatus: ${task.status}\nAssigned to: ${task.assignedVolunteerName}',
                    ),
                    isThreeLine: true,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Task {
  final String key; // Unique key for each task
  final String title;
  final String description;
  final DateTime dueDate;
  final String status; // Immutable status
  final String assignedVolunteerId; // Volunteer ID to whom the task is assigned
  final String assignedVolunteerName; // Volunteer name to whom the task is assigned

  Task({
    required this.key,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.status,
    required this.assignedVolunteerId,
    required this.assignedVolunteerName,
  });

  factory Task.fromMap(
      Map<dynamic, dynamic> map, String key, String assignedVolunteerName) {
    return Task(
      key: key,
      title: map['title'] ?? 'No Title',
      description: map['description'] ?? 'No Description',
      dueDate:
      DateTime.parse(map['dueDate'] ?? DateTime.now().toIso8601String()),
      status: map['status'] ?? 'No Status',
      assignedVolunteerId: map['assignedVolunteer'] ?? '',
      assignedVolunteerName: assignedVolunteerName,
    );
  }
}

extension DateTimeFormatting on DateTime {
  String toShortDateString() {
    return '${this.day}-${this.month}-${this.year}';
  }
}
