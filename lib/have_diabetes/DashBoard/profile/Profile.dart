import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:mybete_app/have_diabetes/DashBoard/profile/account_settings_screen.dart';
import 'package:mybete_app/have_diabetes/DashBoard/profile/recommend_screen.dart';
import 'package:mybete_app/have_diabetes/DashBoard/profile/support_feedback_screen.dart';
import '../MyActivity/weekly_stats_screen.dart';
import 'about.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String email = "thenujaasuntharesan@gmail.com";
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header with Profile title
          Container(
            width: double.infinity,
            color: Color(0xFF89D0ED),
            padding: EdgeInsets.only(left: 20, right: 20, top: 70, bottom: 16),
            child: Text(
              "Profile",
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),

          // Profile avatar and email
          Expanded(
            child: Container(
              width: double.infinity,
              color: Colors.white,
              child: Column(
                children: [
                  SizedBox(height: 20),
                  // Profile image with border
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Color(0xFFD6EDF8),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.grey.shade300, width: 1),
                        image: _profileImage != null
                            ? DecorationImage(
                          image: FileImage(_profileImage!),
                          fit: BoxFit.cover,
                        )
                            : null,
                      ),
                      child: _profileImage == null
                          ? Icon(
                        Icons.person,
                        size: 50,
                        color: Color(0xFF89D0ED),
                      )
                          : null,
                    ),
                  ),
                  SizedBox(height: 15),
                  // Email with tap to edit
                  GestureDetector(
                    onTap: _showEmailDialog,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          email,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 5),
                        Icon(Icons.edit, size: 14, color: Colors.grey),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),

                  // Menu items
                  _buildMenuItem(
                    icon: Icons.settings_outlined,
                    title: "Account & Settings",
                    onTap: () =>
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AccountSettingsScreen()),
                        ),
                  ),

                  _buildMenuItem(
                    icon: Icons.bar_chart_outlined,
                    title: "Stats",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WeeklyStatsScreen(
                          logEntries: [], // You'll need to pass actual log entries here
                          primaryColor: Color(0xFF89D0ED),
                          accentColor: Color(0xFF4EACD9),
                          lightColor: Color(0xFFD6EDF8),
                          veryLightColor: Color(0xFFEAF6FC),
                          tealColor: Color(0xFF4EACD9),
                          textColor: Colors.black,
                        ),
                      ),
                    ),
                  ),

                  _buildMenuItem(
                    icon: Icons.favorite_outline,
                    title: "Recommend myBete",
                    onTap: () =>
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => RecommendScreen()),
                        ),
                  ),
                  _buildMenuItem(
                    icon: Icons.chat_bubble_outline,
                    title: "Support & Feedback",
                    onTap: () =>
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SupportFeedbackScreen()),
                        ),
                  ),
                  _buildMenuItem(
                    icon: Icons.menu_book_outlined,
                    title: "About",
                    onTap: () =>
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AboutScreen()),
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

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey, size: 22),
            SizedBox(width: 15),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            Spacer(),
            Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
          ],
        ),
      ),
    );
  }

  // Function to pick image from gallery
  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
      });
    }
  }

  // Function to show email edit dialog
  void _showEmailDialog() {
    TextEditingController controller = TextEditingController(text: email);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Change Email"),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: "Email",
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: Text(
                "Save",
                style: TextStyle(color: Color(0xFF89D0ED)),
              ),
              onPressed: () {
                if (controller.text.isNotEmpty && controller.text.contains('@')) {
                  setState(() {
                    email = controller.text;
                  });
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Please enter a valid email address")),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}