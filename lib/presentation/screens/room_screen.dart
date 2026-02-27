import 'package:flutter/material.dart';
import 'package:aa_doudizhu/domain/game_logic/card.dart';
import 'package:aa_doudizhu/presentation/widgets/card_deck.dart';
import 'package:aa_doudizhu/domain/game_logic/rule_checker.dart';
import 'package:aa_doudizhu/domain/game_logic/game_state.dart';
import 'package:aa_doudizhu/core/theme.dart';

class RoomScreen extends StatefulWidget {
  const RoomScreen({Key? key}) : super(key: key);

  @override
  _RoomScreenState createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  late List<CardModel> hand;
  final Set<int> _selected = {};
  String _currentPlayer = '玩家1';
  final List<String> _players = ['玩家1', '玩家2', '玩家3', '玩家4'];

  @override
  void initState() {
    super.initState();
    hand = _demoHand();
  }

  List<CardModel> _demoHand() {
    return [
      CardModel(suit: Suit.hearts, rank: Rank.four, id: 1),
      CardModel(suit: Suit.spades, rank: Rank.king, id: 2),
      CardModel(suit: Suit.clubs, rank: Rank.ten, id: 3),
      CardModel(suit: Suit.diamonds, rank: Rank.nine, id: 4),
      CardModel(suit: Suit.clubs, rank: Rank.jack, id: 5),
      CardModel(suit: Suit.spades, rank: Rank.eight, id: 6),
    ];
  }

  void _toggleSelect(int idx) {
    setState(() {
      if (_selected.contains(idx)) {
        _selected.remove(idx);
      } else {
        _selected.add(idx);
      }
    });
  }

  void _handlePlay() {
    final playing = _selected.toList();
    if (playing.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先选择要出的牌')),
      );
      return;
    }
    final selectedCards = playing.map((i) => hand[i]).toList();
    final state = GameState(roomId: 'r', currentTurnPlayerId: _currentPlayer, hands: hand, deskCards: []);
    final ok = SimpleRuleChecker().isLegalPlay(selectedCards, state);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? '出牌合法' : '出牌不合法'),
        backgroundColor: ok ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kSurface,
        title: Row(
          children: [
            Icon(Icons.casino, color: kGold, size: 20),
            const SizedBox(width: 8),
            const Text('房间 - 私人房'),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.settings), onPressed: () {}),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [kBackground, Color(0xFF0A0A0A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            // Top: Players row
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              color: Colors.black26,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: _players.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final name = entry.value;
                  final isCurrentTurn = name == _currentPlayer;
                  return _playerAvatar(name, isCurrentTurn);
                }).toList(),
              ),
            ),
            // Center: Table area
            Expanded(
              child: Center(
                child: Container(
                  margin: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.black38,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: kGold.withOpacity(0.2), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: kGold.withOpacity(0.05),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.table_restaurant, size: 48, color: Colors.white12),
                        const SizedBox(height: 12),
                        Text('等待开始...', style: TextStyle(color: Colors.white38, fontSize: 16)),
                        const SizedBox(height: 8),
                        Text('底分: 1', style: TextStyle(color: kGold, fontSize: 14)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Bottom: Hand and actions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: kSurface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black45,
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('手牌 (${hand.length}张)', style: TextStyle(color: Colors.white70, fontSize: 14)),
                        Text('当前: $_currentPlayer', style: TextStyle(color: kGold, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 100,
                      child: CardDeck(
                        cards: hand,
                        selectedIndices: _selected,
                        onCardTap: _toggleSelect,
                        cardWidth: 60,
                        cardHeight: 84,
                        spacing: 4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _handlePlay,
                            icon: const Icon(Icons.arrow_upward),
                            label: const Text('出牌'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kGold,
                              foregroundColor: kBackground,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('提示功能开发中...')),
                            );
                          },
                          icon: const Icon(Icons.lightbulb_outline),
                          label: const Text('提示'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kSurfaceLight,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              _selected.clear();
                            });
                          },
                          icon: const Icon(Icons.clear),
                          label: const Text('取消'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.withOpacity(0.2),
                            foregroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                          ),
                        ),
                      ],
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

  Widget _playerAvatar(String name, bool isCurrentTurn) {
    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCurrentTurn ? kGold : kSurfaceLight,
            border: Border.all(
              color: isCurrentTurn ? kGold : Colors.white24,
              width: isCurrentTurn ? 2 : 1,
            ),
            boxShadow: isCurrentTurn ? [
              BoxShadow(color: kGold.withOpacity(0.4), blurRadius: 8),
            ] : null,
          ),
          child: Center(
            child: Text(
              name[0],
              style: TextStyle(
                color: isCurrentTurn ? kBackground : Colors.white54,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          name,
          style: TextStyle(
            color: isCurrentTurn ? kGold : Colors.white54,
            fontSize: 11,
            fontWeight: isCurrentTurn ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
