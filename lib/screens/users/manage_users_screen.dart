import 'package:flutter/material.dart';
import '../../data/models/user_model.dart';
import '../../data/services/user_service.dart';
import '../../data/services/data_change_notifier.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  late Future<List<AppUser>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
    dataChangeNotifier.addListener(_fetchUsers);
  }

  @override
  void dispose() {
    dataChangeNotifier.removeListener(_fetchUsers);
    super.dispose();
  }

  void _fetchUsers() {
    if (mounted) {
      setState(() {
        _usersFuture = UserService.instance.getUsers();
      });
    }
  }

  void _showConfirmationDialog({
    required String title,
    required String content,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            child: const Text('Confirm'),
            onPressed: () {
              onConfirm();
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Staff Users'),
      ),
      body: FutureBuilder<List<AppUser>>(
        future: _usersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No users found.'));
          }

          final allUsers = snapshot.data!;
          final staffUsers = allUsers.where((user) => user.role == UserRole.staff).toList();

          if (staffUsers.isEmpty) {
            return const Center(
              child: Text(
                'No staff users have been added yet.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: staffUsers.length,
            itemBuilder: (context, index) {
              final user = staffUsers[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  leading: const Icon(Icons.account_circle, size: 40, color: Colors.grey),
                  title: Text(user.email, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Chip(
                    label: Text(
                      user.role.name[0].toUpperCase() + user.role.name.substring(1),
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Colors.blueGrey,
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'promote') {
                        _showConfirmationDialog(
                          title: 'Promote User?',
                          content: 'Are you sure you want to promote ${user.email} to Admin?',
                          onConfirm: () => UserService.instance.promoteToAdmin(userId: user.uid),
                        );
                      } else if (value == 'delete') {
                        _showConfirmationDialog(
                          title: 'Delete User?',
                          content: 'Are you sure you want to permanently delete ${user.email}?',
                          onConfirm: () => UserService.instance.deleteUser(userId: user.uid),
                        );
                      }
                    },
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'promote',
                        child: ListTile(
                          leading: Icon(Icons.admin_panel_settings),
                          title: Text('Promote to Admin'),
                        ),
                      ),
                      const PopupMenuDivider(),
                      const PopupMenuItem<String>(
                        value: 'delete',
                        child: ListTile(
                          leading: Icon(Icons.delete, color: Colors.red),
                          title: Text('Delete User', style: TextStyle(color: Colors.red)),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}