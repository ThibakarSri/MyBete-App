import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'monthly_stats_screen.dart';

class BiWeeklyStatsScreen extends StatefulWidget {
  final List<Map<String, dynamic>> logEntries;
  final Color primaryColor;
  final Color accentColor;
  final Color lightColor;
  final Color veryLightColor;
  final Color tealColor;
  final Color textColor;

  const BiWeeklyStatsScreen({
    Key? key,
    required this.logEntries,
    required this.primaryColor,
    required this.accentColor,
    required this.lightColor,
    required this.veryLightColor,
    required this.tealColor,
    required this.textColor,
  }) : super(key: key);

  @override
  State<BiWeeklyStatsScreen> createState() => _BiWeeklyStatsScreenState();
}

class _BiWeeklyStatsScreenState extends State<BiWeeklyStatsScreen> {
  // Current bi-weekly data
  String currentBiWeek = '';
  int totalLogs = 0;
  double averageBloodSugar = 0.0;

  // Bi-weekly data points
  List<FlSpot> biWeeklySpots = [];
  List<String> weekLabels = ['9', '10'];

  // Previous bi-week data
  String previousBiWeek = '';

  // Expanded sections
  bool _isCurrentBiWeekExpanded = true;
  bool _isPreviousBiWeekExpanded = false;

  @override
  void initState() {
    super.initState();
    _processLogData();
  }

