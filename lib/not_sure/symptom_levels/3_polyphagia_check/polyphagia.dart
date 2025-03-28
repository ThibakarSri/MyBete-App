import 'package:flutter/material.dart';

class Symptom3Screen extends StatefulWidget {
  @override
  _ExtremeHungerCheckerState createState() => _ExtremeHungerCheckerState();
}

class _ExtremeHungerCheckerState extends State<Symptom3Screen> {
  int _totalCalories = 0;
  List<Map<String, dynamic>> _hungerLogs = [];

  final List<Map<String, dynamic>> _foodItems = [
    {'name': 'Carbohydrates', 'calories': 300, 'image': 'lib/not_sure/symptom_levels/3_polyphagia_check/Images/Carbohydrate.jpeg'},
    {'name': 'Proteins', 'calories': 200, 'image': 'lib/not_sure/symptom_levels/3_polyphagia_check/Images/Protein.jpg'},
    {'name': 'Fats', 'calories': 200, 'image': 'lib/not_sure/symptom_levels/3_polyphagia_check/Images/Lipides.jpg'},
    {'name': 'Dairy & Alternatives', 'calories': 100, 'image': 'lib/not_sure/symptom_levels/3_polyphagia_check/Images/Dairy foods.png'},
    {'name': 'Fruits & Vegetables', 'calories': 100, 'image': 'lib/not_sure/symptom_levels/3_polyphagia_check/Images/Fruits.jpg'},
    {'name': 'Processed Foods & Beverages', 'calories': 200, 'image': 'lib/not_sure/symptom_levels/3_polyphagia_check/Images/Beverages & Processed Foods.jpg'},
  ];

  void _addCalories(int calories) {
    setState(() {
      _totalCalories += calories;
    });
  }

  void _checkExtremeHunger() {
    if (_totalCalories > 2000) { // Extreme hunger threshold
      setState(() {
        _hungerLogs.add({
          'date': DateTime.now().toString(),
          'status': 'Extreme Eating Detected'
        });
      });
      _showDialog("Extreme Eating Detected!", "This total calorie intake qualifies as extreme eating.");
    } else {
      setState(() {
        _hungerLogs.add({
          'date': DateTime.now().toString(),
          'status': 'Normal Eating'
        });
      });
      _showDialog("Normal Eating", "This total calorie intake is within a normal range.");
    }
    // Reset total calories
    setState(() {
      _totalCalories = 0;
    });
  }

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Extreme Hunger Checker"),
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: _foodItems.length,
              itemBuilder: (context, index) {
                final food = _foodItems[index];
                return GestureDetector(
                  onTap: () => _addCalories(food['calories']),
                  child: Card(
                    child: Column(
                      children: [
                        Expanded(
                          child: Image.asset(
                            food['image'],
                            fit: BoxFit.cover,
                          ),
                        ),
                        Text(
                          food['name'],
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text("${food['calories']} cal"),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  "Total Calories: $_totalCalories",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _checkExtremeHunger,
                  child: Text("Check Hunger"),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _hungerLogs.length,
              itemBuilder: (context, index) {
                final log = _hungerLogs[index];
                return ListTile(
                  title: Text(log['status'] ?? ''),
                  subtitle: Text(log['date'] ?? ''),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
