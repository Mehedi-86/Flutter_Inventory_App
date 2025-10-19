import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/user_model.dart';

// --- DESIGN PATTERN: SINGLETON ---
// This class ensures that there is only one instance of AuthService in the app.
class AuthService {
  // Private constructor
  AuthService._internal();

  // The single, static instance of the class
  static final AuthService _instance = AuthService._internal();

  // Public getter to access the instance
  static AuthService get instance => _instance;

  // --- FIREBASE INSTANCES ---
  // MEHEDI-TODO: This entire list will be removed and replaced by Firestore calls.
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- NEW: DUMMY LOGOUT LOGIC ---
  Future<void> logout() async {
    // MEHEDI-TODO: This will be replaced with a single Firebase call.
    // Use `await FirebaseAuth.instance.signOut();`
    // No need to handle navigation here; that's the UI's job.
    await _auth.signOut();
    print('User logged out.');
  }


  // --- NEW: DUMMY FORGOT PASSWORD LOGIC ---
  Future<void> forgotPassword(String email) async {
    // MEHEDI-TODO: This entire block will be replaced with a single Firebase call.
    // Use `await FirebaseAuth.instance.sendPasswordResetEmail(email: email);`
    // You should wrap it in a try-catch block to handle potential Firebase
    // errors, like 'user-not-found'.
    try {
      await _auth.sendPasswordResetEmail(email: email);
      print('Password reset link sent to $email');
    } on FirebaseAuthException catch (e) {
      print('Error sending password reset email: ${e.message}');
      throw Exception(e.message ?? 'An unknown error occurred.');
    }
  }


  // --- NEW: METHOD TO CHECK FOR EXISTING ADMIN ---
  Future<bool> adminExists() async {
    // MEHEDI-TODO: Replace this dummy logic with a real Firestore query.
    // You will need to query the 'users' collection to see if any document
    // has a 'role' field equal to 'admin'.
    // Example Query:
    // final query = await firestore.collection('users').where('role', isEqualTo: 'admin').limit(1).get();
    // return query.docs.isNotEmpty;
    final query = await _firestore
        .collection('users')
        .where('role', isEqualTo: UserRole.admin.name)
        .limit(1)
        .get();
        
    return query.docs.isNotEmpty;
  }

  // --- DUMMY LOGIN LOGIC ---
  Future<AppUser> login(String email, String password) async {
    // MEHEDI-TODO: This entire logic block will be replaced by a single call:
    // await FirebaseAuth.instance.signInWithEmailAndPassword(...)
    // You will handle exceptions from Firebase (e.g., user-not-found, wrong-password).
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw Exception('Login failed, user not found.');
      }

      final DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(firebaseUser.uid).get();

      if (!userDoc.exists) {
        throw Exception('User data not found in database.');
      }
      
      return AppUser.fromFirestore(userDoc);

    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Error on login: ${e.message}');
      throw Exception(e.message ?? 'Invalid email or password.');
    }
  }

  // --- NEW: DUMMY SIGN UP LOGIC ---
  Future<void> signUp({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    // MEHEDI-TODO: This will be replaced by two Firebase calls:
    // 1. `FirebaseAuth.instance.createUserWithEmailAndPassword(...)`
    // 2. A call to Firestore to save the user's details (name, role) in a 'users' collection.
    try {
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw Exception('Sign up failed, could not create user.');
      }

      final newUser = AppUser(
        uid: firebaseUser.uid,
        email: email,
        role: role,
      );

      await _firestore.collection('users').doc(newUser.uid).set(newUser.toFirestore());

      print('New user signed up and data saved to Firestore: ${newUser.email}, Role: ${newUser.role}');

    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Error on sign up: ${e.message}');
      throw Exception(e.message ?? 'An unknown error occurred during sign up.');
    }
  }
}

