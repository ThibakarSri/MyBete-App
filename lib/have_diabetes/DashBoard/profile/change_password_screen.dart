import 'package:flutter/material.dart';

class ChangePasswordScreen extends StatefulWidget {
  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  bool _oldPasswordVisible = false;
  bool _newPasswordVisible = false;
  bool _confirmPasswordVisible = false;

  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            color: Color(0xFF89D0ED),
            padding: EdgeInsets.only(top: 40, bottom: 15, left: 10, right: 20),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
                Text(
                  "Change Password",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: Container(
              color: Colors.white,
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Old password field
                  _buildPasswordField(
                    label: "Old password",
                    controller: _oldPasswordController,
                    isVisible: _oldPasswordVisible,
                    onVisibilityChanged: (value) {
                      setState(() => _oldPasswordVisible = value);
                    },
                  ),

                  SizedBox(height: 20),

                  // New password field
                  _buildPasswordField(
                    label: "New password",
                    controller: _newPasswordController,
                    isVisible: _newPasswordVisible,
                    onVisibilityChanged: (value) {
                      setState(() => _newPasswordVisible = value);
                    },
                    helperText: "please use at least 8 characters for your password.",
                  ),

                  SizedBox(height: 20),

                  // Confirm password field
                  _buildPasswordField(
                    label: "Confirm password",
                    controller: _confirmPasswordController,
                    isVisible: _confirmPasswordVisible,
                    onVisibilityChanged: (value) {
                      setState(() => _confirmPasswordVisible = value);
                    },
                    helperText: "please use at least 8 characters for your password.",
                  ),

                  SizedBox(height: 40),

                  // Save button
                  ElevatedButton(
                    onPressed: _changePassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF89D0ED),
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    child: Text(
                      "Save",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool isVisible,
    required Function(bool) onVisibilityChanged,
    String? helperText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  obscureText: !isVisible,
                  decoration: InputDecoration(
                    labelText: label,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 10),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  isVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.grey,
                ),
                onPressed: () => onVisibilityChanged(!isVisible),
              ),
            ],
          ),
        ),
        if (helperText != null)
          Padding(
            padding: EdgeInsets.only(top: 5, left: 5),
            child: Text(
              helperText,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ),
      ],
    );
  }

  void _changePassword() {
    // Validate passwords
    if (_newPasswordController.text.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Password must be at least 8 characters")),
      );
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Passwords don't match")),
      );
      return;
    }

    // Show success dialog
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Password Changed!"),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Go back to previous screen
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}