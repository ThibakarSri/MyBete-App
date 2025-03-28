import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

class Symptom5Screen extends StatefulWidget {
  @override
  _FrequentUrinaryCheckerState createState() => _FrequentUrinaryCheckerState();
}

class _FrequentUrinaryCheckerState extends State<Symptom5Screen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> _records = [];
  Timer? _timer;
  int _remainingSeconds = 24 * 60 * 60; // 24 hours in seconds
  bool _isTimerRunning = false;
  String _urinaryResult = "";

  @override
  void initState() {
    super.initState();
    _loadTimerState();
  }

  // Fetch records in real-time using a Stream
  Stream<QuerySnapshot> _getUrinaryRecordsStream() {
    final user = _auth.currentUser;
    if (user != null) {
      return _firestore
          .collection('urinary_records')
          .where('userId', isEqualTo: user.uid)
          .orderBy('timestamp', descending: true)
          .snapshots();
    }
    return const Stream.empty();
  }

  Future<void> _addRecord() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final timestamp = DateTime.now();
        await _firestore.collection('urinary_records').add({
          'timestamp': timestamp.toIso8601String(),
          'userId': user.uid, // Add the user's UID to the record
        });

        // Immediately update the UI by adding the new record to the _records list
        setState(() {
          _records.insert(0, {
            'date': _formatDateTime(timestamp),
          });
        });
      }
    } catch (e) {
      print('Error adding record: $e');
    }
  }

  Future<void> _clearRecords() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        QuerySnapshot querySnapshot = await _firestore
            .collection('urinary_records')
            .where('userId', isEqualTo: user.uid)
            .get();
        for (var doc in querySnapshot.docs) {
          await _firestore.collection('urinary_records').doc(doc.id).delete();
        }

        // Clear the _records list and update the UI
        setState(() {
          _records.clear();
        });
      }
    } catch (e) {
      print('Error clearing records: $e');
    }
  }

  Future<void> _loadTimerState() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot timerDoc =
        await _firestore.collection('timer_state').doc(user.uid).get();

        if (timerDoc.exists) {
          final startTime = DateTime.parse(timerDoc['startTime']);
          final now = DateTime.now();
          final elapsedSeconds = now.difference(startTime).inSeconds;

          if (elapsedSeconds < 24 * 60 * 60) {
            setState(() {
              _remainingSeconds = (24 * 60 * 60) - elapsedSeconds;
              _isTimerRunning = true;
            });

            _startTimer(isResuming: true);
          } else {
            _evaluateUrinaryFrequency();
          }
        }
      }
    } catch (e) {
      print('Error loading timer state: $e');
    }
  }

  Future<void> _saveTimerState() async {
    final user = _auth.currentUser;
    if (user != null) {
      final startTime = DateTime.now().toIso8601String();
      try {
        await _firestore.collection('timer_state').doc(user.uid).set({
          'startTime': startTime,
          'userId': user.uid, // Add the user's UID to the timer state
        });
      } catch (e) {
        print('Error saving timer state: $e');
      }
    }
  }

  void _startTimer({bool isResuming = false}) {
    if (_isTimerRunning && !isResuming) return;

    if (!isResuming) {
      _saveTimerState();
    }

    setState(() {
      _isTimerRunning = true;
      _urinaryResult = "";
    });

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingSeconds <= 0) {
        timer.cancel();
        _evaluateUrinaryFrequency();
        setState(() {
          _isTimerRunning = false;
        });
      } else {
        setState(() {
          _remainingSeconds--;
        });
      }
    });
  }

  Future<void> _resetTimer() async {
    _timer?.cancel();
    setState(() {
      _remainingSeconds = 24 * 60 * 60; // Reset to 24 hours
      _isTimerRunning = false;
      _urinaryResult = "";
    });

    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('timer_state').doc(user.uid).delete();
      }
    } catch (e) {
      print('Error resetting timer state: $e');
    }
  }

  void _evaluateUrinaryFrequency() {
    final int count = _records.length;
    if (count > 7) {
      setState(() {
        _urinaryResult = "Frequent Urination Detected: $count times in 24 hours";
      });
    } else {
      setState(() {
        _urinaryResult = "Normal Urination Frequency: $count times in 24 hours";
      });
    }
  }

  void _generateReport() {
    _evaluateUrinaryFrequency();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Color(0xFFF1FAEE), // Light background
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Row(
            children: [
              Icon(
                _urinaryResult.contains("Frequent")
                    ? Icons.close // Red cross for frequent urination
                    : Icons.check, // Green check for normal frequency
                color: _urinaryResult.contains("Frequent")
                    ? Color(0xFFE28869) // Red color
                    : Color(0xFF288994), // Green color
              ),
              SizedBox(width: 10),
              Text(
                'Urination Report',
                style: TextStyle(
                  color: Color(0xFF06333B), // Dark text
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            _urinaryResult.isNotEmpty
                ? _urinaryResult
                : "No data available to generate a report.",
            style: TextStyle(
              color: Color(0xFF245D6B), // Dark text
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'OK',
                style: TextStyle(
                  color: Color(0xFF288994), // Primary color
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatTime(int seconds) {
    final int hours = seconds ~/ 3600;
    final int minutes = (seconds % 3600) ~/ 60;
    final int secs = seconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}:${dateTime.second}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Frequent Urinary Checker',
          style: TextStyle(
            color: Color(0xFFF1FAEE), // Light text
            fontWeight: FontWeight.bold,
          ),
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
              Color(0xFFB3E5FC), // Lighter blue
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildActionButton(
                'Log Urination',
                _addRecord,
                Icons.wc,
                Color(0xFF35B4C9), // Light blue
              ),
              SizedBox(height: 10),
              _buildActionButton(
                'Clear Data',
                _clearRecords,
                Icons.delete,
                Color(0xFFE28869), // Red
              ),
              SizedBox(height: 10),
              _buildActionButton(
                'Generate Report',
                _generateReport,
                Icons.assignment,
                Color(0xFF96D8E3), // Light blue
              ),
              SizedBox(height: 20),
              Text(
                'Timer: ${_formatTime(_remainingSeconds)}',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF06333B), // Dark text
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildActionButton(
                    'Start Timer',
                        () => _startTimer(),
                    Icons.play_arrow,
                    Color(0xFF288994), // Primary color
                  ),
                  SizedBox(width: 10),
                  _buildActionButton(
                    'Reset Timer',
                    _resetTimer,
                    Icons.refresh,
                    Color(0xFF245D6B), // Dark blue
                  ),
                ],
              ),
              SizedBox(height: 20),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _getUrinaryRecordsStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text('Error: ${snapshot.error}'),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Text(
                          'No records yet. Log your first urination event!',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF06333B), // Dark text
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        final doc = snapshot.data!.docs[index];
                        final timestamp = DateTime.parse(doc['timestamp']);
                        return Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          margin: EdgeInsets.symmetric(vertical: 5),
                          child: ListTile(
                            leading: Icon(
                              Icons.wc,
                              color: Color(0xFF288994), // Primary color
                            ),
                            title: Text(
                              'Date: ${_formatDateTime(timestamp)}',
                              style: TextStyle(
                                color: Color(0xFF06333B), // Dark text
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
      String text, VoidCallback onPressed, IconData icon, Color color) {
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
          Icon(icon, color: Color(0xFFF1FAEE)), // Light text
          SizedBox(width: 10),
          Text(
            text,
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFFF1FAEE), // Light text
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}