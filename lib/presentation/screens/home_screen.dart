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
            colors: [Color(0xFF1A1A2E), Color(0xFF0F0F1A), Color(0xFF16213E)],
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
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [kGold, kGoldDark]),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.style, color: kBackground, size: 20),
                        ),
                        const SizedBox(width: 12),
                        const Text('AA斗地主', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: kGold.withOpacity(0.3)),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.monetization_on, color: kGold, size: 18),
                              SizedBox(width: 4),
                              Text('1000', style: TextStyle(color: kGold, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: kSurface,
                            border: Border.all(color: kGold.withOpacity(0.5)),
                          ),
                          child: const Center(child: Text('我', style: TextStyle(color: kGold, fontSize: 12))),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('AA斗地主', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 8),
                    const Text('黑暗哥特写实风格\n融合NFT与虚拟货币的斗地主游戏', style: TextStyle(color: Colors.white54, fontSize: 16, height: 1.5)),
                    const SizedBox(height: 32),
                    const Text('功能菜单', style: TextStyle(color: kGold, fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Expanded(
                      child: GridView.count(
                        crossAxisCount: 3,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 1,
                        children: [
                          _buildMenuItem(Icons.groups, '多人游戏', Colors.purple),
                          _buildMenuItem(Icons.store, '商城', Colors.orange),
                          _buildMenuItem(Icons.inventory_2, '背包', Colors.green),
                          _buildMenuItem(Icons.leaderboard, '排行榜', Colors.red),
                          _buildMenuItem(Icons.person, '我的', Colors.teal),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pushNamed('/lobby'),
                        child: const Text('进入房间'),
                        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String label, Color color) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: kSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}
