import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  final String name;
  final int calorieGoal;

  const HomePage({super.key, required this.name, required this.calorieGoal});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int totalCalories = 0;
  List<dynamic> foodList = [];
  List<dynamic> savedFoods = [];

  // Fetch food items from Open Food Facts API
  Future<void> fetchFood(String query) async {
    final url = Uri.parse('https://world.openfoodfacts.org/cgi/search.pl?search_terms=$query&search_simple=1&action=process&json=1');
    final response = await http.get(
      url,
      headers: {
        'User-Agent': 'FitFormula - Flutter - Version 1.0 - www.example.com',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        foodList = jsonDecode(response.body)['products'] ?? [];
      });
    }
  }

  // Simulate adding food (you would replace this logic with actual food item tracking)
  void addFood(int calories) {
    setState(() {
      totalCalories += calories;
      if (totalCalories >= widget.calorieGoal) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Calorie Limit Reached!'),
            content: Text('You have reached or exceeded your calorie limit.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    });
  }

  // Sign out the user
  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final progress = (totalCalories / widget.calorieGoal) * 100;

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          onChanged: (query) async {
            await fetchFood(query);
          },
          decoration: InputDecoration(
            hintText: 'Search food',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            prefixIcon: Icon(Icons.search),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: signUserOut,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Display user name
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.blue,
                  child: Text(
                    widget.name.substring(0, 1).toUpperCase(),
                    style: TextStyle(fontSize: 24, color: Colors.white),
                  ),
                ),
                // Display calorie progress
                Column(
                  children: [
                    Text(
                      'Calories Consumed: $totalCalories',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: CircularProgressIndicator(
                        value: progress / 100,
                        strokeWidth: 6,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: foodList.length,
                itemBuilder: (context, index) {
                  final food = foodList[index];
                  return ListTile(
                    leading: food['image_url'] != null
                        ? Image.network(food['image_url'], width: 50, height: 50)
                        : Icon(Icons.fastfood),
                    title: Text(food['product_name'] ?? 'Unnamed Food'),
                    subtitle: Text('${food['nutriments']?['energy-kcal_100g'] ?? 0} kcal per 100g'),
                    trailing: IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            final controller = TextEditingController();
                            return AlertDialog(
                              title: Text('Enter Portion Size (g)'),
                              content: TextField(
                                controller: controller,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(hintText: 'Portion in grams'),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    final portion = int.tryParse(controller.text) ?? 0;
                                    final calories = ((food['nutriments']?['energy-kcal_100g'] ?? 0) * portion / 100).toInt();
                                    addFood(calories);
                                    setState(() {
                                      savedFoods.add({
                                        'name': food['product_name'],
                                        'calories': calories,
                                      });
                                    });
                                    Navigator.pop(context);
                                  },
                                  child: Text('Add'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            Divider(),
            Text('Saved Foods:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView.builder(
                itemCount: savedFoods.length,
                itemBuilder: (context, index) {
                  final saved = savedFoods[index];
                  return ListTile(
                    title: Text(saved['name'] ?? 'Unnamed Food'),
                    subtitle: Text('${saved['calories']} kcal'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
