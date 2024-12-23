import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'food_detail_page.dart';  // Import the FoodDetailPage file

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
  TextEditingController searchController = TextEditingController();

  // Fetch food items from Open Food Facts API
  Future<void> fetchFood(String query) async {
    if (query.isEmpty) {
      setState(() {
        foodList = [];
      });
      return;
    }

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
    } else {
      print('Failed to fetch data');
    }
  }

  // Add food to the calorie tracker
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
        title: Row(
          children: [
            // Welcome Message on the left
            Text(
              'Welcome, ${widget.name}',
              style: TextStyle(
                fontSize: 18,
                color: Colors.purple,
                fontWeight: FontWeight.bold,
              ),
            ),
            Spacer(),
            // Sign-out button
            IconButton(
              icon: Icon(Icons.logout, color: Colors.purple),
              onPressed: signUserOut,
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Welcome, Search Bar, and Progress Bar in a vertical layout
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Search Bar
                Container(
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: TextField(
                    controller: searchController,
                    onChanged: (query) async {
                      await fetchFood(query);
                    },
                    decoration: InputDecoration(
                      hintText: 'Search food',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      prefixIcon: Icon(Icons.search, color: Colors.purple),
                    ),
                  ),
                ),
                // Progress Bar on the Right
                Column(
                  children: [
                    Text(
                      'Calories Consumed: $totalCalories',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    SizedBox(
                      width: 100,
                      height: 100,
                      child: CircularProgressIndicator(
                        value: progress / 100,
                        strokeWidth: 8,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16),
            // Displaying Food Items List
            Expanded(
              child: ListView.builder(
                itemCount: foodList.length,
                itemBuilder: (context, index) {
                  final food = foodList[index];
                  return ListTile(
                    leading: food['image_url'] != null
                        ? Image.network(food['image_url'], width: 50, height: 50)
                        : Icon(Icons.fastfood, color: Colors.purple),
                    title: Text(
                      food['product_name'] ?? 'Unnamed Food',
                      style: TextStyle(color: Colors.purple),
                    ),
                    subtitle: Text(
                      '${food['nutriments']?['energy-kcal_100g'] ?? 0} kcal per 100g',
                      style: TextStyle(color: Colors.purple),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Info Button to show food details
                        IconButton(
                          icon: Icon(Icons.info, color: Colors.purple),
                          onPressed: () {
                            // Navigate to FoodDetailPage with relevant data
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FoodDetailPage(
                                  foodName: food['product_name'] ?? 'Unnamed Food',
                                  calories: (food['nutriments']?['energy-kcal_100g'] ?? 0).toInt(),
                                  protein: (food['nutriments']?['proteins_100g'] ?? 0).toDouble(),
                                  carbs: (food['nutriments']?['carbohydrates_100g'] ?? 0).toDouble(),
                                  fat: (food['nutriments']?['fat_100g'] ?? 0).toDouble(),
                                ),
                              ),
                            );
                          },
                        ),
                        // Add Button
                        IconButton(
                          icon: Icon(Icons.add, color: Colors.purple),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                final controller = TextEditingController();
                                return AlertDialog(
                                  title: Text('Enter Portion Size (g)', style: TextStyle(color: Colors.purple)),
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
                                      child: Text('Add', style: TextStyle(color: Colors.purple)),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Divider(),
            Text(
              'Saved Foods:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.purple),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: savedFoods.length,
                itemBuilder: (context, index) {
                  final saved = savedFoods[index];
                  return ListTile(
                    title: Text(saved['name'] ?? 'Unnamed Food', style: TextStyle(color: Colors.purple)),
                    subtitle: Text('${saved['calories']} kcal', style: TextStyle(color: Colors.purple)),
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
