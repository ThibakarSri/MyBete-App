import 'package:flutter/material.dart';
import 'package:mybete_app/not_sure/navigation.dart';
import 'symptom_levels/6_blurry_vision_check/blurry_vision.dart';
import 'symptom_levels/5_frequent_urinary_check/frequent_urinary.dart';
import 'symptom_levels/7_feel_tired_check/more_tired.dart';
import 'symptom_levels/2_nerones_damage_check/neurons_damage.dart';
import 'symptom_levels/9_numbness_check/numbness.dart';
import 'symptom_levels/10_period_check/period_changes.dart';
import 'symptom_levels/1_polydipsia_check/polydipsia.dart';
import 'symptom_levels/3_polyphagia_check/polyphagia.dart';
import 'symptom_levels/8_skin_changes_check/skin_changes.dart';
import 'symptom_levels/4_weight_changes_check/weight_changes.dart';

class NotSureDashboard extends StatelessWidget {
  final List<String> symptoms = [
    'Feeling Extra Thirsty (Polydipsia)',
    'Neurons damage and stroke',
    'Extreme Hunger (Polyphagia)',
    'Weight changes',
    'Frequent urinary tract infections or yeast infections (Polyuria)',
    'Blurry vision',
    'Feeling more tired than usual',
    'Skin changes',
    'Numbness or tingling in the feet',
    'Changes to your periods',
  ];

  final List<IconData> icons = [
    Icons.local_drink,
    Icons.health_and_safety,
    Icons.fastfood,
    Icons.monitor_weight,
    Icons.wc,
    Icons.remove_red_eye,
    Icons.bedtime,
    Icons.spa,
    Icons.accessible,
    Icons.calendar_today,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white, // Solid background color
        child: Column(
          children: [
            AppBar(
              title: const Text(
                "Symptoms Levels",
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 24,
                ),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black87),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: symptoms.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LevelDetailScreen(
                            level: index + 1,
                            symptom: symptoms[index],
                          ),
                        ),
                      );
                    },
                    child: Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50, // Solid color for the card
                          borderRadius: BorderRadius.circular(15),
                        ),
                        padding: EdgeInsets.all(16),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.blue.withOpacity(0.2),
                              child: Icon(
                                icons[index],
                                color: Color(0xFF288994),
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                symptoms[index],
                                style: TextStyle(
                                  color: Color(0xFF288994),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: Color(0xFF288994),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBarWidget(currentIndex: 1),
    );
  }
}

class LevelDetailScreen extends StatelessWidget {
  final int level;
  final String symptom;

  LevelDetailScreen({required this.level, required this.symptom});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Level $level',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xFF288994),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        color: Colors.white, // Solid background color
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Level $level: $symptom',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF288994),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF288994),
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        switch (level) {
                          case 1:
                            return Symptom1Screen();
                          case 2:
                            return Symptom2Screen();
                          case 3:
                            return Symptom3Screen();
                          case 4:
                            return Symptom4Screen();
                          case 5:
                            return Symptom5Screen();
                          case 6:
                            return Symptom6Screen();
                          case 7:
                            return Symptom7Screen();
                          case 8:
                            return Symptom8Screen();
                          case 9:
                            return Symptom9Screen();
                          case 10:
                            return Symptom10Screen();
                          default:
                            return Symptom1Screen();
                        }
                      },
                    ),
                  );
                },
                child: Text(
                  "Check Symptom",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}