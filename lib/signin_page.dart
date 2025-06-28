import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_nav_page.dart'; // Add this import

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});
  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  bool _isSigningIn = false;
  User? _user;

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _signInWithGoogle() async {
    setState(() => _isSigningIn = true);
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        setState(() => _isSigningIn = false);
        return;
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final user = userCredential.user;

      // Add user to Firestore if not exists
      if (user != null) {
        final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
        final docSnapshot = await userDoc.get();
        if (!docSnapshot.exists) {
          await userDoc.set({
            'uid': user.uid,
            'displayName': user.displayName,
            'email': user.email,
            'photoURL': user.photoURL,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      }

      setState(() {
        _user = user;
        _isSigningIn = false;
      });

      if (_user != null && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomeNavPage(
              user: _user!,
              onSignOut: () async {
                await FirebaseAuth.instance.signOut();
                await GoogleSignIn().signOut();
                setState(() => _user = null);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const SignInPage()),
                );
              },
            ),
          ),
        );
      }
    } catch (e) {
      setState(() => _isSigningIn = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign in failed: $e')),
      );
    }
  }

  Future<void> _signInWithEmailPassword() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSigningIn = true);
    try {
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      setState(() {
        _user = userCredential.user;
        _isSigningIn = false;
      });

      if (_user != null && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomeNavPage(
              user: _user!,
              onSignOut: () async {
                await FirebaseAuth.instance.signOut();
                await GoogleSignIn().signOut();
                setState(() => _user = null);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const SignInPage()),
                );
              },
            ),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _isSigningIn = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Sign in failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign In')),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(labelText: 'Email'),
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) =>
                            v != null && v.contains('@') ? null : 'Enter a valid email',
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        decoration: const InputDecoration(labelText: 'Password'),
                        obscureText: true,
                        validator: (v) =>
                            v != null && v.length >= 6 ? null : 'Min 6 characters',
                      ),
                      const SizedBox(height: 24),
                      _isSigningIn
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                              onPressed: _signInWithEmailPassword,
                              child: const Text('Sign In'),
                            ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text('OR'),
                const SizedBox(height: 16),
                _isSigningIn
                    ? const SizedBox.shrink()
                    : ElevatedButton.icon(
                        icon: Image.asset('assets/google_logo.png', height: 24),
                        label: const Text('Sign in with Google'),
                        onPressed: _signInWithGoogle,
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
