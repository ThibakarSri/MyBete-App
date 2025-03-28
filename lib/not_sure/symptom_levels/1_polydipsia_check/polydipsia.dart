import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Symptom1Screen extends StatefulWidget {
  @override
  _Symptom1ScreenState createState() => _Symptom1ScreenState();
}

class _Symptom1ScreenState extends State<Symptom1Screen> {
  int smallGlasses = 0;
  int mediumGlasses = 0;
  int largeGlasses = 0;
  int smallBottles = 0;
  int mediumBottles = 0;
  int largeBottles = 0;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  double getTotalWaterIntake() {
    double total = (smallGlasses * 200 +
        mediumGlasses * 250 +
        largeGlasses * 300 +
        smallBottles * 500 +
        mediumBottles * 750 +
        largeBottles * 1000) /
        1000;
    return total;
  }

  Future<void> _saveData() async {
    double totalIntake = getTotalWaterIntake();
    try {
      String today = DateTime.now().toIso8601String().split('T')[0];
      String userId = _auth.currentUser!.uid; // Get the current user's ID

      QuerySnapshot snapshot = await _firestore
          .collection('water_intake_records')
          .where('date', isEqualTo: today)
          .where('userId', isEqualTo: userId) // Filter by user ID
          .get();

      if (snapshot.docs.isNotEmpty) {
        DocumentSnapshot existingRecord = snapshot.docs.first;
        double existingIntake = existingRecord['intake'];
        double updatedIntake = existingIntake + totalIntake;

        await _firestore
            .collection('water_intake_records')
            .doc(existingRecord.id)
            .update({
          'intake': updatedIntake,
          'status': updatedIntake > 5
              ? 'Extreme'
              : (updatedIntake >= 2 && updatedIntake <= 3 ? 'Healthy' : 'Normal'),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Water intake updated for today!')),
        );
      } else {
        await _firestore.collection('water_intake_records').add({
          'date': today,
          'intake': totalIntake,
          'status': totalIntake > 5
              ? 'Extreme'
              : (totalIntake >= 2 && totalIntake <= 3 ? 'Healthy' : 'Normal'),
          'userId': userId, // Include the user ID
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Data saved successfully!')),
        );
      }
    } catch (e) {
      print('Error saving data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save data. Please try again.')),
      );
    }
  }

