import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VolunteerDashboard extends StatefulWidget {
  @override
  _VolunteerDashboardState createState() => _VolunteerDashboardState();
}

class _VolunteerDashboardState extends State<VolunteerDashboard> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  List<Task> _tasks = [];
  String _selectedFilter = 'All';
  String _selectedSort = 'Due Date';

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  void _loadTasks() {
    final user = _auth.currentUser;
    if (user != null) {
      print("Current user display name: ${user.displayName}"); // Debugging line

      _database
          .ref()
          .child('tasks')
          .orderByChild('assignedTo')
          .equalTo(user.displayName) // Filter by user display name
          .onValue
          .listen((event) {
        final List<Task> tasks = [];
        final data = event.snapshot.value as Map?;
        print("Data received from Firebase: $data"); // Debugging line

        if (data != null) {
          data.forEach((key, value) {
            print("Task data: $value"); // Debugging line
            tasks.add(Task.fromMap(value));
          });
        } else {
          print("No data found for user ${user.displayName}"); // Debugging line
        }

        setState(() {
          _tasks = _sortAndFilterTasks(tasks);
          print("Loaded tasks after sorting and filtering: $_tasks"); // Debugging line
        });
      });
    } else {
      print("No current user found."); // Debugging line
    }
  }

  List<Task> _sortAndFilterTasks(List<Task> tasks) {
    List<Task> filteredTasks = tasks.where((task) {
      if (_selectedFilter == 'All') return true;
      return task.status == _selectedFilter;
    }).toList();

    if (_selectedSort == 'Due Date') {
      filteredTasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    } else if (_selectedSort == 'Status') {
      filteredTasks.sort((a, b) => a.status.compareTo(b.status));
    }

    return filteredTasks;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Volunteer Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await _auth.signOut();
              Navigator.of(context).pop();
            },
          ),
        ],
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
                      '${task.description}\nDue Date: ${task.dueDate.toLocal().toShortDateString()}\nStatus: ${task.status}'),
                  isThreeLine: true,
                );
              },
            ),
          ),
        ],
      ),
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
      items: ['All', 'New', 'Active', 'Bug', 'Completed']
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
  final String title;
  final String description;
  final DateTime dueDate;
  final String status;

  Task({
    required this.title,
    required this.description,
    required this.dueDate,
    required this.status,
  });

  factory Task.fromMap(Map<dynamic, dynamic> map) {
    return Task(
      title: map['title'] ?? 'No Title',
      description: map['description'] ?? 'No Description',
      dueDate: DateTime.parse(map['dueDate'] ?? DateTime.now().toIso8601String()),
      status: map['status'] ?? 'No Status',
    );
  }
}

extension DateTimeFormatting on DateTime {
  String toShortDateString() {
    return '${this.day}-${this.month}-${this.year}';
  }
}
