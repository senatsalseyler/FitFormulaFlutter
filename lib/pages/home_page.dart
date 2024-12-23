import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePage extends StatefulWidget {
  final String name;
  final int calorieGoal;

  const HomePage({super.key, required this.name, required this.calorieGoal});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int totalCalories = 0;
  List<Map<String, dynamic>> foodList = [];
  List<Map<String, dynamic>> savedFoods = [];

  // Fetch food from Open Food Facts API
  Future<void> searchFood(String query) async {
    final url = Uri.parse('https://world.openfoodfacts.org/cgi/search.pl?search_terms=$query&search_simple=1&json=1');

    try {
      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'FitFormula - Flutter - Version 1.0 - www.example.com',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          foodList = (data['products'] as List).map((item) {
            return {
              'name': item['product_name'] ?? 'Unknown',
              'calories': int.tryParse(item['nutriments']?['energy-kcal_100g']?.toString() ?? '0') ?? 0,
              'image': item['image_url'],
              'protein': item['nutriments']?['proteins_100g'] ?? 0.0,
              'carbs': item['nutriments']?['carbohydrates_100g'] ?? 0.0,
              'fat': item['nutriments']?['fat_100g'] ?? 0.0,
            };
          }).toList();
        });
      } else {
        print('Failed to fetch food data: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error fetching food data: $e');
    }
  }

  // Add food and calories
  void addFood(Map<String, dynamic> food, int portion) {
    setState(() {
      int addedCalories = ((food['calories'] ?? 0) * portion) ~/ 100;
      totalCalories += addedCalories;
      savedFoods.add({...food, 'portion': portion});

      if (totalCalories >= widget.calorieGoal) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Calorie Limit Reached!'),
            content: const Text('You have reached or exceeded your calorie limit.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
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
    final progress = (totalCalories / widget.calorieGoal).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: signUserOut,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search for food...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              onSubmitted: searchFood,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.blue,
                      child: Text(
                        widget.name.substring(0, 1).toUpperCase(),
                        style: const TextStyle(fontSize: 30, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Welcome, ${widget.name}!', style: const TextStyle(fontSize: 16)),
                  ],
                ),
                Column(
                  children: [
                    CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 8,
                      backgroundColor: Colors.grey[200],
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                    ),
                    const SizedBox(height: 8),
                    Text('Calories: $totalCalories / ${widget.calorieGoal}', style: const TextStyle(fontSize: 16)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: foodList.length,
                itemBuilder: (context, index) {
                  final food = foodList[index];
                  return ListTile(
                    leading: food['image'] != null
                        ? Image.network(food['image'], width: 50, height: 50, fit: BoxFit.cover)
                        : const Icon(Icons.fastfood),
                    title: Text(food['name']),
                    subtitle: Text('Calories: ${food['calories']} kcal/100g'),
                    trailing: IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            TextEditingController portionController = TextEditingController();
                            return AlertDialog(
                              title: const Text('Enter Portion (g)'),
                              content: TextField(
                                controller: portionController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(hintText: 'Enter portion in grams'),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    final portion = int.tryParse(portionController.text) ?? 0;
                                    if (portion > 0) {
                                      addFood(food, portion);
                                      Navigator.pop(context);
                                    }
                                  },
                                  child: const Text('Add'),
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
            const Divider(),
            const Text('Saved Foods:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView.builder(
                itemCount: savedFoods.length,
                itemBuilder: (context, index) {
                  final food = savedFoods[index];
                  return ListTile(
                    leading: food['image'] != null
                        ? Image.network(food['image'], width: 50, height: 50, fit: BoxFit.cover)
                        : const Icon(Icons.fastfood),
                    title: Text('${food['name']} (x${food['portion']}g)'),
                    subtitle: Text('Calories: ${(food['calories'] * food['portion'] ~/ 100)} kcal'),
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
