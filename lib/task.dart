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
      'Assigned Volunteer': assignedVolunteer,
      'dueDate': dueDate,
      'status': status,
    };
  }
}



