import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class RecommendScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Recommend myBete",
          style: TextStyle(color: Colors.black, fontSize: 20),
        ),
        backgroundColor: Color(0xFF89D0ED),
        elevation: 0,
      ),
      body: Container(
        color: Color(0xFFF0F9FD),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.share,
                size: 80,
                color: Color(0xFF89D0ED),
              ),
              SizedBox(height: 20),
              Text(
                "Share myBete with your friends",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  "Help others manage their diabetes by recommending the myBete app",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  _shareApp(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF89D0ED),
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                child: Text("Share Now"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _shareApp(BuildContext context) async {
    await Share.share(
      "I'm using the myBete App to manage diabetes. Try it out! Download here: https://mybete.com/app",
    );
  }
}