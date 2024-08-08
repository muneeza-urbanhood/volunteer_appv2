import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'task.dart';

class AdminViewVolunteerProgress extends StatefulWidget {
  @override
  _AdminViewVolunteerProgressState createState() => _AdminViewVolunteerProgressState();
}

class _AdminViewVolunteerProgressState extends State<AdminViewVolunteerProgress> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  Map<String, List<Task>> _volunteerTasks = {};
  Map<String, String> _volunteerNames = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchVolunteerTasks();
  }

  Future<void> _fetchVolunteerTasks() async {
    await _fetchVolunteerNames();
    try {
      DataSnapshot snapshot = await _database.child('tasks').get();
      if (snapshot.exists) {
        final Map<String, List<Task>> volunteerTasks = {};
        Map<dynamic, dynamic>? tasksData = snapshot.value as Map<dynamic, dynamic>?;
        if (tasksData != null) {
          tasksData.forEach((key, value) {
            if (value is Map) {
              final Task task = Task.fromMap(value);
              final String volunteerUID = value['assignedVolunteer'] as String? ?? '';
              if (volunteerUID.isNotEmpty) {
                volunteerTasks.putIfAbsent(volunteerUID, () => []).add(task);
              }
            }
          });
        }
        setState(() {
          _volunteerTasks = volunteerTasks;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        print('No tasks found.');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Failed to fetch tasks: $e');
    }
  }

  Future<void> _fetchVolunteerNames() async {
    try {
      DataSnapshot snapshot = await _database.child('volunteers').get();
      if (snapshot.exists) {
        final Map<String, String> volunteerNames = {};
        Map<dynamic, dynamic>? volunteersData = snapshot.value as Map<dynamic, dynamic>?;
        if (volunteersData != null) {
          volunteersData.forEach((uid, data) {
            if (data is Map) {
              final String name = data['name'] as String? ?? '';
              if (name.isNotEmpty) {
                volunteerNames[uid] = name;
              }
            }
          });
        }
        setState(() {
          _volunteerNames = volunteerNames;
        });
      } else {
        print('No volunteers found.');
      }
    } catch (e) {
      print('Failed to fetch volunteer names: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Volunteer Task Progress'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _volunteerTasks.isEmpty
          ? Center(child: Text('No tasks found.'))
          : ListView.builder(
        itemCount: _volunteerTasks.length,
        itemBuilder: (context, index) {
          final String volunteerUID = _volunteerTasks.keys.elementAt(index);
          final List<Task> tasks = _volunteerTasks[volunteerUID]!;
          final String volunteerName = _volunteerNames[volunteerUID] ?? 'Unknown Volunteer';
          return ExpansionTile(
            title: Text(volunteerName),
            children: tasks.map((task) {
              return ListTile(
                title: Text(task.title),
                subtitle: Text(task.description),
                trailing: Text(task.status),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
