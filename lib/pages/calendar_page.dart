import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late DateTime selectedDay;
  late DateTime focusedDay;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late String userId;
  late int calorieGoal;
  Map<String, int> dailyCalories = {};

  @override
  void initState() {
    super.initState();
    selectedDay = DateTime.now();
    focusedDay = DateTime.now();
    userId = _auth.currentUser!.uid;
    calorieGoal = 2000;  // Example, replace with actual value.
    fetchDailyCalories();
  }

  // Fetch the daily calorie intake for the user from Firestore
  Future<void> fetchDailyCalories() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentSnapshot snapshot = await firestore
        .collection('users')
        .doc(userId)
        .collection('dailyCalories')
        .doc('caloriesData')
        .get();

    if (snapshot.exists) {
      Map<String, dynamic> caloriesData = snapshot.data() as Map<String, dynamic>;
      Map<String, int> calories = {};

      caloriesData.forEach((key, value) {
        calories[key] = value is int ? value : 0;  // Ensure value is int
      });

      setState(() {
        dailyCalories = calories;
      });
    }
  }

  // Save the calorie data for the selected day
  void saveCaloriesToFirestore(String dateKey, int calories) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    await firestore
        .collection('users')
        .doc(userId)
        .collection('dailyCalories')
        .doc('caloriesData')
        .update({dateKey: calories});
  }

  // Determine the color of a day based on the calories consumed
  Color getDayColor(String dateKey) {
    if (dailyCalories.containsKey(dateKey)) {
      final dailyCalorie = dailyCalories[dateKey]!;
      if (dailyCalorie < calorieGoal) {
        return Colors.green; // Less than goal
      } else {
        return Colors.red; // Exceeded goal
      }
    }
    return Colors.grey; // No data for the day
  }

  // Build the indicator widget to show calorie data on each day
  Widget buildDayIndicator(String dateKey) {
    if (dailyCalories.containsKey(dateKey)) {
      final dailyCalorie = dailyCalories[dateKey]!;
      return Positioned(
        bottom: 2,
        right: 2,
        child: CircleAvatar(
          radius: 8,
          backgroundColor: dailyCalorie < calorieGoal ? Colors.green : Colors.red,
          child: Text(
            '${dailyCalorie}',
            style: TextStyle(fontSize: 12, color: Colors.white),
          ),
        ),
      );
    }
    return SizedBox.shrink(); // If no calorie data, return an empty widget
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calendar'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);  // This will take the user back to the homepage
          },
        ),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: focusedDay,
            selectedDayPredicate: (day) => isSameDay(selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                this.selectedDay = selectedDay;
                this.focusedDay = focusedDay;
              });
              // Fetch and display the calorie data for that day
              final dateKey = '${selectedDay.year}-${selectedDay.month}-${selectedDay.day}';
              final calories = dailyCalories[dateKey];
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Calories for ${selectedDay.toLocal()}'),
                  content: Text(
                      'Calories consumed: ${calories ?? 'No data available'}'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('OK'),
                    ),
                  ],
                ),
              );
            },
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.purple,
                shape: BoxShape.circle,
              ),
              defaultDecoration: BoxDecoration(
                shape: BoxShape.circle,
              ),
              weekendDecoration: BoxDecoration(
                color: Colors.grey[300],
                shape: BoxShape.circle,
              ),
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: TextStyle(color: Colors.purple),
              weekendStyle: TextStyle(color: Colors.red),
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, focusedDay) {
                final dateKey = '${day.year}-${day.month}-${day.day}';
                return Stack(
                  children: [
                    Center(child: Text('${day.day}', style: TextStyle(color: Colors.purple))),
                    buildDayIndicator(dateKey),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
