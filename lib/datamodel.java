public class Task {
    private String title;
    private String description;
    private String assignedVolunteer;
    private String dueDate;
    private String status;

    // Constructors, getters, and setters
    public Task() { }

    public Task(String title, String description, String assignedVolunteer, String dueDate, String status) {
        this.title = title;
        this.description = description;
        this.assignedVolunteer = assignedVolunteer;
        this.dueDate = dueDate;
        this.status = status;
    }

    // Getters and setters...
}
