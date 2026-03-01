import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: SimpleApp()));
}

class SimpleApp extends StatelessWidget {
  const SimpleApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AA斗地主 - AlleyAce',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFFD4AF37), // 金色
        scaffoldBackgroundColor: const Color(0xFF1A1A2E),
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFFD4AF37),
          surface: const Color(0xFF16213E),
          background: const Color(0xFF0F0F1A),
        ),
      ),
      home: const SimpleHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SimpleHomePage extends StatelessWidget {
  const SimpleHomePage({Key? key}) : super(key: key);

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
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 顶部标题栏
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFFD4AF37), Color(0xFFB8941F)]),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.style, color: Color(0xFF1A1A2E), size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'AA斗地主',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4AF37).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.monetization_on, color: Color(0xFFD4AF37), size: 18),
                          SizedBox(width: 4),
                          Text('1000', style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 48),
                
                // 主要内容
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'AA斗地主',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        '黑暗哥特写实风格\n融合NFT与虚拟货币的斗地主游戏',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                      
                      const SizedBox(height: 48),
                      
                      // 功能卡片
                      Expanded(
                        child: GridView.count(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 1.2,
                          children: [
                            _buildFeatureCard(
                              Icons.groups,
                              '多人对战',
                              '3人实时对战，智能AI替补',
                              Colors.purple,
                            ),
                            _buildFeatureCard(
                              Icons.auto_awesome,
                              'NFT特效',
                              '炸弹积分翻倍等特殊效果',
                              Colors.orange,
                            ),
                            _buildFeatureCard(
                              Icons.smart_toy,
                              '智能AI',
                              '多种难度，无缝接管',
                              Colors.green,
                            ),
                            _buildFeatureCard(
                              Icons.casino,
                              '完整规则',
                              '标准斗地主规则实现',
                              Colors.red,
                            ),
                          ],
                        ),
                      ),
                      
                      // 开始按钮
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('游戏功能开发中，敬请期待！'),
                                backgroundColor: Color(0xFFD4AF37),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD4AF37),
                            foregroundColor: const Color(0xFF1A1A2E),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.play_arrow),
                              SizedBox(width: 8),
                              Text('开始游戏', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(IconData icon, String title, String description, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Text(
                description,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
