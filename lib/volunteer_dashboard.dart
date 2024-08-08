import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Task {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  String status;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.status,
  });
}

class VolunteerDashboard extends StatefulWidget {
  @override
  _VolunteerDashboardState createState() => _VolunteerDashboardState();
}

class _VolunteerDashboardState extends State<VolunteerDashboard> {
  late DatabaseReference _tasksRef;
  late String _currentUserUid;
  List<Task> _tasks = [];
  List<Task> _filteredTasks = [];
  String _selectedStatus = 'Status';
  String _selectedSortByDueDate = 'Due Date';
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _tasksRef = FirebaseDatabase.instance.ref('tasks');
    _currentUserUid = FirebaseAuth.instance.currentUser!.uid;
    _fetchTasks();
  }

  Future<void> _fetchTasks() async {
    final snapshot = await _tasksRef.get();
    final tasksList = <Task>[];
    snapshot.children.forEach((child) {
      final taskData = child.value as Map<dynamic, dynamic>;
      final dueDate = _parseDate(taskData['dueDate'] as String);
      final task = Task(
        id: child.key!,
        title: taskData['title'] as String,
        description: taskData['description'] as String,
        dueDate: dueDate,
        status: taskData['status'] as String,
      );
      if (taskData['assignedVolunteer'] == _currentUserUid) {
        tasksList.add(task);
      }
    });
    setState(() {
      _tasks = tasksList;
      _applyFilters();
    });
  }

  DateTime _parseDate(String dateString) {
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return DateTime.now();
    }
  }

  void _applyFilters() {
    List<Task> filteredTasks = _tasks;

    if (_selectedStatus != 'All') {
      filteredTasks = filteredTasks.where((task) => task.status == _selectedStatus).toList();
    }

    if (_startDate != null && _endDate != null) {
      filteredTasks = _filterByDateRange(filteredTasks, _startDate!, _endDate!);
    }

    // Sort tasks by Due Date
    if (_selectedSortByDueDate == 'Ascending') {
      filteredTasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    } else if (_selectedSortByDueDate == 'Descending') {
      filteredTasks.sort((a, b) => b.dueDate.compareTo(a.dueDate));
    }

    setState(() {
      _filteredTasks = filteredTasks;
    });
  }

  List<Task> _filterByDateRange(List<Task> tasks, DateTime startDate, DateTime endDate) {
    return tasks.where((task) {
      return task.dueDate.isAfter(startDate) && task.dueDate.isBefore(endDate);
    }).toList();
  }

  Future<void> _updateTaskStatus(String taskId, String newStatus) async {
    await _tasksRef.child(taskId).update({'status': newStatus});
    setState(() {
      final task = _tasks.firstWhere((task) => task.id == taskId);
      task.status = newStatus;
      _applyFilters();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Volunteer Dashboard'),
      ),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButton<String>(
                  value: _selectedStatus,
                  items: ['Status', 'All', 'Active', 'Bug', 'Complete']
                      .map((status) => DropdownMenuItem<String>(
                    value: status,
                    child: Text(status),
                  ))
                      .toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedStatus = newValue!;
                      _applyFilters();
                    });
                  },
                ),
              ),
              Expanded(
                child: DropdownButton<String>(
                  value: _selectedSortByDueDate,
                  items: ['Due Date', 'Ascending', 'Descending']
                      .map((sortOption) => DropdownMenuItem<String>(
                    value: sortOption,
                    child: Text(sortOption),
                  ))
                      .toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedSortByDueDate = newValue!;
                      _applyFilters();
                    });
                  },
                ),
              ),
              IconButton(
                icon: Icon(Icons.date_range),
                onPressed: () => _selectDateRange(context),
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredTasks.length,
              itemBuilder: (context, index) {
                final task = _filteredTasks[index];
                return ListTile(
                  title: Text(task.title),
                  subtitle: Text(
                    '${task.description}\nDue: ${task.dueDate.toLocal()}\nStatus: ${task.status}',
                    style: TextStyle(fontSize: 14),
                  ),
                  trailing: DropdownButton<String>(
                    value: task.status,
                    items: ['New', 'Active', 'Bug', 'Complete']
                        .map((status) => DropdownMenuItem<String>(
                      value: status,
                      child: Text(status),
                    ))
                        .toList(),
                    onChanged: (newStatus) {
                      if (newStatus != null && newStatus != 'Update Status') {
                        _updateTaskStatus(task.id, newStatus);
                      }
                    },
                    icon: Icon(Icons.arrow_downward),
                    underline: SizedBox(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTime? pickedStartDate = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedStartDate != null) {
      final DateTime? pickedEndDate = await showDatePicker(
        context: context,
        initialDate: _endDate ?? DateTime.now(),
        firstDate: pickedStartDate,
        lastDate: DateTime(2100),
      );

      if (pickedEndDate != null) {
        setState(() {
          _startDate = pickedStartDate;
          _endDate = pickedEndDate;
          _applyFilters();
        });
      }
    }
  }
}
