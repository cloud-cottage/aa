import 'package:flutter/material.dart';
import 'package:aa_doudizhu/core/theme.dart';
import 'package:aa_doudizhu/presentation/screens/home_screen.dart';

void main() {
  runApp(const AAApp());
}

class AAApp extends StatelessWidget {
  const AAApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AA斗地主 - AlleyAce',
      theme: gothicTheme(),
      home: const HomeScreen(),
    );
  }
}
