import '../models/user_model.dart';
import 'data_change_notifier.dart';

// --- DESIGN PATTERN: SINGLETON ---
class UserService {
  UserService._internal();
  static final UserService _instance = UserService._internal();
  static UserService get instance => _instance;

  // MUBIN-NOTE: This is our in-memory "users" table. We initialize it with
  // the same dummy users from the manage_users_screen.dart file.
  final List<AppUser> _users = [
    AppUser(uid: '1', email: 'admin@gmail.com', role: UserRole.admin),
    AppUser(uid: '3', email: 'staff@gmail.com', role: UserRole.staff),
    AppUser(uid: '4', email: 'staff2@gmail.com', role: UserRole.staff),
  ];

  /// Fetches a list of all users.
  Future<List<AppUser>> getUsers() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _users;
  }

  /// Changes a user's role from staff to admin.
  Future<void> promoteToAdmin({required String userId}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final userIndex = _users.indexWhere((user) => user.uid == userId);

    if (userIndex != -1) {
      final user = _users[userIndex];
      // Create a new user instance with the updated role
      _users[userIndex] = AppUser(
        uid: user.uid,
        email: user.email,
        role: UserRole.admin,
      );
      dataChangeNotifier.notify(); // Notify listeners of the change
    }
  }

  /// Deletes a user from the in-memory list.
  Future<void> deleteUser({required String userId}) async {
    await Future.delayed(const Duration(milliseconds: 600));
    _users.removeWhere((user) => user.uid == userId);
    dataChangeNotifier.notify(); // Notify listeners of the change
  }
}