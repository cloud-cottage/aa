import 'package:flutter/material.dart';
import 'package:aa_doudizhu/core/theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('个人资料')),
      body: Container(
        color: kBackground,
        child: const Center(child: Text('个人资料', style: TextStyle(color: Colors.white54))),
      ),
    );
  }
}
