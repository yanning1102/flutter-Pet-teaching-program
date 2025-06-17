import 'package:flutter/material.dart';
import 'package:celebrities/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '可愛動物 App',
      home: const HomePage(),
    );
  }
}


