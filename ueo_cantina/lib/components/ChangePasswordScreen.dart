import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({Key? key}) : super(key: key);

  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmNewPasswordController = TextEditingController(); // New TextEditingController for confirm password

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Change Password'),
      ),
      body: _isLoading ? _buildLoadingIndicator() : _buildChangePasswordForm(),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildChangePasswordForm() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Current Password'),
              obscureText: true,
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter your current password';
                }
                return null;
              },
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _newPasswordController,
              decoration: InputDecoration(labelText: 'New Password'),
              obscureText: true,
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter a new password';
                }
                return null;
              },
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _confirmNewPasswordController,
              decoration: InputDecoration(labelText: 'Confirm New Password'),
              obscureText: true,
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please confirm your new password';
                } else if (value != _newPasswordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _changePassword(_passwordController.text, _newPasswordController.text);
                }
              },
              child: Text('Change Password'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _changePassword(String currentPassword, String newPassword) async {
    setState(() {
      _isLoading = true;
    });

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Reauthenticate user with current password before changing password
        AuthCredential credential = EmailAuthProvider.credential(email: user.email!, password: currentPassword);
        await user.reauthenticateWithCredential(credential);

        // Change user's password
        await user.updatePassword(newPassword);

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Password changed successfully'),
        ));
        Navigator.of(context).pop(); // Pop the change password screen
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to change password: $error'),
      ));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose(); // Dispose the confirm password controller
    super.dispose();
  }
}