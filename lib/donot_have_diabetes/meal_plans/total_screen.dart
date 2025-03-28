import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:table_calendar/table_calendar.dart';
import 'summary.dart';

class TotalScreen extends StatefulWidget {
  final String category;
  const TotalScreen({Key? key, required this.category}) : super(key: key);

  @override
  _TotalScreenState createState() => _TotalScreenState();
}

class _TotalScreenState extends State<TotalScreen> {
  List<Map<String, dynamic>> clickedItems = [];
  num totalCalories = 0;
  bool isLoading = true;
  DateTime selectedDate = DateTime.now();
  bool showCalendar = false;
  Map<DateTime, num> dailyTotals = {};

  void _fetchClickedItems() async {
    setState(() {
      isLoading = true;
    });

    final userId = 'user123'; // Replace with the actual user ID
    final userRef = FirebaseFirestore.instance.collection('users').doc(userId);

    try {
      num caloriesSum = 0;
      List<Map<String, dynamic>> items = [];
      List<String> categories = ['vegetable_calories', 'fruit_calories', 'grain_calories'];

      // Format date for comparison (start and end of selected day)
      final startOfDay = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
      );

      final endOfDay = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          23, 59, 59, 999
      );

      for (String category in categories) {
        final querySnapshot = await userRef.collection(category)
            .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
            .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
            .get();

        for (var doc in querySnapshot.docs) {
          final data = doc.data();
          items.add({
            'id': doc.id,
            'name': data['name'],
            'calories': data['calories'],
            'timestamp': data['timestamp'],
          });

          if (data['calories'] is num) {
            caloriesSum += data['calories'];
          }
        }
      }

      // Sort items by timestamp (newest first)
      items.sort((a, b) {
        final aTimestamp = a['timestamp'];
        final bTimestamp = b['timestamp'];
        if (aTimestamp == null || bTimestamp == null) return 0;
        return bTimestamp.compareTo(aTimestamp);
      });

      setState(() {
        clickedItems = items;
        totalCalories = caloriesSum;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching items: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  void _fetchDailyTotals() async {
    final userId = 'user123'; // Replace with actual user ID
    final userRef = FirebaseFirestore.instance.collection('users').doc(userId);

    // Get the first day of the month
    final firstDay = DateTime(selectedDate.year, selectedDate.month, 1);
    // Get the last day of the month
    final lastDay = DateTime(selectedDate.year, selectedDate.month + 1, 0);

    try {
      Map<DateTime, num> totals = {};
      List<String> categories = ['vegetable_calories', 'fruit_calories', 'grain_calories'];

      for (String category in categories) {
        final querySnapshot = await userRef.collection(category)
            .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(firstDay))
            .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(lastDay))
            .get();

        for (var doc in querySnapshot.docs) {
          final data = doc.data();
          if (data['timestamp'] != null && data['calories'] is num) {
            final timestamp = data['timestamp'] as Timestamp;
            final date = timestamp.toDate();
            final dayDate = DateTime(date.year, date.month, date.day);

            if (totals.containsKey(dayDate)) {
              totals[dayDate] = totals[dayDate]! + data['calories'];
            } else {
              totals[dayDate] = data['calories'];
            }
          }
        }
      }

      setState(() {
        dailyTotals = totals;
      });
    } catch (e) {
      print("Error fetching daily totals: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchClickedItems();
    _fetchDailyTotals();
  }

  void _onDaySelected(DateTime day, DateTime focusedDay) {
    setState(() {
      selectedDate = day;
      showCalendar = false;
    });
    _fetchClickedItems();
  }

  @override
  Widget build(BuildContext context) {
    final isToday = selectedDate.year == DateTime.now().year &&
        selectedDate.month == DateTime.now().month &&
        selectedDate.day == DateTime.now().day;

    return Scaffold(
      appBar: AppBar(
        title: Text('Daily Calories'),
        backgroundColor: const Color(0x0065F3FF),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_month),
            onPressed: () {
              setState(() {
                showCalendar = !showCalendar;
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (showCalendar)
              TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: selectedDate,
                selectedDayPredicate: (day) {
                  return isSameDay(selectedDate, day);
                },
                onDaySelected: _onDaySelected,
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, date, events) {
                    final dayDate = DateTime(date.year, date.month, date.day);
                    if (dailyTotals.containsKey(dayDate)) {
                      return Positioned(
                        bottom: 1,
                        child: Container(
                          width: 35,
                          height: 15,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${dailyTotals[dayDate]!.toInt()}',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }
                    return null;
                  },
                ),
              ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0x81FFFBB9),
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
                    isToday
                        ? 'Today\'s Calories'
                        : 'Calories for ${DateFormat('MMM d, yyyy').format(selectedDate)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
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
                        '${totalCalories.toStringAsFixed(0)} kcal',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF009439),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : clickedItems.isEmpty
                  ? Center(
                child: Text(
                  isToday
                      ? 'No items added today'
                      : 'No items added on this day',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
              )
                  : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: clickedItems.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final item = clickedItems[index];
                  final timestamp = item['timestamp'] as Timestamp;
                  final itemDate = timestamp.toDate();

                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      item['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Text(
                      DateFormat('h:mm a').format(itemDate),
                      style: TextStyle(
                        fontSize: 12,

                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${item['calories']} kcal',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF009439),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                          onPressed: () => _deleteItem(item['id']),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SummaryScreen()),
          );
        },
        backgroundColor: const Color(0xFF00FF62),
        child: const Icon(Icons.pie_chart),
        tooltip: 'View Summary',
      ),
    );
  }

  void _deleteItem(String id) async {
    final userId = 'user123';
    final userRef = FirebaseFirestore.instance.collection('users').doc(userId);

    try {
      // First determine which collection the item is in
      List<String> collections = ['vegetable_calories', 'fruit_calories', 'grain_calories','dairy_calories'];
      String? itemCollection;

      for (String collection in collections) {
        final docSnapshot = await userRef.collection(collection).doc(id).get();
        if (docSnapshot.exists) {
          itemCollection = collection;
          break;
        }
      }

      if (itemCollection != null) {
        final docSnapshot = await userRef.collection(itemCollection).doc(id).get();
        final data = docSnapshot.data();
        final calories = data?['calories'] ?? 0;
        await userRef.collection(itemCollection).doc(id).delete();

        // Update the UI
        setState(() {
          clickedItems.removeWhere((item) => item['id'] == id);
          totalCalories -= calories;
        });

        // Update daily totals
        _fetchDailyTotals();
      }
    } catch (e) {
      print("Error deleting item: $e");
    }
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}