  Future<void> _clearRecords() async {
    String userId = _auth.currentUser!.uid; // Get the current user's ID

    try {
      QuerySnapshot snapshot = await _firestore
          .collection('water_intake_records')
          .where('userId', isEqualTo: userId) // Filter by user ID
          .get();
      for (var doc in snapshot.docs) {
        await _firestore.collection('water_intake_records').doc(doc.id).delete();
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('All records cleared!')),
      );
    } catch (e) {
      print('Error clearing records: $e');
    }
  }

  void _viewData() async {
    String userId = _auth.currentUser!.uid; // Get the current user's ID

    QuerySnapshot snapshot = await _firestore
        .collection('water_intake_records')
        .where('userId', isEqualTo: userId) // Filter by user ID
        .orderBy('date', descending: true)
        .get();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Color(0xFFEEF5FA), // Light background
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(
            'Saved Data',
            style: TextStyle(
              color: Color(0xFF06333B), // Dark text
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: snapshot.docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                String status = data['status'];
                IconData icon = status == 'Extreme' ? Icons.warning : Icons.check;
                Color iconColor = status == 'Extreme' ? Color(0xFFE28869) : Color(0xFF288994);

                return Card(
                  elevation: 2,
                  margin: EdgeInsets.symmetric(vertical: 5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  color: Color(0xFF96D8E3),
                  child: ListTile(
                    leading: Icon(icon, color: iconColor),
                    title: Text(
                      'Date: ${data['date']}',
                      style: TextStyle(
                        color: Color(0xFF06333B),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      'Intake: ${data['intake']} L\nStatus: $status',
                      style: TextStyle(
                        color: Color(0xFF245D6B),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Close',
                style: TextStyle(
                  color: Color(0xFF288994),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _calculateRisk() async {
    String userId = _auth.currentUser!.uid; // Get the current user's ID

    QuerySnapshot snapshot = await _firestore
        .collection('water_intake_records')
        .where('userId', isEqualTo: userId) // Filter by user ID
        .orderBy('date', descending: true)
        .get();

    int extremeCount = 0;
    int healthyCount = 0;

    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      String status = data['status'];
      if (status == 'Extreme') {
        extremeCount++;
      } else if (status == 'Healthy') {
        healthyCount++;
      }
    }

    String result =
    extremeCount > healthyCount ? 'Risk of Diabetes' : 'You are Healthy!';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Color(0xffeef6fa), // Light background
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(
            'Calculation Result',
            style: TextStyle(
              color: Color(0xFF06333B), // Dark text
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Extreme Intake Days: $extremeCount\nHealthy Intake Days: $healthyCount',
                style: TextStyle(
                  color: Color(0xFF245D6B),
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Result: $result',
                style: TextStyle(
                  color: extremeCount > healthyCount ? Color(0xFFE28869) : Color(0xFF288994),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Close',
                style: TextStyle(
                  color: Color(0xFF288994),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Feeling Extra Thirsty (Polydipsia)',
          style: TextStyle(
            color: Color(0xFFEEFAFA), // Light text
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xFF288994), // Primary color
        elevation: 0,
      ),
      body: Container(
        color: Color(0xFFEEF9FA), // Light background
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                'Enter your water intake today:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF06333B), // Dark text
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                child: ListView(
                  children: [
                    buildWaterIntakeCard(
                      'Small Glass (200ml)',
                      smallGlasses,
                      Icons.local_drink,
                          (value) {
                        setState(() {
                          smallGlasses = value;
                        });
                      },
                    ),
                    buildWaterIntakeCard(
                      'Medium Glass (250ml)',
                      mediumGlasses,
                      Icons.local_drink,
                          (value) {
                        setState(() {
                          mediumGlasses = value;
                        });
                      },
                    ),
                    buildWaterIntakeCard(
                      'Large Glass (300ml)',
                      largeGlasses,
                      Icons.local_drink,
                          (value) {
                        setState(() {
                          largeGlasses = value;
                        });
                      },
                    ),
                    buildWaterIntakeCard(
                      'Small Bottle (500ml)',
                      smallBottles,
                      Icons.local_drink, // Bottle icon
                          (value) {
                        setState(() {
                          smallBottles = value;
                        });
                      },
                    ),
                    buildWaterIntakeCard(
                      'Medium Bottle (750ml)',
                      mediumBottles,
                      Icons.local_drink, // Bottle icon
                          (value) {
                        setState(() {
                          mediumBottles = value;
                        });
                      },
                    ),
                    buildWaterIntakeCard(
                      'Large Bottle (1L)',
                      largeBottles,
                      Icons.local_drink, // Bottle icon
                          (value) {
                        setState(() {
                          largeBottles = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Total Intake: ${getTotalWaterIntake().toStringAsFixed(2)} L',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF06333B), // Dark text
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton('Save Data', _saveData, Color(0xFF288994)),
                  _buildActionButton('View Data', _viewData, Color(0xFF288994)),
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton('Calculate Risk', _calculateRisk, Color(0xFF288994)),
                  _buildActionButton('Clear Records', _clearRecords, Color(0xFFE28869)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildWaterIntakeCard(
      String label, int count, IconData icon, ValueChanged<int> onChanged) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      margin: EdgeInsets.symmetric(vertical: 8),
      color: Color(0xFFF1F5F6),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: Color(0xFF288994)), // Primary color
                SizedBox(width: 10),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF06333B), // Dark text
                  ),
                ),
              ],
            ),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.remove, color: Color(0xFF288994)),
                  onPressed: count > 0
                      ? () {
                    onChanged(count - 1);
                  }
                      : null,
                ),
                Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF06333B), // Dark text
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add, color: Color(0xFF288994)),
                  onPressed: () {
                    onChanged(count + 1);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String text, VoidCallback onPressed, Color color) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          color: Color(0xFFF1FAEE), // Light text
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}