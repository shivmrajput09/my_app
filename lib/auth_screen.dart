
import 'package:flutter/material.dart'; // UI widgets
import 'package:firebase_auth/firebase_auth.dart'; // Firebase login/signup

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key}); // Authentication screen

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>(); // Form validation key
  final _emailController = TextEditingController(); // Email input
  final _passwordController = TextEditingController(); // Password input

  bool _isLogin = true; // true = Login, false = Signup
  bool _isLoading = false; // Button loading state
  String? _errorMessage; // Firebase error message

  final FirebaseAuth _auth = FirebaseAuth.instance; // Firebase Auth instance

  // Login ya Signup operation
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return; // Invalid form ko roko

    setState(() {
      _isLoading = true; // Loading start
      _errorMessage = null; // Purana error clear
    });

    try {
      final email = _emailController.text.trim(); // Extra spaces remove
      final password = _passwordController.text; // Password read

      if (_isLogin) {
        // Existing account se login
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        // Naya account create
        await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
      }

      // Success par navigation main.dart ka authStateChanges karega
    } on FirebaseAuthException catch (e) {
      // Firebase se aane wale errors handle karo
      if (e.code == 'email-already-in-use') {
        _errorMessage = 'Ye email pehle se registered hai.';
      } else if (e.code == 'invalid-email') {
        _errorMessage = 'Email address sahi nahi hai.';
      } else if (e.code == 'weak-password') {
        _errorMessage = 'Password kam se kam 6 characters ka rakho.';
      } else if (e.code == 'user-not-found' ||
          e.code == 'wrong-password' ||
          e.code == 'invalid-credential') {
        _errorMessage = 'Email ya password galat hai.';
      } else if (e.code == 'network-request-failed') {
        _errorMessage = 'Internet connection check karo.';
      } else {
        _errorMessage = e.message ?? 'Authentication failed.';
      }
    } catch (e) {
      _errorMessage = 'Kuch galat hua. Dobara try karo.';
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false; // Loading stop
        });
      }
    }

    if (mounted && _errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_errorMessage!)), // Error display
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose(); // Email controller cleanup
    _passwordController.dispose(); // Password controller cleanup
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLogin ? 'Login' : 'Create Account'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey, // Form validation connect
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.lock_outline,
                  size: 72,
                  color: Colors.blue,
                ),
                const SizedBox(height: 24),

                // Email input
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Email enter karo';
                    }
                    if (!value.trim().contains('@')) {
                      return 'Valid email enter karo';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Password input
                TextFormField(
                  controller: _passwordController,
                  obscureText: true, // Password hide rakho
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.password),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password enter karo';
                    }
                    if (value.length < 6) {
                      return 'Password minimum 6 characters ka ho';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Login/Signup action
                ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  child: _isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : Text(_isLogin ? 'Login' : 'Sign Up'),
                ),

                // Switch between Login and Signup
                TextButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          setState(() {
                            _isLogin = !_isLogin;
                            _errorMessage = null;
                          });
                        },
                  child: Text(
                    _isLogin
                        ? 'New user? Create an account'
                        : 'Already registered? Login',
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