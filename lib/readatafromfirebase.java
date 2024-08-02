import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.ValueEventListener;

public void readTasks() {
    databaseReference.addValueEventListener(new ValueEventListener() {
        @Override
        public void onDataChange(DataSnapshot dataSnapshot) {
            for (DataSnapshot snapshot : dataSnapshot.getChildren()) {
                Task task = snapshot.getValue(Task.class);
                // Update your UI with the task data
            }
        }

        @Override
        public void onCancelled(DatabaseError databaseError) {
            // Handle possible errors
        }
    });
}
