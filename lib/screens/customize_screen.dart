import '../main.dart';
import 'package:flutter/material.dart';

class CustomizeScreen extends StatelessWidget {
  const CustomizeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),

            const CircleAvatar(
              radius: 60,
              backgroundImage: AssetImage(
                'assets/images/profile.png',
              ),
            ),

            const SizedBox(height: 20),
            SwitchListTile(
  title: const Text("Dark Mode"),
  value: MyApp.of(context).isDarkMode,
  onChanged: (value) {
    MyApp.of(context).toggleTheme();
  },
),

            const Text(
              "Kushal",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              "Customize your All IN One app",
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}