import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: EcommerceHome(),
    );
  }
}

class EcommerceHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Shop"),
        backgroundColor: Colors.blue,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          productCard("Nike Shoes", "\$120"),
          productCard("T-Shirt", "\$35"),
          productCard("Smart Watch", "\$250"),
        ],
      ),
    );
  }

  Widget productCard(String name, String price) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: const Icon(Icons.shopping_bag, size: 40),
        title: Text(name),
        subtitle: Text(price),
        trailing: ElevatedButton(
          onPressed: () {},
          child: const Text("Buy"),
        ),
      ),
    );
  }
}