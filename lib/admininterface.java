public class AdminActivity extends AppCompatActivity {
    private EditText titleEditText, descriptionEditText, assignedVolunteerEditText, dueDateEditText, statusEditText;
    private Button saveButton;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_admin);

        titleEditText = findViewById(R.id.titleEditText);
        descriptionEditText = findViewById(R.id.descriptionEditText);
        assignedVolunteerEditText = findViewById(R.id.assignedVolunteerEditText);
        dueDateEditText = findViewById(R.id.dueDateEditText);
        statusEditText = findViewById(R.id.statusEditText);
        saveButton = findViewById(R.id.saveButton);

        FirebaseHelper firebaseHelper = new FirebaseHelper();

        saveButton.setOnClickListener(view -> {
            String title = titleEditText.getText().toString();
            String description = descriptionEditText.getText().toString();
            String assignedVolunteer = assignedVolunteerEditText.getText().toString();
            String dueDate = dueDateEditText.getText().toString();
            String status = statusEditText.getText().toString();

            Task task = new Task(title, description, assignedVolunteer, dueDate, status);
            firebaseHelper.addTask(task);
        });
    }
}