  void _processLogData() {
    if (widget.logEntries.isEmpty) {
      setState(() {
        totalLogs = 0;
        averageBloodSugar = 0.0;
        biWeeklySpots = [];
      });
      return;
    }

    // Get current date and calculate bi-week start/end
    final now = DateTime.now();
    final weekNumber = (now.difference(DateTime(now.year, 1, 1)).inDays / 7).ceil();
    final currentWeekStart = now.subtract(Duration(days: now.weekday - 1));
    final biWeekStart = currentWeekStart.subtract(Duration(days: 7));
    final biWeekEnd = currentWeekStart.add(const Duration(days: 6));

    // Format current bi-week string
    currentBiWeek = '${DateFormat('MMM d').format(biWeekStart)} - ${DateFormat('MMM d').format(biWeekEnd)}, ${biWeekStart.year}';

    // Calculate previous bi-week
    final prevBiWeekStart = biWeekStart.subtract(const Duration(days: 14));
    final prevBiWeekEnd = biWeekStart.subtract(const Duration(days: 1));
    previousBiWeek = '${DateFormat('MMM d').format(prevBiWeekStart)} - ${DateFormat('MMM d').format(prevBiWeekEnd)}, ${prevBiWeekStart.year}';

    // Filter logs for current bi-week
    final biWeekLogs = widget.logEntries.where((log) {
      final logDate = log['date'] is Timestamp
          ? (log['date'] as Timestamp).toDate()
          : DateTime.parse(log['date'].toString());
      return logDate.isAfter(biWeekStart.subtract(const Duration(days: 1))) &&
          logDate.isBefore(biWeekEnd.add(const Duration(days: 1)));
    }).toList();

    // Calculate total logs and average blood sugar
    totalLogs = biWeekLogs.length;

    double totalBloodSugar = 0;
    int bloodSugarCount = 0;

    // Initialize spots for each week of the bi-week
    biWeeklySpots = [FlSpot(0, 0), FlSpot(1, 0)];
    weekLabels = ['${weekNumber-1}', '$weekNumber'];

    // Group logs by week
    Map<int, List<Map<String, dynamic>>> weeklyLogs = {
      0: [], // First week
      1: [], // Second week
    };

    // Process each log
    for (var log in biWeekLogs) {
      if (log['bloodSugar'] != null) {
        final bloodSugar = double.parse(log['bloodSugar'].toString());
        totalBloodSugar += bloodSugar;
        bloodSugarCount++;

        // Add to weekly groups
        final logDate = log['date'] is Timestamp
            ? (log['date'] as Timestamp).toDate()
            : DateTime.parse(log['date'].toString());
        final weekIndex = logDate.isBefore(currentWeekStart) ? 0 : 1;
        weeklyLogs[weekIndex]!.add(log);
      }
    }

    // Calculate weekly averages
    for (int i = 0; i < 2; i++) {
      final weekLogs = weeklyLogs[i]!;
      if (weekLogs.isNotEmpty) {
        double weekTotal = 0;
        int weekCount = 0;

        for (var log in weekLogs) {
          if (log['bloodSugar'] != null) {
            weekTotal += double.parse(log['bloodSugar'].toString());
            weekCount++;
          }
        }

        if (weekCount > 0) {
          biWeeklySpots[i] = FlSpot(i.toDouble(), weekTotal / weekCount);
        }
      }
    }

    // Calculate overall average
    setState(() {
      averageBloodSugar = bloodSugarCount > 0 ? totalBloodSugar / bloodSugarCount : 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: widget.primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Stats',
          style: TextStyle(
            fontFamily: GoogleFonts.poppins().fontFamily,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // Total logs section
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: widget.lightColor,
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total logs',
                  style: TextStyle(
                    fontFamily: GoogleFonts.poppins().fontFamily,
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '$totalLogs',
                  style: TextStyle(
                    fontFamily: GoogleFonts.poppins().fontFamily,
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Bi-Weekly Stats section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Center(
                        child: Text(
                          'Bi-Weekly Stats',
                          style: TextStyle(
                            fontFamily: GoogleFonts.poppins().fontFamily,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: widget.textColor,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.arrow_forward_ios, size: 18),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MonthlyStatsScreen(
                              logEntries: widget.logEntries,
                              primaryColor: widget.primaryColor,
                              accentColor: widget.accentColor,
                              lightColor: widget.lightColor,
                              veryLightColor: widget.veryLightColor,
                              tealColor: widget.tealColor,
                              textColor: widget.textColor,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                Text(
                  '24 Feb - 9 Mar',
                  style: TextStyle(
                    fontFamily: GoogleFonts.poppins().fontFamily,
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 20),

                // Average circle
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.lightColor,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          averageBloodSugar > 0 ? averageBloodSugar.toStringAsFixed(1) : '---',
                          style: TextStyle(
                            fontFamily: GoogleFonts.poppins().fontFamily,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: widget.textColor,
                          ),
                        ),
                        Text(
                          'mg/dL',
                          style: TextStyle(
                            fontFamily: GoogleFonts.poppins().fontFamily,
                            fontSize: 14,
                            color: widget.textColor.withAlpha(178),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Average',
                  style: TextStyle(
                    fontFamily: GoogleFonts.poppins().fontFamily,
                    fontSize: 16,
                    color: widget.textColor,
                  ),
                ),
              ],
            ),
          ),

          // Chart section
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Bi-week header with toggle
                  InkWell(
                    onTap: () {
                      setState(() {
                        _isCurrentBiWeekExpanded = !_isCurrentBiWeekExpanded;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      color: widget.accentColor,
                      width: double.infinity,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            currentBiWeek,
                            style: TextStyle(
                              fontFamily: GoogleFonts.poppins().fontFamily,
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Icon(
                            _isCurrentBiWeekExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Line chart (collapsible)
                  if (_isCurrentBiWeekExpanded)
                    Container(
                      height: 300,
                      padding: const EdgeInsets.all(16.0),
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: true,
                            horizontalInterval: 80,
                            verticalInterval: 1,
                            getDrawingHorizontalLine: (value) {
                              if (value == 160) { // High glucose level
                                return FlLine(
                                  color: Colors.red.withAlpha(100),
                                  strokeWidth: 1,
                                );
                              } else if (value == 80) { // Low glucose level
                                return FlLine(
                                  color: Colors.blue.withAlpha(100),
                                  strokeWidth: 1,
                                );
                              }
                              return FlLine(
                                color: Colors.grey.withAlpha(30),
                                strokeWidth: 0.5,
                              );
                            },
                            getDrawingVerticalLine: (value) {
                              return FlLine(
                                color: Colors.grey.withAlpha(30),
                                strokeWidth: 0.5,
                              );
                            },
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 30,
                                interval: 1,
                                getTitlesWidget: (value, meta) {
                                  if (value.toInt() >= 0 && value.toInt() < weekLabels.length) {
                                    return Text(
                                      'Week ${weekLabels[value.toInt()]}',
                                      style: TextStyle(
                                        fontFamily: GoogleFonts.poppins().fontFamily,
                                        color: widget.textColor.withAlpha(150),
                                        fontSize: 10,
                                      ),
                                    );
                                  }
                                  return Text('');
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: 80,
                                reservedSize: 40,
                                getTitlesWidget: (value, meta) {
                                  if (value % 80 == 0 && value > 0) {
                                    return Text(
                                      '${value.toInt()}',
                                      style: TextStyle(
                                        fontFamily: GoogleFonts.poppins().fontFamily,
                                        color: widget.textColor.withAlpha(150),
                                        fontSize: 10,
                                      ),
                                    );
                                  }
                                  return Text('');
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(
                            show: true,
                            border: Border(
                              bottom: BorderSide(color: Colors.grey.withAlpha(50)),
                              left: BorderSide(color: Colors.grey.withAlpha(50)),
                            ),
                          ),
                          minX: 0,
                          maxX: 1,
                          minY: 0,
                          maxY: 240,
                          lineBarsData: [
                            LineChartBarData(
                              spots: biWeeklySpots.where((spot) => spot.y > 0).toList(),
                              isCurved: true,
                              color: widget.tealColor,
                              barWidth: 2,
                              isStrokeCapRound: true,
                              dotData: FlDotData(
                                show: true,
                                getDotPainter: (spot, percent, barData, index) {
                                  return FlDotCirclePainter(
                                    radius: 5,
                                    color: widget.tealColor,
                                    strokeWidth: 2,
                                    strokeColor: Colors.white,
                                  );
                                },
                              ),
                              belowBarData: BarAreaData(
                                show: true,
                                color: widget.tealColor.withAlpha(30),
                              ),
                            ),
                          ],
                          lineTouchData: LineTouchData(
                            touchTooltipData: LineTouchTooltipData(
                              getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                                return touchedBarSpots.map((barSpot) {
                                  return LineTooltipItem(
                                    '${barSpot.y.toInt()} mg/dL',
                                    TextStyle(
                                      fontFamily: GoogleFonts.poppins().fontFamily,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                }).toList();
                              },
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Previous bi-week section with toggle
                  InkWell(
                    onTap: () {
                      setState(() {
                        _isPreviousBiWeekExpanded = !_isPreviousBiWeekExpanded;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      color: widget.accentColor,
                      width: double.infinity,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            previousBiWeek,
                            style: TextStyle(
                              fontFamily: GoogleFonts.poppins().fontFamily,
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Icon(
                            _isPreviousBiWeekExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Previous bi-week content (collapsible)
                  if (_isPreviousBiWeekExpanded)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(
                        child: Text(
                          'Bi-weekly blood sugar chart will be displayed here',
                          style: TextStyle(
                            fontFamily: GoogleFonts.poppins().fontFamily,
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

