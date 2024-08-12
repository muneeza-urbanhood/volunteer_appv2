// class Task {
//   String title;
//   String description;
//   String assignedVolunteer;
//   String dueDate;
//   String status;
//
//   Task(this.title, this.description, this.assignedVolunteer, this.dueDate, this.status);
//
//   Map<String, String> toJson() {
//     return {
//       'title': title,
//       'description': description,
//       'Assigned Volunteer': assignedVolunteer,
//       'dueDate': dueDate,
//       'status': status,
//     };
//   }
// }
class Task {
  String title;
  String description;
  String assignedVolunteer;
  String dueDate;
  String status;

  Task(this.title, this.description, this.assignedVolunteer, this.dueDate, this.status);

  Map<String, String> toJson() {
    return {
      'title': title,
      'description': description,
      'assignedVolunteer': assignedVolunteer,
      'dueDate': dueDate,
      'status': status,
    };
  }

  factory Task.fromMap(Map<dynamic, dynamic> map) {
    return Task(
      map['title'] as String,
      map['description'] as String,
      map['assignedVolunteer'] as String,
      map['dueDate'] as String,
      map['status'] as String,
    );
  }
}



