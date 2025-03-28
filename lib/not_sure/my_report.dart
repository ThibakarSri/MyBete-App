import 'package:flutter/material.dart';
import 'navigation.dart';

class MyReportScreen extends StatefulWidget {
  @override
  _MyReportScreenState createState() => _MyReportScreenState();
}

class _MyReportScreenState extends State<MyReportScreen> {
  // Storing the results of the 10 symptoms. True = Symptom present, False = Symptom not present.
  final Map<String, bool> _symptomResults = {
    'Feeling Extra Thirsty (Polydipsia)': false,
    'Neurons damage and stroke': false,
    'Extreme Hunger (Polyphagia)': false,
    'Weight changes': false,
    'Frequent urinary tract infections or yeast infections (Polyuria)': false,
    'Blurry vision': false,
    'Feeling more tired than usual': false,
    'Skin changes': false,
    'Numbness or tingling in the feet': false,
    'Changes to your periods': false,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Report'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          const Text(
            'Your Diabetes Report',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          const Text(
            'Select the symptoms you are experiencing:',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              children: _symptomResults.keys.map((symptom) {
                return CheckboxListTile(
                  title: Text(symptom),
                  value: _symptomResults[symptom],
                  onChanged: (value) {
                    setState(() {
                      _symptomResults[symptom] = value!;
                    });
                  },
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              _generateReport(context);
            },
            child: const Text('Generate Report'),
          ),
          const SizedBox(height: 20),
        ],
      ),
      bottomNavigationBar: NavigationBarWidget(currentIndex: 2),
    );
  }

  void _generateReport(BuildContext context) {
    // Calculate the number of symptoms marked as true
    int positiveSymptoms = _symptomResults.values.where((result) => result == true).length;

    // Calculate the percentage
    double percentage = (positiveSymptoms / _symptomResults.length) * 100;

    // Show the report in a dialog box
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Diabetes Report'),
          content: Text(
            'You have reported experiencing $positiveSymptoms out of ${_symptomResults.length} symptoms.\n\n'
                'Based on this, your estimated diabetes likelihood is ${percentage.toStringAsFixed(2)}%.',
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
