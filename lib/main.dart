import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AA斗地主',
      home: Scaffold(
        body: Container(
          color: Colors.red,
          child: const Center(
            child: Text('HELLO WORLD', style: TextStyle(fontSize: 40)),
          ),
        ),
      ),
    );
  }
}
