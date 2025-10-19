import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/auth/login_screen.dart';

// MEHEDI-TODO: You will need to add Firebase initialization here.
// 1. Make sure to call `WidgetsFlutterBinding.ensureInitialized();`
// 2. Then, call `await Firebase.initializeApp(...)` before runApp.
// 3. You will also need to change the main function to be `async`.
//    e.g., `void main() async { ... }`

void main() async {
  // This line is required to use async/await before runApp()
  WidgetsFlutterBinding.ensureInitialized();
  
  // This loads the variables from your .env file
  await dotenv.load(fileName: ".env");

  // This uses your keys from the .env file to connect to the correct Firebase project
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: dotenv.env['FIREBASE_API_KEY']!,
      authDomain: dotenv.env['FIREBASE_AUTH_DOMAIN']!,
      projectId: dotenv.env['FIREBASE_PROJECT_ID']!,
      storageBucket: dotenv.env['FIREBASE_STORAGE_BUCKET']!,
      messagingSenderId: dotenv.env['FIREBASE_MESSAGING_SENDER_ID']!,
      appId: dotenv.env['FIREBASE_APP_ID']!,
      measurementId: dotenv.env['FIREBASE_MEASUREMENT_ID'], // Add measurement ID for web
    ),
  );
  
  // This runs your app after Firebase has been initialized
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Hides the debug banner in the corner
      debugShowCheckedModeBanner: false,
      
      // A title for your app, used by the operating system
      title: 'Inventory App',
      
      // --- THEME SETUP ---
      // This provides a consistent visual theme for your entire application.
      // You can customize colors, fonts, and more here.
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        // Define a consistent style for all ElevatedButtons
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      
      // --- INITIAL SCREEN ---
      // This is the first screen the user will see.
      //
      // MEHEDI-TODO: Later, this will be replaced with a "wrapper" or "auth gate" widget.
      // That widget will check the user's authentication state using a StreamBuilder
      // and show the LoginScreen if the user is logged out, or the DashboardScreen
      // if they are already logged in.
      home: const LoginScreen(),
    );
  }
}
