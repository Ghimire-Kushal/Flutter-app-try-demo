import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EnglishDateScreen extends StatefulWidget {
  const EnglishDateScreen({super.key});

  @override
  State<EnglishDateScreen> createState() => _EnglishDateScreenState();
}

class _EnglishDateScreenState extends State<EnglishDateScreen> {
  DateTime selectedDate = DateTime.now();

  Future<void> pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("English Date"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              DateFormat('EEEE, MMMM d, yyyy').format(selectedDate),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            ElevatedButton.icon(
              onPressed: pickDate,
              icon: const Icon(Icons.calendar_month),
              label: const Text("Select Date"),
            ),
          ],
        ),
      ),
    );
  }
}