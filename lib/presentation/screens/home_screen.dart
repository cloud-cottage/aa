import 'package:flutter/material.dart';
import 'package:aa_doudizhu/presentation/screens/room_screen.dart';
import 'package:aa_doudizhu/presentation/widgets/card_deck.dart';
import 'package:aa_doudizhu/domain/game_logic/card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Web-friendly responsive layout with a top header
    return Scaffold(
      body: Column(
        children: [
          // header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0B0B0F), Color(0xFF0A0A0F)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('AA斗地主 - AlleyAce', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pushNamed('/lobby'),
                    child: const Text('进入房间'),
                  ),
                ],
              ),
            ),
          ),
          // body
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                return Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF0B0B0F), Color(0xFF0A0A0F)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Left: Branding & CTA
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
                      // Right: 演示牌组预览
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.all(40.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text('牌组预览', style: TextStyle(color: Colors.white, fontSize: 20)),
                              const SizedBox(height: 16),
                              CardDeck(
                                cards: [
                                  CardModel(suit: Suit.clubs, rank: Rank.five, id: 100),
                                  CardModel(suit: Suit.spades, rank: Rank.king, id: 101),
                                  CardModel(suit: Suit.hearts, rank: Rank.ten, id: 102),
                                  CardModel(suit: Suit.diamonds, rank: Rank.nine, id: 103),
                                  CardModel(suit: Suit.clubs, rank: Rank.jack, id: 104),
                                ],
                                cardWidth: 70,
                                cardHeight: 96 * 0.9,
                                spacing: 12,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
