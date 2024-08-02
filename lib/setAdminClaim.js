const admin = require('firebase-admin');

// Initialize the Firebase Admin SDK
const serviceAccount = require('./serviceAccountKey.json'); // Update path if needed

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

// Function to set custom claims
const setAdminClaim = async (uid) => {
  try {
    await admin.auth().setCustomUserClaims(uid, { isAdmin: true });
    console.log(`Custom claim set for user ${uid}`);
  } catch (error) {
    console.error('Error setting custom claim:', error);
  }
};

// Replace with the UID of the user you want to make an admin
const userUID = 'USER_UID_HERE';

setAdminClaim(userUID);
