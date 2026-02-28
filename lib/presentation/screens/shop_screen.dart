import 'package:flutter/material.dart';
import 'package:aa_doudizhu/core/theme.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('商城')),
      body: Container(
        color: kBackground,
        child: const Center(child: Text('商城', style: TextStyle(color: Colors.white54))),
      ),
    );
  }
}
