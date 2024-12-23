import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  final String name;
  final int calorieGoal;

  const HomePage({super.key, required this.name, required this.calorieGoal});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int totalCalories = 0;

  // Simulate adding food (you would replace this logic with actual food item tracking)
  void addFood(int calories) {
    setState(() {
      totalCalories += calories;
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
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: signUserOut,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Display user name
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blue,
              child: Text(
                widget.name.substring(0, 1).toUpperCase(),
                style: const TextStyle(fontSize: 40, color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Welcome, ${widget.name}!',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Your Calorie Goal: ${widget.calorieGoal}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            // Display calorie progress
            Text(
              'Calories Consumed: $totalCalories',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            CircularProgressIndicator(
              value: progress / 100,
              strokeWidth: 6,
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
            ),
            const SizedBox(height: 20),
            // Button to simulate adding food (with a fixed calorie value for demonstration)
            ElevatedButton(
              onPressed: () => addFood(50),  // Add 50 calories as a test
              child: const Text('Add Food (50 Calories)'),
            ),
            const SizedBox(height: 20),
            // Button to navigate to the DetailsPage (in case user needs to change their info)
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailsPage(
                      name: widget.name,
                      calorieGoal: widget.calorieGoal,
                    ),
                  ),
                );
              },
              child: const Text('Edit Your Details'),
            ),
          ],
        ),
      ),
    );
  }
}

class DetailsPage extends StatefulWidget {
  final String name;
  final int calorieGoal;

  const DetailsPage({super.key, required this.name, required this.calorieGoal});

  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  late TextEditingController _nameController;
  late TextEditingController _calorieController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _calorieController = TextEditingController(text: widget.calorieGoal.toString());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _calorieController.dispose();
    super.dispose();
  }

  void saveDetails() {
    String newName = _nameController.text;
    int newCalorieGoal = int.tryParse(_calorieController.text) ?? widget.calorieGoal;

    // Save the updated details here (e.g., update in Firebase or local storage)

    Navigator.pop(context, {'name': newName, 'calorieGoal': newCalorieGoal});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Your Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _calorieController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Calorie Goal'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: saveDetails,
              child: const Text('Save Details'),
            ),
          ],
        ),
      ),
    );
  }
}