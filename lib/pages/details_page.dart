import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_page.dart';

class DetailsPage extends StatefulWidget {
  const DetailsPage({super.key});

  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  final nameController = TextEditingController();
  final calorieController = TextEditingController();

  void saveDetails() async {
    final name = nameController.text;
    final calorieGoal = int.tryParse(calorieController.text) ?? 0;

    if (name.isNotEmpty && calorieGoal > 0) {
      // Save user details to Firebase (Firestore or Realtime Database)
      User? user = FirebaseAuth.instance.currentUser;
      // Assuming you're using Firestore to store user data
      // You can replace this with your Firebase Firestore code

      // For simplicity, we use local storage for now
      // You can replace this with Firestore calls
      await FirebaseAuth.instance.currentUser!.updateDisplayName(name);

      // Navigate to the home page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage(name: name, calorieGoal: calorieGoal)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Set Your Details")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: calorieController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Calorie Goal'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: saveDetails,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
