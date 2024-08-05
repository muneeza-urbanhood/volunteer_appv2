// import 'package:firebase_database/firebase_database.dart';
//
// Future<void> addTaskForVolunteer(String userId, String taskId, String title, String description, String dueDate, String status) async {
//   DatabaseReference ref = FirebaseDatabase.instance.ref("volunteer_tasks/$userId/$taskId");
//
//   try {
//     await ref.set({
//       "title": title,
//       "description": description,
//       "assigned_volunteer": userId,
//       "due_date": dueDate,
//       "status": status,
//     });
//     print("Task added successfully.");
//   } catch (error) {
//     print("Failed to add task: $error");
//   }
// }


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

