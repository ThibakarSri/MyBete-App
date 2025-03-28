import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'total_screen.dart'; // Add this line

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
        scaffoldBackgroundColor: const Color(0xFFF0E6FF), // Light purple background
      ),
      home: const BeveragesScreen(),
    );
  }
}

class BeveragesScreen extends StatelessWidget {
  const BeveragesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      // Handle back button press
                    },
                    child: const Icon(
                      Icons.arrow_back,
                      size: 28,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Beverages',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),

            // Search Icon
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Icon(
                  Icons.search,
                  size: 28,
                  color: Colors.black.withOpacity(0.6),
                ),
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Low-Calorie Section
                      const Text(
                        'Low-Calorie Beverages (Below 10 kcal per 100ml)',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Low-Calorie Beverages Grid
                      Row(
                        children: [
                          _buildBeverageCard(
                            'Water',
                            '0 kcal',
                            'assets/images/water.png',
                                () => _showBeverageDetails(context, 'Water'),
                          ),
                          const SizedBox(width: 12),
                          _buildBeverageCard(
                            'Black Coffee (Unsweetened)',
                            '2 kcal',
                            'assets/images/black_coffee.png',
                                () => _showBeverageDetails(context, 'Black Coffee'),
                          ),
                          const SizedBox(width: 12),
                          _buildBeverageCard(
                            'Black Tea (Unsweetened)',
                            '1 kcal',
                            'assets/images/black_tea.png',
                                () => _showBeverageDetails(context, 'Black Tea'),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Moderate-Calorie Section
                      const Text(
                        'Moderate-Calorie Beverages (10-50 kcal per 100ml)',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Moderate-Calorie Beverages Grid
                      Row(
                        children: [
                          _buildBeverageCard(
                            'Coconut Water (Unsweetened)',
                            '19 kcal',
                            'assets/images/coconut_water.png',
                                () => _showBeverageDetails(context, 'Coconut Water'),
                          ),
                          const SizedBox(width: 12),
                          _buildBeverageCard(
                            'Soy Milk (Unsweetened)',
                            '33 kcal',
                            'assets/images/soy_milk.png',
                                () => _showBeverageDetails(context, 'Soy Milk'),
                          ),
                          const SizedBox(width: 12),
                          _buildBeverageCard(
                            'Almond Milk (Unsweetened)',
                            '15 kcal',
                            'assets/images/almond_milk.png',
                                () => _showBeverageDetails(context, 'Almond Milk'),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // High-Calorie Section
                      const Text(
                        'High-Calorie Beverages (Above 50 kcal per 100ml)',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // High-Calorie Beverages Grid
                      Row(
                        children: [
                          _buildBeverageCard(
                            'Papaya Fruit Juice (Sweetened)',
                            '70 kcal',
                            'assets/images/papaya_juice.png',
                                () => _showBeverageDetails(context, 'Papaya Juice'),
                          ),
                          const SizedBox(width: 12),
                          _buildBeverageCard(
                            'Chocolate Milk',
                            '85 kcal',
                            'assets/images/chocolate_milk.png',
                                () => _showBeverageDetails(context, 'Chocolate Milk'),
                          ),
                          const SizedBox(width: 12),
                          _buildBeverageCard(
                            'Strawberry Milkshake',
                            '150 kcal',
                            'assets/images/strawberry_milkshake.png',
                                () => _showBeverageDetails(context, 'Strawberry Milkshake'),
                          ),
                        ],
                      ),
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
                  _buildNavBarItem(Icons.book, true),
                  _buildNavBarItem(Icons.favorite, false),
                  _buildNavBarItem(Icons.fitness_center, false),
                  _buildNavBarItem(Icons.person, false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build beverage cards
  Widget _buildBeverageCard(String name, String calories, String imagePath, VoidCallback onTap) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Placeholder for beverage image
            Container(
              height: 80,
              alignment: Alignment.center,
              child: _getBeverageImage(name),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  calories,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to get beverage image based on name
  Widget _getBeverageImage(String name) {
    // In a real app, you would use actual image assets
    // For this example, we'll use simple icons based on the beverage name
    IconData iconData;
    Color iconColor;

    if (name.contains('Water')) {
      iconData = Icons.water_drop;
      iconColor = Colors.blue;
    } else if (name.contains('Coffee')) {
      iconData = Icons.coffee;
      iconColor = Colors.brown;
    } else if (name.contains('Tea')) {
      iconData = Icons.emoji_food_beverage;
      iconColor = Colors.pink;
    } else if (name.contains('Coconut')) {
      iconData = Icons.beach_access;
      iconColor = Colors.green;
    } else if (name.contains('Milk')) {
      iconData = Icons.opacity;
      iconColor = Colors.amber;
    } else if (name.contains('Juice')) {
      iconData = Icons.local_drink;
      iconColor = Colors.orange;
    } else if (name.contains('Milkshake')) {
      iconData = Icons.local_cafe;
      iconColor = Colors.red;
    } else {
      iconData = Icons.local_drink;
      iconColor = Colors.purple;
    }

    return Icon(
      iconData,
      size: 48,
      color: iconColor,
    );
  }

  // Helper method to build bottom navigation bar items
  Widget _buildNavBarItem(IconData icon, bool isSelected) {
    return Icon(
      icon,
      size: 28,
      color: isSelected ? Colors.blue : Colors.black54,
    );
  }

  // Helper method to show beverage details
  void _showBeverageDetails(BuildContext context, String beverageName) {
    // In a real app, this would navigate to a details page
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$beverageName details'),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}