import 'package:firebase_database/firebase_database.dart';

class Task {
  String title;
  String description;
  String assignedVolunteer;
  String dueDate;
  String status;

  Task(this.title, this.description, this.assignedVolunteer, this.dueDate, this.status);

  Task.fromJson(Map<String, dynamic> json)
      : title = json['title'],
        description = json['description'],
        assignedVolunteer = json['assignedVolunteer'],
        dueDate = json['dueDate'],
        status = json['status'];

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'assignedVolunteer': assignedVolunteer,
    'dueDate': dueDate,
    'status': status,
  };
}

class FirebaseService {
  final DatabaseReference _tasksRef = FirebaseDatabase.instance.ref().child('tasks');

  Future<void> addTask(Task task) async {
    String? taskId = _tasksRef.push().key;
    if (taskId != null) {
      await _tasksRef.child(taskId).set(task.toJson());
    }
  }

  Stream<DatabaseEvent> getTasksStream() {
    return _tasksRef.onValue;
  }
}
