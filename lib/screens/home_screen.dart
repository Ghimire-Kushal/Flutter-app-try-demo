import 'package:flutter/material.dart';
import 'calculator_screen.dart';
import 'date_time_screen.dart';
import 'nepali_date_screen.dart';
import 'english_date_screen.dart';
import 'customize_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Widget buildCard(
    BuildContext context,
    String title,
    Widget screen,
    IconData icon,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Icon(icon, size: 30),
        title: Text(
          title,
          style: const TextStyle(fontSize: 18),
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => screen),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All IN One"),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CustomizeScreen(),
                ),
              );
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            buildCard(
              context,
              "Calculator",
              const CalculatorScreen(),
              Icons.calculate,
            ),
            buildCard(
              context,
              "Date & Time",
              const DateTimeScreen(),
              Icons.access_time,
            ),
            buildCard(
              context,
              "Nepali Date",
              const NepaliDateScreen(),
              Icons.calendar_month,
            ),
            buildCard(
              context,
              "English Date",
              const EnglishDateScreen(),
              Icons.event,
            ),
          ],
        ),
      ),
    );
  }
}