// lib/donot_have_diabetes/meal_plans/summary.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class SummaryScreen extends StatefulWidget {
  const SummaryScreen({Key? key}) : super(key: key);

  @override
  _SummaryScreenState createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  bool isLoading = true;
  DateTime selectedDate = DateTime.now();

  // Category data
  Map<String, CategoryData> categoriesData = {
    'vegetables': CategoryData(
      name: 'Vegetables',
      icon: Icons.eco,
      color: Colors.green,
      totalCalories: 0,
      items: [],
    ),
    'fruits': CategoryData(
      name: 'Fruits',
      icon: Icons.apple,
      color: Colors.red,
      totalCalories: 0,
      items: [],
    ),
    'dairy': CategoryData(
      name: 'Dairy',
      icon: Icons.egg,
      color: Colors.blue,
      totalCalories: 0,
      items: [],
    ),
    'bakery': CategoryData(
      name: 'Bakery',
      icon: Icons.bakery_dining,
      color: Colors.brown,
      totalCalories: 0,
      items: [],
    ),
    'animal_proteins': CategoryData(
      name: 'Animal Proteins',
      icon: Icons.set_meal,
      color: Colors.purple,
      totalCalories: 0,
      items: [],
    ),
    'beverages': CategoryData(
      name: 'Beverages',
      icon: Icons.local_drink,
      color: Colors.cyan,
      totalCalories: 0,
      items: [],
    ),
    'grains': CategoryData(
      name: 'Grains',
      icon: Icons.grain,
      color: Colors.amber,
      totalCalories: 0,
      items: [],
    ),
    'breakfast': CategoryData(
      name: 'Breakfast',
      icon: Icons.free_breakfast,
      color: Colors.orange,
      totalCalories: 0,
      items: [],
    ),
    'lunch': CategoryData(
      name: 'Lunch',
      icon: Icons.lunch_dining,
      color: Colors.teal,
      totalCalories: 0,
      items: [],
    ),
    'dinner': CategoryData(
      name: 'Dinner',
      icon: Icons.dinner_dining,
      color: Colors.indigo,
      totalCalories: 0,
      items: [],
    ),
    'snack': CategoryData(
      name: 'Snack',
      icon: Icons.cookie,
      color: Colors.pink,
      totalCalories: 0,
      items: [],
    ),
  };

  int grandTotalCalories = 0;
  int dailyCalorieGoal = 2000; // Default goal, can be customized

  @override
  void initState() {
    super.initState();
    fetchAllCategoriesData();
  }

  Future<void> fetchAllCategoriesData() async {
    setState(() {
      isLoading = true;
    });

    final userId = 'user123'; // Replace with actual user ID
    final userRef = FirebaseFirestore.instance.collection('users').doc(userId);

    try {
      // Reset all category data
      categoriesData.forEach((key, value) {
        value.totalCalories = 0;
        value.items = [];
      });

      // Format date for Firestore query
      final startOfDay = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      // Fetch data for each category
      for (final category in categoriesData.keys) {
        // For food categories, check the corresponding collection
        String collectionName;
        if (category == 'vegetables') {
          collectionName = 'vegetable_calories';
        } else if (category == 'fruits') {
          collectionName = 'fruit_calories';
        } else if (category == 'grains') {
          collectionName = 'grain_calories';
        } else {
          collectionName = '${category}_calories';
        }

        final querySnapshot = await userRef
            .collection(collectionName)
            .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
            .where('timestamp', isLessThan: Timestamp.fromDate(endOfDay))
            .get();

        for (final doc in querySnapshot.docs) {
          final data = doc.data();
          final name = data['name'] ?? 'Unknown';
          final calories = data['calories'] ?? 0;

          categoriesData[category]!.items.add({
            'id': doc.id,
            'name': name,
            'calories': calories,
          });

          // Fix: Explicitly convert num to int
          if (calories is num) {
            int caloriesInt = calories.toInt();
            categoriesData[category]!.totalCalories += caloriesInt;
          }
        }
      }

      // Calculate grand total
      int total = 0;
      categoriesData.forEach((key, value) {
        total += value.totalCalories;
      });

      setState(() {
        grandTotalCalories = total;
        isLoading = false;
      });

    } catch (e) {
      print("Error fetching summary data: $e");
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF00FF62),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      fetchAllCategoriesData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutrition Summary'),
        backgroundColor: const Color(0xFF0065F3),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _selectDate(context),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date and Total Calories Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE5FFED),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    DateFormat('EEEE, MMMM d, yyyy').format(selectedDate),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.local_fire_department,
                        color: Color(0xFF009439),
                        size: 32,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$grandTotalCalories',
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF009439),
                        ),
                      ),
                      const Text(
                        ' kcal',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF009439),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'of $dailyCalorieGoal kcal goal',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: grandTotalCalories / dailyCalorieGoal,
                      minHeight: 15,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        grandTotalCalories > dailyCalorieGoal
                            ? Colors.red
                            : const Color(0xFF00FF62),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Pie Chart
            if (grandTotalCalories > 0) ...[
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Calorie Distribution',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(
                height: 250,
                child: PieChart(
                  PieChartData(
                    sections: _createPieChartSections(),
                    centerSpaceRadius: 40,
                    sectionsSpace: 2,
                  ),
                ),
              ),
            ],

            // Category Breakdown
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Category Breakdown',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // List of categories
            ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: categoriesData.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final category = categoriesData.values.elementAt(index);
                final hasItems = category.totalCalories > 0;

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: hasItems
                        ? category.color
                        : Colors.grey[300],
                    child: Icon(
                      category.icon,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    category.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${category.totalCalories} kcal',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: hasItems
                              ? const Color(0xFF009439)
                              : Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.grey[400],
                      ),
                    ],
                  ),
                  onTap: hasItems
                      ? () => _showCategoryDetails(category)
                      : null,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _createPieChartSections() {
    final List<PieChartSectionData> sections = [];

    // Only include categories with calories > 0
    final activeCategories = categoriesData.values
        .where((category) => category.totalCalories > 0)
        .toList();

    // If no categories have calories, return empty list
    if (activeCategories.isEmpty) {
      return sections;
    }

    // Calculate total calories for percentage calculation
    final totalCalories = activeCategories
        .fold(0, (sum, category) => sum + category.totalCalories);

    // Create a section for each active category
    for (final category in activeCategories) {
      // Calculate percentage
      final percentage = (category.totalCalories / totalCalories) * 100;

      sections.add(
        PieChartSectionData(
          color: category.color,
          value: category.totalCalories.toDouble(),
          title: percentage >= 5 ? '${percentage.toInt()}%' : '',
          radius: 100,
          titleStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    }

    return sections;
  }

  void _showCategoryDetails(CategoryData category) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                // Handle
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                // Header
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: category.color,
                        child: Icon(
                          category.icon,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        category.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${category.totalCalories} kcal',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF009439),
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(),

                // Items list
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: category.items.length,
                    itemBuilder: (context, index) {
                      final item = category.items[index];
                      return ListTile(
                        title: Text(item['name']),
                        trailing: Text(
                          '${item['calories']} kcal',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF009439),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class CategoryData {
  final String name;
  final IconData icon;
  final Color color;
  int totalCalories;
  List<Map<String, dynamic>> items;

  CategoryData({
    required this.name,
    required this.icon,
    required this.color,
    required this.totalCalories,
    required this.items,
  });
}