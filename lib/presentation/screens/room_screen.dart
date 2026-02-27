import 'package:flutter/material.dart';
import 'package:aa_doudizhu/domain/game_logic/card.dart';
import 'package:aa_doudizhu/presentation/widgets/card_deck.dart';
import 'package:aa_doudizhu/presentation/widgets/playing_card.dart';
import 'package:aa_doudizhu/domain/game_logic/rule_checker.dart';
import 'package:aa_doudizhu/domain/game_logic/game_state.dart';

class RoomScreen extends StatefulWidget {
  const RoomScreen({Key? key}) : super(key: key);

  @override
  _RoomScreenState createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  late List<CardModel> hand;
  final Set<int> _selected = {};

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
    final selectedCards = playing.map((i) => hand[i]).toList();
    final state = GameState(roomId: 'r', currentTurnPlayerId: 'p', hands: hand, deskCards: []);
    final ok = SimpleRuleChecker().isLegalPlay(selectedCards, state);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? '出牌合法' : '出牌不合法')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(title: const Text('房间 - 私人房（占位）')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          return Column(
            children: [
              // 顶部玩家行
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                color: Colors.black.withOpacity(0.2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(4, (idx) => _playerAvatar("玩家${idx+1}")),
                ),
              ),
              // 中部牌桌占位
              Expanded(
                child: Center(
                  child: Container(
                    width: width * 0.75,
                    height: 320,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Center(child: Text('牌桌占位 - 实际牌桌实现待后续阶段', style: TextStyle(color: Colors.white70))),
                  ),
                ),
              ),
              // 底部自己的手牌与操作区
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  children: [
                    CardDeck(
                      cards: hand,
                      selectedIndices: _selected,
                      onCardTap: _toggleSelect,
                      cardWidth: 74,
                      cardHeight: 100,
                      spacing: 8,
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(onPressed: _handlePlay, child: const Text('出牌')),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _playerAvatar(String name) {
    return Column(
      children: [
        CircleAvatar(radius: 22, backgroundColor: Colors.grey[800]),
        const SizedBox(height: 6),
        Text(name, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }
}

class RoomScreen extends StatelessWidget {
  const RoomScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('房间')),
      body: Center(child: Text('房间界面占位')),
    );
  }
}
