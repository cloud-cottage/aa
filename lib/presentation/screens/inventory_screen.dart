import 'package:flutter/material.dart';
import 'package:aa_doudizhu/core/theme.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('背包')),
      body: Container(
        color: kBackground,
        child: const Center(child: Text('背包', style: TextStyle(color: Colors.white54))),
      ),
    );
  }
}
