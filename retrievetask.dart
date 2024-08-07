import 'package:firebase_database/firebase_database.dart';

void listenToVolunteerTasks(String userId) {
  DatabaseReference ref = FirebaseDatabase.instance.ref("volunteer_tasks/$userId");

  ref.onValue.listen((DatabaseEvent event) {
    if (event.snapshot.exists) {
      print("Tasks updated: ${event.snapshot.value}");
      // You can update your UI here with the new data
    } else {
      print("No tasks available.");
    }
  });
}
