import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting dates
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Symptom10Screen extends StatefulWidget {
  @override
  _Symptom10ScreenState createState() => _Symptom10ScreenState();
}

class _Symptom10ScreenState extends State<Symptom10Screen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Period Checker",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF288994), // Primary color
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE6F7FF), // Light blue
              Color(0xFFE6F7FF), // Lighter blue
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildActionButton(
                "Log Period",
                    () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PeriodLoggerScreen()),
                  );
                },
                Icons.calendar_today,
                Color(0xFF35B4C9), // Light blue
              ),
              SizedBox(height: 20),
              _buildActionButton(
                "View Report",
                    () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CycleReportScreen()),
                  );
                },
                Icons.assignment,
                Color(0xFF96D8E3), // Light blue
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(String text, VoidCallback onPressed, IconData icon, Color color) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white),
          SizedBox(width: 10),
          Text(
            text,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class PeriodLoggerScreen extends StatefulWidget {
  @override
  _PeriodLoggerScreenState createState() => _PeriodLoggerScreenState();
}

class _PeriodLoggerScreenState extends State<PeriodLoggerScreen> {
  DateTime? startDate;
  DateTime? endDate;
  int? cycleLength;
  String flowLevel = "Normal"; // Default flow level
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> selectDate(BuildContext context, bool isStart) async {
    DateTime initialDate = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != initialDate) {
      setState(() {
        if (isStart) {
          startDate = picked;
        } else {
          endDate = picked;
          if (startDate != null) {
            cycleLength = endDate!.difference(startDate!).inDays;
          }
        }
      });
    }
  }

  Future<void> savePeriodData() async {
    if (startDate == null || endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select both dates first.")),
      );
      return;
    }

    String userId = _auth.currentUser!.uid; // Get current user ID
    String startDateFormatted = DateFormat('dd/MM/yyyy').format(startDate!);
    String endDateFormatted = DateFormat('dd/MM/yyyy').format(endDate!);

    try {
      await _firestore.collection('period_logs').add({
        'userId': userId,
        'startDate': startDateFormatted,
        'endDate': endDateFormatted,
        'cycleLength': cycleLength,
        'flow': flowLevel,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Period data logged!")),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save data: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Log Period",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF288994), // Primary color
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE6F7FF), // Light blue
              Color(0xFFE6F7FF), // Lighter blue
            ],
          ),
        ),
        child: Center( // Wrap the Column in a Center widget
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // Center the Column vertically
              crossAxisAlignment: CrossAxisAlignment.center, // Center the Column horizontally
              children: [
                _buildDatePickerButton(
                  "Select Start Date",
                  startDate == null ? null : DateFormat('dd/MM/yyyy').format(startDate!),
                      () => selectDate(context, true),
                ),
                SizedBox(height: 16),
                _buildDatePickerButton(
                  "Select End Date",
                  endDate == null ? null : DateFormat('dd/MM/yyyy').format(endDate!),
                      () => selectDate(context, false),
                ),
                SizedBox(height: 16),
                Text(
                  cycleLength == null
                      ? "Cycle Length: Not Calculated"
                      : "Cycle Length: $cycleLength days",
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF06333B), // Dark text
                  ),
                ),
                SizedBox(height: 16),
                DropdownButton<String>(
                  value: flowLevel,
                  onChanged: (String? newValue) {
                    setState(() {
                      flowLevel = newValue!;
                    });
                  },
                  items: <String>['Normal', 'Light', 'Heavy']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: TextStyle(
                          color: Color(0xFF06333B), // Dark text
                        ),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: savePeriodData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF288994), // Primary color
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    "Save",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDatePickerButton(String label, String? date, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFFF1FAEE), // Light background
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Text(
        date == null ? label : date,
        style: TextStyle(
          fontSize: 16,
          color: Color(0xFF06333B), // Dark text
        ),
      ),
    );
  }
}

class CycleReportScreen extends StatefulWidget {
  @override
  _CycleReportScreenState createState() => _CycleReportScreenState();
}

class _CycleReportScreenState extends State<CycleReportScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> periodLogs = [];

  @override
  void initState() {
    super.initState();
    fetchPeriodLogs();
  }

  Future<void> fetchPeriodLogs() async {
    String userId = _auth.currentUser!.uid; // Get current user ID
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('period_logs')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .get();

      setState(() {
        periodLogs = snapshot.docs.map((doc) {
          return {
            'startDate': doc['startDate'],
            'endDate': doc['endDate'],
            'cycleLength': doc['cycleLength'],
            'flow': doc['flow'],
          };
        }).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to fetch logs: $e")),
      );
    }
  }

  Future<void> clearLogs() async {
    String userId = _auth.currentUser!.uid; // Get current user ID
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('period_logs')
          .where('userId', isEqualTo: userId)
          .get();

      for (var doc in snapshot.docs) {
        await _firestore.collection('period_logs').doc(doc.id).delete();
      }

      setState(() {
        periodLogs.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("All logs cleared!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to clear logs: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Cycle Report",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF288994), // Primary color
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE6F7FF), // Light blue
              Color(0xFFE6F7FF), // Lighter blue
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Logged Data:",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF06333B), // Dark text
                ),
              ),
              SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: periodLogs.length,
                  itemBuilder: (context, index) {
                    final log = periodLogs[index];
                    return Card(
                      elevation: 2,
                      margin: EdgeInsets.symmetric(vertical: 8.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Start Date: ${log['startDate']}",
                              style: TextStyle(
                                color: Color(0xFF06333B), // Dark text
                              ),
                            ),
                            Text(
                              "End Date: ${log['endDate']}",
                              style: TextStyle(
                                color: Color(0xFF06333B), // Dark text
                              ),
                            ),
                            Text(
                              "Cycle Length: ${log['cycleLength']} days",
                              style: TextStyle(
                                color: Color(0xFF06333B), // Dark text
                              ),
                            ),
                            Text(
                              "Flow Level: ${log['flow']}",
                              style: TextStyle(
                                color: Color(0xFF06333B), // Dark text
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Divider(color: Color(0xFF288994)), // Primary color
              SizedBox(height: 10),
              Text(
                "Suggestions:",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF06333B), // Dark text
                ),
              ),
              SizedBox(height: 10),
              Text(
                getHealthSuggestion(30, 5, "Normal"),
                style: TextStyle(
                  color: Color(0xFF245D6B), // Dark text
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: clearLogs,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFE28869), // Red
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    "Clear Logs",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Dummy suggestion function (can use real data instead)
  String getHealthSuggestion(int cycleLength, int periodDuration, String flowLevel) {
    if (cycleLength < 21 || cycleLength > 35) {
      return "Your cycle length is irregular. Consider monitoring further or consulting a doctor.";
    }
    if (periodDuration < 2 || periodDuration > 7) {
      return "Your period duration is outside the normal range. Please consult a healthcare professional.";
    }
    if (flowLevel == "Heavy") {
      return "Your flow level is heavy. Make sure to stay hydrated and consult a doctor if needed.";
    }
    return "Your cycles appear normal. Keep tracking for consistent insights.";
  }
}