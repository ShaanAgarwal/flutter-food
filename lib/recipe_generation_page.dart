// recipe_generation_page.dart
import 'package:flutter/material.dart';

class RecipeGenerationPage extends StatelessWidget {
  const RecipeGenerationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipe Generation'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              'Welcome to Recipe Generation!',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            Text(
              'Here, you can generate recipes based on your available ingredients.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            // You can add more functionality here later (e.g., form fields, buttons)
          ],
        ),
      ),
    );
  }
}
