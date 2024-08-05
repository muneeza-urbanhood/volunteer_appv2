// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter/material.dart';
// import 'firebase_service.dart';
//
// class VolunteerScreen extends StatefulWidget {
//   final String volunteerId;
//
//   VolunteerScreen({required this.volunteerId});
//
//   @override
//   _VolunteerScreenState createState() => _VolunteerScreenState();
// }
//
// class _VolunteerScreenState extends State<VolunteerScreen> {
//   final FirebaseService _firebaseService = FirebaseService();
//   late Stream<DatabaseEvent> _tasksStream;
//   List<Task> _tasks = [];
//   String _filter = 'All'; // Default filter
//   String _sortBy = 'Due Date'; // Default sorting
//
//   @override
//   void initState() {
//     super.initState();
//     _tasksStream = _firebaseService.getTasksStreamForVolunteer(widget.volunteerId);
//     _startListening();
//   }
//
//   void _startListening() {
//     _tasksStream.listen((event) {
//       final data = event.snapshot.value;
//       if (data != null) {
//         Map<dynamic, dynamic> taskData = Map<dynamic, dynamic>.from(data as Map);
//         List<Task> loadedTasks = [];
//         taskData.forEach((key, value) {
//           loadedTasks.add(Task.fromJson(Map<String, dynamic>.from(value)));
//         });
//         _applyFilterAndSort(loadedTasks);
//       }
//     });
//   }
//
//   void _applyFilterAndSort(List<Task> tasks) {
//     List<Task> filteredTasks;
//     if (_filter == 'All') {
//       filteredTasks = tasks;
//     } else {
//       filteredTasks = tasks.where((task) => task.status == _filter).toList();
//     }
//
//     if (_sortBy == 'Due Date') {
//       filteredTasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));
//     } else if (_sortBy == 'Status') {
//       filteredTasks.sort((a, b) => a.status.compareTo(b.status));
//     }
//
//     setState(() {
//       _tasks = filteredTasks;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('My Tasks'),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.filter_list),
//             onPressed: _showFilterDialog,
//           ),
//           IconButton(
//             icon: Icon(Icons.sort),
//             onPressed: _showSortDialog,
//           ),
//         ],
//       ),
//       body: _tasks.isEmpty
//           ? Center(child: Text('No tasks available.'))
//           : ListView.builder(
//         itemCount: _tasks.length,
//         itemBuilder: (context, index) {
//           final task = _tasks[index];
//           return ListTile(
//             title: Text(task.title),
//             subtitle: Text(
//               '${task.description}\nDue Date: ${task.dueDate}\nStatus: ${task.status}',
//               style: TextStyle(fontSize: 16),
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   void _showFilterDialog() {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text('Filter Tasks'),
//           content: DropdownButton<String>(
//             value: _filter,
//             onChanged: (String? newValue) {
//               setState(() {
//                 _filter = newValue!;
//                 Navigator.of(context).pop();
//                 _applyFilterAndSort(_tasks);
//               });
//             },
//             items: <String>['All', 'New', 'Active', 'Complete', 'Bug']
//                 .map<DropdownMenuItem<String>>((String value) {
//               return DropdownMenuItem<String>(
//                 value: value,
//                 child: Text(value),
//               );
//             }).toList(),
//           ),
//         );
//       },
//     );
//   }
//
//   void _showSortDialog() {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text('Sort Tasks'),
//           content: DropdownButton<String>(
//             value: _sortBy,
//             onChanged: (String? newValue) {
//               setState(() {
//                 _sortBy = newValue!;
//                 Navigator.of(context).pop();
//                 _applyFilterAndSort(_tasks);
//               });
//             },
//             items: <String>['Due Date', 'Status']
//                 .map<DropdownMenuItem<String>>((String value) {
//               return DropdownMenuItem<String>(
//                 value: value,
//                 child: Text(value),
//               );
//             }).toList(),
//           ),
//         );
//       },
//     );
//   }
// }






import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'datamodel.dart';
import 'firebase_service.dart';

class VolunteerScreen extends StatefulWidget {
  final String volunteerId;

  VolunteerScreen({required this.volunteerId});

  @override
  _VolunteerScreenState createState() => _VolunteerScreenState();
}

class _VolunteerScreenState extends State<VolunteerScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  late Stream<DatabaseEvent> _tasksStream;
  List<Task> _tasks = [];
  String _filter = 'All'; // Default filter
  String _sortBy = 'Due Date'; // Default sorting

  @override
  void initState() {
    super.initState();
    _tasksStream = _firebaseService.getTasksStreamForVolunteer(widget.volunteerId);
    _startListening();
  }

  void _startListening() {
    _tasksStream.listen((event) {
      final data = event.snapshot.value;
      print("Data received: $data"); // Debugging line
      if (data != null) {
        Map<dynamic, dynamic> taskData = Map<dynamic, dynamic>.from(data as Map);
        List<Task> loadedTasks = [];
        taskData.forEach((key, value) {
          print("Task: $value"); // Debugging line
          loadedTasks.add(Task.fromJson(Map<String, dynamic>.from(value)));
        });
        _applyFilterAndSort(loadedTasks);
      } else {
        print("No data found."); // Debugging line
      }
    });
  }

  void _applyFilterAndSort(List<Task> tasks) {
    List<Task> filteredTasks;
    if (_filter == 'All') {
      filteredTasks = tasks;
    } else {
      filteredTasks = tasks.where((task) => task.status == _filter).toList();
    }

    if (_sortBy == 'Due Date') {
      filteredTasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    } else if (_sortBy == 'Status') {
      filteredTasks.sort((a, b) => a.status.compareTo(b.status));
    }

    setState(() {
      _tasks = filteredTasks;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Tasks'),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () {
              _showFilterDialog();
            },
          ),
          IconButton(
            icon: Icon(Icons.sort),
            onPressed: () {
              _showSortDialog();
            },
          ),
        ],
      ),
      body: _tasks.isEmpty
          ? Center(child: Text('No tasks available.')) // Display message if no tasks
          : ListView.builder(
        itemCount: _tasks.length,
        itemBuilder: (context, index) {
          final task = _tasks[index];
          return ListTile(
            title: Text(task.title),
            subtitle: Text(
              '${task.description}\nDue Date: ${task.dueDate}\nStatus: ${task.status}',
              style: TextStyle(fontSize: 16),
            ),
          );
        },
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Filter Tasks'),
          content: DropdownButton<String>(
            value: _filter,
            onChanged: (String? newValue) {
              setState(() {
                _filter = newValue!;
                Navigator.of(context).pop();
                _applyFilterAndSort(_tasks);
              });
            },
            items: <String>['All', 'New', 'Active', 'Complete', 'Bug']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Sort Tasks'),
          content: DropdownButton<String>(
            value: _sortBy,
            onChanged: (String? newValue) {
              setState(() {
                _sortBy = newValue!;
                Navigator.of(context).pop();
                _applyFilterAndSort(_tasks);
              });
            },
              items: <String>['Due Date', 'Status']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
          ),
        );
      },
    );
  }
}
