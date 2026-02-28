import 'package:flutter/material.dart';
import 'package:aa_doudizhu/core/theme.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('排行榜')),
      body: Container(
        color: kBackground,
        child: const Center(child: Text('排行榜', style: TextStyle(color: Colors.white54))),
      ),
    );
  }
}
