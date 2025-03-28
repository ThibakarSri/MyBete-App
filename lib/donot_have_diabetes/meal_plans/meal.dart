import 'package:flutter/material.dart';
import 'meal_category.dart'; // Make sure to create this page


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'SF Pro Display',
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      ),
      home: const MealPlannerScreen(),
    );
  }
}

class MealPlannerScreen extends StatelessWidget {
  const MealPlannerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Status Bar and Back Button
            Padding(
              padding: const EdgeInsets.only(top: 8.0, left: 16.0, right: 16.0),
              child: Row(
                children: [],
              ),
            ),

            // Main Content
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),

                      // Meal Planner Title
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [
                            Color(0xFF00FAFF),
                            Color(0xFF00CCFF),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(bounds),
                        child: const Text(
                          'Meal Planner',
                          style: TextStyle(
                            fontSize: 35,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),


                      // Calories Display
                      Row(
                        children: [
                          // Calorie Pill
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF00FFB2),
                                  Color(0xFF0099FF),
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: const Text(
                              '1200kcal',
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),

                          const SizedBox(width: 24),

                          // Food and Calorie Icon - CHANGED TO ASSET
                          Image.asset(
                            'lib/donot_have_diabetes/meal_plans/meal_images/calories (1).png', // Update with your actual icon path
                            width: 100,
                            height: 100,
                            errorBuilder: (context, error, stackTrace) {
                              print('Error loading food icon: $error'); // Added for debugging
                              return Container(
                                width: 100,
                                height: 100,
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.fastfood, size: 40),
                              );
                            },
                          ),
                        ],
                      ),

                      // Add the Water Tracker Widget Here
                      const WaterTracker(),  // Add this line to display the water tracker widget

                      const SizedBox(height: 40),



                      // Select Your Meal Section
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [
                            Color(0xFF0066FF),
                            Color(0xFF00CCFF),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(bounds),
                        child: const Text(
                          'Select Your Meal',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),


                      // Horizontal Meal Cards
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            // Breakfast Card
                            _mealCard(
                              context,
                              imageUrl: 'lib/donot_have_diabetes/meal_plans/meal_images/breakfast.jpg',
                              label: 'Breakfast',
                            ),
                            const SizedBox(width: 16),
                            // Lunch Card
                            _mealCard(
                              context,
                              imageUrl: 'lib/donot_have_diabetes/meal_plans/meal_images/lunch.jpg',
                              label: 'Lunch',
                            ),
                            const SizedBox(width: 16),
                            // Dinner Card
                            _mealCard(
                              context,
                              imageUrl: 'lib/donot_have_diabetes/meal_plans/meal_images/dinner.jpg',
                              label: 'Dinner',
                            ),
                            const SizedBox(width: 16),
                            // Snack Card
                            _mealCard(
                              context,
                              imageUrl: 'lib/donot_have_diabetes/meal_plans/meal_images/snack.jpg',
                              label: 'Snack',
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
            // Bottom Navigation Bar
            Container(
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  NavBarItem(
                    icon: Icons.menu_book,
                    color: Colors.blue,
                    isSelected: true,
                  ),
                  NavBarItem(
                    icon: Icons.favorite,
                    color: Colors.black,
                    isSelected: false,
                  ),
                  NavBarItem(
                    icon: Icons.fitness_center,
                    color: Colors.black,
                    isSelected: false,
                  ),
                  NavBarItem(
                    icon: Icons.person,
                    color: Colors.black,
                    isSelected: false,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }



  // Helper function to generate meal cards with label overlaid on image
  Widget _mealCard(BuildContext context, {required String imageUrl, required String label}) {
    return GestureDetector(
      onTap: () {
        // Navigate to the MealCategoryPage
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => FoodCategoryScreen(mealType: label)),
        );
      },
      child: Container(
        height: 180,
        width: 280,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Meal Image
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.asset(
                imageUrl,
                width: 280,
                height: 180,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  print('Error loading image: $imageUrl - $error');
                  return Container(
                    width: 280,
                    height: 180,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.image, size: 100),
                  );
                },
              ),
            ),
            // Semi-transparent overlay for better text visibility
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.1),
                    Colors.black.withOpacity(0.5),
                  ],
                ),
              ),
            ),
            // Meal Label
            Positioned(
              bottom: 16,
              left: 16,
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      offset: Offset(1, 1),
                      blurRadius: 3,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}




class NutritionProgressIndicator extends StatelessWidget {
  final double value;
  final String label;
  final Color color;

  const NutritionProgressIndicator({
    Key? key,
    required this.value,
    required this.label,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // Background Circle
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
            // Progress Circle
            SizedBox(
              width: 64,
              height: 64,
              child: CircularProgressIndicator(
                value: value,
                strokeWidth: 6,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            // Percentage Text
            Text(
              '${(value * 100).toInt()}%',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Label
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,

          ),
        ),
      ],
    );
  }
}

class WaterTracker extends StatefulWidget {
  const WaterTracker({Key? key}) : super(key: key);

  @override
  _WaterTrackerState createState() => _WaterTrackerState();
}

class _WaterTrackerState extends State<WaterTracker> {
  double _waterIntake = 0.0;
  final double _goal = 2000.0; // Target goal for daily water intake in ml

  void _incrementWater() {
    setState(() {
      if (_waterIntake < _goal) {
        _waterIntake += 200.0; // Increase by 200 ml
      }
    });
  }

  void _decrementWater() {
    setState(() {
      if (_waterIntake > 0) {
        _waterIntake -= 200.0; // Decrease by 200 ml
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Water Tracker',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(offset: Offset(1.5, 1.5), blurRadius: 3, color: Colors.black38),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Progress Bar for water intake with gradient and shadow effect
          Container(
            width: double.infinity,
            height: 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.grey.shade300,
            ),
            child: LinearProgressIndicator(
              value: _waterIntake / _goal,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 12),
          // Display current water intake with better font styling
          Text(
            '$_waterIntake ml / $_goal ml',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              shadows: [
                Shadow(offset: Offset(1.5, 1.5), blurRadius: 3, color: Colors.black38),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Add Button with gradient
              Container(
                width: 150,
                child: ElevatedButton(
                  onPressed: _incrementWater,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: Colors.transparent, // Make button background transparent
                  ).copyWith(
                    backgroundColor: MaterialStateProperty.all(Colors.transparent),
                  ),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue, Colors.lightBlueAccent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 50),
                      alignment: Alignment.center,
                      child: const Text(
                        'Add 200 ml',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              // Remove Button with gradient
              Container(
                width: 150,
                child: ElevatedButton(
                  onPressed: _decrementWater,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: Colors.transparent, // Make button background transparent
                  ).copyWith(
                    backgroundColor: MaterialStateProperty.all(Colors.transparent),
                  ),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.red, Colors.orange],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 50),
                      alignment: Alignment.center,
                      child: const Text(
                        'Remove 200 ml',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


class NavBarItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final bool isSelected;

  const NavBarItem({
    Key? key,
    required this.icon,
    required this.color,
    required this.isSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Icon(
        icon,
        size: 28,
        color: color,
      ),
    );
  }
}