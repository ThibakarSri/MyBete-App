import 'package:flutter/material.dart';
import 'navigation.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("User Profile"),
      ),
      body: Center(
        child: const Text(
          "Profile Details",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      bottomNavigationBar: NavigationBarWidget(currentIndex: 3), // Navigation bar
    );
  }
}
