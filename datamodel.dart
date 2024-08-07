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






