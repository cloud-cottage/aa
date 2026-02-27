import 'package:flutter/material.dart';
import 'package:aa_doudizhu/presentation/screens/lobby_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AA斗地主')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('欢迎来到 AA斗地主', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const LobbyScreen()));
              },
              child: const Text('进入房间'),
            ),
          ],
        ),
      ),
    );
  }
}
