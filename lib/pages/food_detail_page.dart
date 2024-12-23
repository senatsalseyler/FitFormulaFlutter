import 'package:flutter/material.dart';

class FoodDetailPage extends StatelessWidget {
  final String foodName;
  final int calories;
  final double protein;
  final double carbs;
  final double fat;

  const FoodDetailPage({
    Key? key,
    required this.foodName,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(foodName)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Calories: $calories kcal', style: TextStyle(fontSize: 18)),
            SizedBox(height: 16),
            Text('Protein: $protein g', style: TextStyle(fontSize: 18)),
            Text('Carbs: $carbs g', style: TextStyle(fontSize: 18)),
            Text('Fat: $fat g', style: TextStyle(fontSize: 18)),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Go back to HomePage
              },
              child: Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }
}
