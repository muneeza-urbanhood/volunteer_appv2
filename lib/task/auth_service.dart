import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_database/firebase_database.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  Future<User?> signUpWithEmail(String email, String password, String name, String role) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;

      if (user != null) {
        await _db.child('$role/${user.uid}').set({
          'email': email,
          'name': name,
        });
      }

      return user;
    } catch (e) {
      print("Error during email sign up: $e");
      return null;
    }
  }

  Future<User?> signInWithEmail(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print("Error during email sign in: $e");
      return null;
    }
  }

  Future<User?> signUpWithGoogle(String role, String name) async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null; // The user canceled the sign-in

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null) {
        final dbRef = _db.child('$role/${user.uid}');
        final snapshot = await dbRef.get();

        if (!snapshot.exists) {
          await dbRef.set({
            'email': user.email,
            'name': name,
          });
        }
      }

      return user;
    } catch (e) {
      print("Error during Google sign up: $e");
      return null;
    }
  }

  Future<User?> loginWithGoogle(String role) async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null) {
        final snapshot = await _db.child('$role/${user.uid}').get();
        if (!snapshot.exists) {
          await _auth.signOut();
          return null; // User is not in the correct role
        }
      }

      return user;
    } catch (e) {
      print("Error during Google login: $e");
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await GoogleSignIn().signOut();
  }
}
