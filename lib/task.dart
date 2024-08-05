class Task {
  final String title;
  final String description;
  final DateTime dueDate;
  final String status;

  Task({
    required this.title,
    required this.description,
    required this.dueDate,
    required this.status,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      title: json['title'] as String,
      description: json['description'] as String,
      dueDate: DateTime.parse(json['dueDate'] as String),
      status: json['status'] as String,
    );
  }
}
