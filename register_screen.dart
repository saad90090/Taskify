import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final dobController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
            'name': nameController.text.trim(),
            'dob': dobController.text.trim(),
            'email': emailController.text.trim(),
            'createdAt': Timestamp.now(),
          });

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
                  controller: nameController,
                  decoration: inputDecoration.copyWith(
                    labelStyle: TextStyle(color: Colors.blueGrey),
                    labelText: 'Full Name',
                    hintText: 'Enter your full name',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Enter your name' : null,
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: dobController,
                  decoration: inputDecoration.copyWith(
                    labelStyle: TextStyle(color: Colors.blueGrey),
                    labelText: 'Date of Birth',
                    hintText: 'Enter your DOB',
                    prefixIcon: Icon(Icons.calendar_today_outlined),
                  ),
                  keyboardType: TextInputType.datetime,
                  validator: (value) =>
                      value!.isEmpty ? 'Enter your date of birth' : null,
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: emailController,
                  decoration: inputDecoration.copyWith(
                    labelStyle: TextStyle(color: Colors.blueGrey),
                    labelText: 'Email',
                    hintText: 'Enter your email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) =>
                      value!.isEmpty ? 'Enter your email' : null,
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: passwordController,
                  decoration: inputDecoration.copyWith(
                    labelStyle: TextStyle(color: Colors.blueGrey),
                    labelText: 'Password',
                    hintText: 'Enter your password',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  obscureText: true,
                  validator: (value) =>
                      value!.length < 6 ? 'Minimum 6 characters' : null,
                ),
                SizedBox(height: 30),
                _isLoading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: register,
                        style: ElevatedButton.styleFrom(
                          elevation: 4,
                          backgroundColor: Colors.blue.shade600,
                          minimumSize: Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          'Create Account',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => LoginScreen()),
                    );
                  },
                  child: Text(
                    'Already have an account? Login',
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
