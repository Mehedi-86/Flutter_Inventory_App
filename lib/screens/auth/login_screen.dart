import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/user_model.dart';
import '../../data/services/auth_service.dart';
import '../dashboard/admin_dashboard_screen.dart';
import '../dashboard/staff_dashboard_screen.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadUserEmail();
  }

  void _loadUserEmail() async {
    // AZROF-NOTE: This method handles the "Remember Me" feature by loading
    // a saved email from the device's local storage.
    final prefs = await SharedPreferences.getInstance();
    final String? email = prefs.getString('remembered_email');
    if (email != null) {
      setState(() {
        _emailController.text = email;
        _rememberMe = true;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _errorMessage = null; });

    // --- "Remember Me" Logic ---
    // MEHEDI-NOTE: This section handles saving the user's email for convenience.
    // This is separate from your main task of implementing session persistence.
    // Your work will involve using FirebaseAuth's `authStateChanges()` stream
    // in main.dart to automatically log the user in if their session is still valid.
    final prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setString('remembered_email', _emailController.text.trim());
    } else {
      await prefs.remove('remembered_email');
    }

    try {
      // --- LOGIC HAND-OFF POINT ---
      // MUBIN-NOTE: This is the critical point where the UI (Azrof's work) calls
      // the business logic layer (your work). Your `AuthService` will handle the
      // logic of verifying the user's credentials.

      // MEHEDI-NOTE: You will not change this line. Your work is to go inside the
      // `AuthService.login()` method and replace the dummy logic with a real
      // call to `FirebaseAuth.instance.signInWithEmailAndPassword(...)`.
      final user = await AuthService.instance.login(_emailController.text.trim(), _passwordController.text.trim());

      // --- UI REACTION TO LOGIC ---
      // MUBIN-NOTE: After your `login` method returns a user object, the UI
      // uses the `role` property from that object to decide which screen to show.
      // This is how your logic layer's data drives the user interface.
      if (mounted) {
        if (user.role == UserRole.admin) {
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const AdminDashboardScreen()));
        } else {
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const StaffDashboardScreen()));
        }
      }
    } catch (e) {
      setState(() { _errorMessage = e.toString().replaceFirst('Exception: ', ''); });
    } finally {
      if (mounted) { setState(() { _isLoading = false; }); }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(decoration: const BoxDecoration(image: DecorationImage(image: NetworkImage('https://images.unsplash.com/photo-1556740738-b6a63e27c4df?q=80&w=2070&auto=format&fit=crop'), fit: BoxFit.cover))),
          Container(color: Colors.black.withOpacity(0.6)),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('Inventory App', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center),
                    const SizedBox(height: 40),
                    TextFormField(controller: _emailController, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Email', labelStyle: TextStyle(color: Colors.white70), enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white70)), focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)), prefixIcon: Icon(Icons.email, color: Colors.white70)), keyboardType: TextInputType.emailAddress, validator: (v) => v == null || v.isEmpty ? 'Please enter your email' : (!RegExp(r'\S+@\S+\.\S+').hasMatch(v) ? 'Please enter a valid email' : null)),
                    const SizedBox(height: 16),
                    TextFormField(controller: _passwordController, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Password', labelStyle: TextStyle(color: Colors.white70), enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white70)), focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)), prefixIcon: Icon(Icons.lock, color: Colors.white70)), obscureText: true, validator: (v) => v == null || v.isEmpty ? 'Please enter your password' : null),
                    const SizedBox(height: 8),
                     Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Row(
                            children: [
                              Checkbox(
                                value: _rememberMe,
                                onChanged: (value) {
                                  setState(() { _rememberMe = value ?? false; });
                                },
                                checkColor: Colors.deepPurple,
                                activeColor: Colors.white,
                                side: const BorderSide(color: Colors.white70),
                              ),
                              const Flexible(
                                child: Text(
                                  'Remember Me',
                                  style: TextStyle(color: Colors.white),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            // --- MEHEDI-NOTE ---
                            // This button navigates to the ForgotPasswordScreen. Inside the
                            // AuthService, you will need to implement the real
                            // `sendPasswordResetEmail` function from Firebase.
                             Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
                            );
                          },
                          child: const Text('Forgot Password?', style: TextStyle(color: Colors.white70)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_errorMessage != null) Padding(padding: const EdgeInsets.only(bottom: 16.0), child: Text(_errorMessage!, style: const TextStyle(color: Colors.redAccent), textAlign: TextAlign.center)),
                    _isLoading ? const Center(child: CircularProgressIndicator()) : ElevatedButton(style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)), onPressed: _login, child: const Text('Login')),
                    const SizedBox(height: 24),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Text("Don't have an account?", style: TextStyle(color: Colors.white)), TextButton(onPressed: () { Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SignUpScreen())); }, child: const Text('Sign Up', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))])
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

