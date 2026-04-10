import 'package:flutter/material.dart';
import 'package:nepali_date_picker/nepali_date_picker.dart' as picker;

class NepaliDateScreen extends StatefulWidget {
  const NepaliDateScreen({super.key});

  @override
  State<NepaliDateScreen> createState() => _NepaliDateScreenState();
}

class _NepaliDateScreenState extends State<NepaliDateScreen> {
  picker.NepaliDateTime selectedDate = picker.NepaliDateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nepali Date"),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),

          const Text(
            "Selected Nepali Date:",
            style: TextStyle(fontSize: 18),
          ),

          const SizedBox(height: 10),

          Text(
            "${selectedDate.year}/${selectedDate.month}/${selectedDate.day}",
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          Expanded(
            child: picker.CalendarDatePicker(
              initialDate: selectedDate,
              firstDate: picker.NepaliDateTime(2070),
              lastDate: picker.NepaliDateTime(2090),
              onDateChanged: (date) {
                setState(() {
                  selectedDate = date;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}