import 'package:firebase_database/firebase_database.dart';
import 'datamodel.dart';

class FirebaseService {
  final DatabaseReference _tasksRef = FirebaseDatabase.instance.ref().child(
      'tasks');
  final DatabaseReference _volunteersRef = FirebaseDatabase.instance.ref()
      .child('volunteers');

  Future<void> addTask(Task task) async {
    String? taskId = _tasksRef
        .push()
        .key;
    if (taskId != null) {
      await _tasksRef.child(taskId).set(task.toJson());
    }
  }

  Stream<DatabaseEvent> getTasksStreamForVolunteer(String volunteerID) {
    Query volunteerTasksQuery = _tasksRef.orderByChild('assignedVolunteer')
        .equalTo(volunteerID);
    return volunteerTasksQuery.onValue;
  }

  Future<List<Map<String, String>>> getVolunteers() async {
    try {
      final snapshot = await _volunteersRef.once();
      print("Snapshot value: ${snapshot.snapshot.value}"); // Debug log

      if (snapshot.snapshot.value != null) {
        Map<dynamic, dynamic> volunteersData = Map<dynamic, dynamic>.from(
            snapshot.snapshot.value as Map);
        List<Map<String, String>> volunteersList = volunteersData.values.map((
            volunteer) {
          return {
            'email': volunteer['email'] as String,
            'name': volunteer['name'] as String,
          };
        }).toList();

        print("Volunteers fetched: $volunteersList"); // Debug log
        return volunteersList;
      } else {
        return [];
      }
    } catch (e) {
      print("Failed to fetch volunteers: $e");
      return [];
    }
  }
}
