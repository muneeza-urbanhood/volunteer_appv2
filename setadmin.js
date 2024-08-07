const admin = require('firebase-admin');
const serviceAccount = require('./lib/serviceAccountkey.json');

try {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    databaseURL: "https://helloworld-155e1-default-rtdb.firebaseio.com/"
  });

  const uid = '2V4IDJCcA9eI4s7Vcqs5lsPsWah2'; // Replace with the UID of the user you want to make an admin

  admin.auth().setCustomUserClaims(uid, { isAdmin: true })
    .then(() => {
      console.log(`Custom claim 'isAdmin' set for user: ${uid}`);
    })
    .catch((error) => {
      console.error('Error setting custom claim:', error);
    });
} catch (error) {
  console.error('Firebase initialization error:', error);
}