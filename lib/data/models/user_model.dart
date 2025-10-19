import 'package:cloud_firestore/cloud_firestore.dart';

// This enum defines the possible roles a user can have in the system.
enum UserRole { admin, staff }

class AppUser {
  final String uid;
  final String email;
  final UserRole role;

  AppUser({
    required this.uid,
    required this.email,
    required this.role,
  });

  // --- NEW: METHOD TO CONVERT A USER OBJECT TO A FIRESTORE MAP ---
  // This method is used when you want to save a user's data to Firestore.
  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'email': email,
      // We store the role as a simple string (e.g., 'admin' or 'staff') in the database.
      'role': role.name, 
    };
  }

  // --- NEW: FACTORY TO CREATE A USER OBJECT FROM A FIRESTORE DOCUMENT ---
  // This factory is used when you fetch user data from Firestore.
  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    // Firestore data comes back as a Map.
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return AppUser(
      uid: data['uid'] ?? '',
      email: data['email'] ?? '',
      // We read the role string from the database and convert it back to our UserRole enum.
      role: UserRole.values.firstWhere(
        (e) => e.name == data['role'],
        orElse: () => UserRole.staff, // Default to 'staff' if the role is missing or invalid.
      ),
    );
  }
}
