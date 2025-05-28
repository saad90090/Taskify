import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> signIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen()),
      );
    } catch (e) {
      showError(e.toString());
    }
    setState(() => _isLoading = false);
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    final inputDecoration = InputDecoration(
      filled: true,
      fillColor: Colors.white,
      hintStyle: TextStyle(color: Colors.grey[600]),
      contentPadding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.blue.shade400, width: 2),
      ),
    );

    return Scaffold(
      backgroundColor: Color(0xFFF7F9FC),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Image.asset('assets/images/loho.png', width: 275, height: 275),
                SizedBox(height: 36),
                TextFormField(
                  controller: emailController,
                  decoration: inputDecoration.copyWith(
                    hintText: 'Enter your email',
                    labelStyle: TextStyle(color: Colors.blueGrey),
                    labelText: 'Email',
                    prefixIcon: Icon(
                      Icons.alternate_email_rounded,
                      color: Colors.blueGrey,
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) =>
                      value!.isEmpty ? 'Enter your email' : null,
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: passwordController,
                  decoration: inputDecoration.copyWith(
                    hintText: 'Enter your password',
                    labelStyle: TextStyle(color: Colors.blueGrey),
                    labelText: 'Password',
                    prefixIcon: Icon(
                      Icons.lock_rounded,
                      color: Colors.blueGrey,
                    ),
                  ),
                  obscureText: true,
                  validator: (value) =>
                      value!.length < 6 ? 'Minimum 6 characters' : null,
                ),
                SizedBox(height: 30),
                _isLoading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: signIn,
                        style: ElevatedButton.styleFrom(
                          elevation: 4,
                          backgroundColor: Colors.blue.shade600,
                          minimumSize: Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          'Sign In',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => RegisterScreen()),
                    );
                  },
                  child: Text(
                    'Don’t have an account? Register',
                    style: TextStyle(color: Colors.blue.shade600),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
