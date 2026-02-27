import 'package:flutter/material.dart';
import 'package:aa_doudizhu/presentation/screens/lobby_screen.dart';
import 'package:aa_doudizhu/core/theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [kBackground, Color(0xFF0A0A0F)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              width: double.infinity,
              child: SafeArea(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('AA斗地主 - AlleyAce', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pushNamed('/lobby'),
                      child: const Text('进入房间'),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  return Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.all(40.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '跨端斗地主卡牌游戏，黑暗哥特写实视觉风格',
                                style: TextStyle(fontSize: width > 1000 ? 28 : 18, color: Colors.white70),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton(
                                onPressed: () => Navigator.of(context).pushNamed('/lobby'),
                                child: const Text('进入房间'),
                                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
