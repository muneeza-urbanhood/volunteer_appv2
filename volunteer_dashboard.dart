import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VolunteerDashboard extends StatefulWidget {
  @override
  _VolunteerDashboardState createState() => _VolunteerDashboardState();
}

class _VolunteerDashboardState extends State<VolunteerDashboard> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  List<Map<String, String>> _volunteers = [];
  Map<String, String> _volunteerNames = {};
  List<Task> _tasks = [];
  String _selectedFilter = 'All';
  String _selectedSort = 'Due Date';

  @override
  void initState() {
    super.initState();
    _fetchVolunteers();
    _loadTasks(); // Load tasks when the screen initializes
  }

  Future<void> _fetchVolunteers() async {
    try {
      DataSnapshot snapshot = await _database.child('volunteers').get();
      if (snapshot.exists) {
        final List<Map<String, String>> volunteerList = [];
        Map<dynamic, dynamic>? volunteersData = snapshot.value as Map<dynamic, dynamic>?;
        if (volunteersData != null) {
          volunteersData.forEach((key, value) {
            if (value is Map) {
              final String name = value['name'] as String? ?? '';
              if (name.isNotEmpty) {
                volunteerList.add({'id': key, 'name': name});
                _volunteerNames[key] = name;
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

  void _loadTasks() {
    final user = _auth.currentUser;
    if (user != null) {
      final String? uid = user.uid;
      print("Current user UID: $uid");

      _database.child('tasks').onValue.listen((event) {
        final List<Task> tasks = [];
        final data = event.snapshot.value as Map?;
        print("Data received from Firebase: $data");

        if (data != null) {
          data.forEach((key, value) {
            if (value is Map && value['assignedVolunteer'] == uid) {
              tasks.add(Task.fromMap(value, key, _volunteerNames[uid] ?? 'Unknown'));
            }
          });
        } else {
          print("No tasks found for user $uid");
        }

        setState(() {
          _tasks = _sortAndFilterTasks(tasks); // Apply sorting and filtering
          print("Loaded tasks after sorting and filtering: ${_tasks.length} tasks");
        });
      });
    } else {
      print("No current user found.");
    }
  }

  List<Task> _sortAndFilterTasks(List<Task> tasks) {
    // Filter tasks based on the selected status
    List<Task> filteredTasks = tasks.where((task) {
      String taskStatus = task.status.trim().toLowerCase();
      String filterStatus = _selectedFilter.trim().toLowerCase();
      bool isMatch = filterStatus == 'all' || taskStatus == filterStatus;
      print("Filtering task: ${task.title}, Status: ${task.status}, isMatch: $isMatch");
      return isMatch;
    }).toList();

    print("Filtered tasks: ${filteredTasks.length}");

    // Sort the filtered tasks based on the selected sort option
    if (_selectedSort == 'Due Date') {
      filteredTasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    } else if (_selectedSort == 'Status') {
      filteredTasks.sort((a, b) => a.status.compareTo(b.status));
    }

    return filteredTasks;
  }

  void _updateTaskStatus(Task task, String newStatus) async {
    try {
      // Update the status in the Firebase database
      await _database.child('tasks').child(task.key).update({'status': newStatus});

      // Update the local state
      setState(() {
        task.status = newStatus;
        _tasks = _sortAndFilterTasks(_tasks); // Reapply filter after status update
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Task status updated successfully!')),
      );
    } catch (e) {
      print('Failed to update task status: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update task status: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Volunteer Dashboard'),
      ),
      body: Column(
        children: [
          _buildFilterDropdown(),
          _buildSortDropdown(),
          Expanded(
            child: _tasks.isEmpty
                ? Center(child: Text("No tasks available"))
                : ListView.builder(
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                final task = _tasks[index];
                return ListTile(
                  title: Text(task.title),
                  subtitle: Text(
                    '${task.description}\nDue Date: ${task.dueDate.toLocal().toShortDateString()}\nStatus: ${task.status}\nAssigned to: ${task.assignedVolunteerName}',
                  ),
                  isThreeLine: true,
                  trailing: ElevatedButton(
                    onPressed: () => _showUpdateStatusDialog(task),
                    child: Text('Update Status'),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () async {
                await _auth.signOut();
                Navigator.of(context).pushNamedAndRemoveUntil('/volunteerOptions', (route) => false);
              },
              child: Text('Sign Out'),
            ),
          ),
        ],
      ),
    );
  }

  void _showUpdateStatusDialog(Task task) {
    showDialog(
      context: context,
      builder: (context) {
        String? _newStatus = task.status;
        return AlertDialog(
          title: Text('Update Task Status'),
          content: DropdownButtonFormField<String>(
            value: _newStatus,
            decoration: InputDecoration(labelText: 'Status'),
            items: <String>['New', 'Active', 'Complete', 'Bug'].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _newStatus = newValue;
              });
            },
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Update'),
              onPressed: () {
                if (_newStatus != null && _newStatus != task.status) {
                  _updateTaskStatus(task, _newStatus!);
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilterDropdown() {
    return DropdownButton<String>(
      value: _selectedFilter,
      onChanged: (value) {
        setState(() {
          _selectedFilter = value ?? 'All';
          _tasks = _sortAndFilterTasks(_tasks);
        });
      },
      items: ['All', 'New', 'Active', 'Bug', 'Complete']
          .map((status) => DropdownMenuItem(
        child: Text(status),
        value: status,
      ))
          .toList(),
    );
  }

  Widget _buildSortDropdown() {
    return DropdownButton<String>(
      value: _selectedSort,
      onChanged: (value) {
        setState(() {
          _selectedSort = value ?? 'Due Date';
          _tasks = _sortAndFilterTasks(_tasks);
        });
      },
      items: ['Due Date', 'Status']
          .map((sortOption) => DropdownMenuItem(
        child: Text(sortOption),
        value: sortOption,
      ))
          .toList(),
    );
  }
}

class Task {
  final String key; // Unique key for each task
  final String title;
  final String description;
  final DateTime dueDate;
  String status; // Mutable to update the status
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

  factory Task.fromMap(Map<dynamic, dynamic> map, String key, String assignedVolunteerName) {
    return Task(
      key: key,
      title: map['title'] ?? 'No Title',
      description: map['description'] ?? 'No Description',
      dueDate: DateTime.parse(map['dueDate'] ?? DateTime.now().toIso8601String()),
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
