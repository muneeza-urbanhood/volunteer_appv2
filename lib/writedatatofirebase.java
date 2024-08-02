import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;

public class FirebaseHelper {

    private DatabaseReference databaseReference;

    public FirebaseHelper() {
        databaseReference = FirebaseDatabase.getInstance().getReference("tasks");
    }

    public void addTask(Task task) {
        String taskId = databaseReference.push().getKey();
        if (taskId != null) {
            databaseReference.child(taskId).setValue(task);
        }
    }
}
