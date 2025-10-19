import 'package:flutter/material.dart';
import '../../widgets/sidebar.dart'; // We will create this reusable sidebar widget
import '../../data/models/user_model.dart';

class DashboardScreen extends StatelessWidget {
  final Widget body; // The "picture" to display inside the frame
  final String title; // The title for the AppBar
  final UserRole userRole; // <-- ADD THE userRole PROPERTY
  const DashboardScreen({super.key,
         required this.body,
        required this.title,
        required this.userRole,


        });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      /// MUBIN/AZROF-TODO: The sidebar will be built here and will show different
      // options based on the user's role (which you can pass down as a parameter).
      drawer: AppSidebar(userRole: userRole), // <-- REMOVED 'const' FROM HERE
      body: body,
    );
  }
}
