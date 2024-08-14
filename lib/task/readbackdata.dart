import 'package:firebase_database/firebase_database.dart';

Future<void> verifyTaskSaved(String userId, String taskId) async {
  DatabaseReference ref = FirebaseDatabase.instance.ref("volunteer_tasks/$userId/$taskId");

  try {
    DataSnapshot snapshot = await ref.get();
    if (snapshot.exists) {
      print("Task data: ${snapshot.value}");
    } else {
      print("No data found for the task.");
    }
  } catch (error) {
    print("Failed to read task: $error");
  }
}



