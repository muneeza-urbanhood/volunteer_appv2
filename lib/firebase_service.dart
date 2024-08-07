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

  Stream<DatabaseEvent> getTasksStreamForVolunteer(String volunteerName) {
    Query volunteerTasksQuery = _tasksRef.orderByChild('assignedVolunteer').equalTo(volunteerName);
    return volunteerTasksQuery.onValue;
  }

  Future<List<Map<String, String>>> getVolunteers() async {
    try {
      final snapshot = await _volunteersRef
          .get(); // Use get() instead of once()
      if (snapshot.value != null) {
        Map<dynamic, dynamic> volunteersData = Map<dynamic, dynamic>.from(
            snapshot.value as Map);
        List<Map<String, String>> volunteersList = volunteersData.entries.map((
            entry) {
          Map<dynamic, dynamic> value = entry.value;
          return {
            'name': value['name'] as String,
            'email': value['email'] as String,
          };
        }).toList();
        print("Volunteers fetched: $volunteersList"); // Debug log
        return volunteersList;
      } else {
        print("No volunteers found.");
        return [];
      }
    } catch (e) {
      print("Failed to fetch volunteers: $e");
      return [];
    }
  }
}