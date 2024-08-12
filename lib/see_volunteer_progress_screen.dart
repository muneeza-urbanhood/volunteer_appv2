import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class AdminViewVolunteerProgress extends StatefulWidget {
  @override
  _AdminViewVolunteerProgressState createState() => _AdminViewVolunteerProgressState();
}

class _AdminViewVolunteerProgressState extends State<AdminViewVolunteerProgress> {
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
    _fetchVolunteersAndTasks(); // Fetch volunteers and tasks together
  }

  Future<void> _fetchVolunteersAndTasks() async {
    setState(() {
      _loadingTasks = true;
    });

    try {
      // Fetch volunteers first
      DataSnapshot volunteerSnapshot = await _database.child('volunteers').get();
      if (volunteerSnapshot.exists) {
        final List<Map<String, String>> volunteerList = [];
        Map<dynamic, dynamic>? volunteersData = volunteerSnapshot.value as Map<dynamic, dynamic>?;
        if (volunteersData != null) {
          volunteersData.forEach((key, value) {
            if (value is Map) {
              final String name = value['name'] as String? ?? '';
              if (name.isNotEmpty) {
                volunteerList.add({'id': key, 'name': name});
                _volunteerNames[key] = name; // Map UID to name
              }
            }
          });
        }
        setState(() {
          _volunteers = volunteerList;
        });
      }

      // Now fetch tasks after volunteers have been loaded
      DataSnapshot taskSnapshot = await _database.child('tasks').get();
      if (taskSnapshot.exists) {
        final List<Task> taskList = [];
        Map<dynamic, dynamic>? tasksData = taskSnapshot.value as Map<dynamic, dynamic>?;
        if (tasksData != null) {
          tasksData.forEach((key, value) {
            if (value is Map) {
              final String assignedVolunteerId = value['assignedVolunteer'];
              final String assignedVolunteerName =
                  _volunteerNames[assignedVolunteerId] ?? 'Unknown'; // Get name by UID
              taskList.add(Task.fromMap(value, key, assignedVolunteerId, assignedVolunteerName));
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
      print('Failed to fetch data: $e');
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
        title: Text('Volunteer Task Progress'),
      ),
      body: _loadingTasks
          ? Center(child: CircularProgressIndicator())
          : Padding(
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
            Expanded(
              child: filteredTasks.isEmpty
                  ? Center(child: Text('No tasks found.'))
                  : ListView.builder(
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
      Map<dynamic, dynamic> map, String key, String assignedVolunteerId, String assignedVolunteerName) {
    return Task(
      key: key,
      title: map['title'] ?? 'No Title',
      description: map['description'] ?? 'No Description',
      dueDate: DateTime.parse(map['dueDate'] ?? DateTime.now().toIso8601String()),
      status: map['status'] ?? 'No Status',
      assignedVolunteerId: assignedVolunteerId,
      assignedVolunteerName: assignedVolunteerName,
    );
  }
}

extension DateTimeFormatting on DateTime {
  String toShortDateString() {
    return '${this.day}-${this.month}-${this.year}';
  }
}
