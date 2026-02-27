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

class _RoomScreenState extends State<RoomScreen> with SingleTickerProviderStateMixin {
  late List<CardModel> hand;
  final Set<int> _selected = {};
  String _currentPlayer = '玩家1';
  final List<String> _players = ['玩家1', '玩家2', '玩家3', '玩家4'];
  bool _isReady = false;
  bool _gameStarted = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    hand = _demoHand();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
    if (!_gameStarted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先准备游戏')),
      );
      return;
    }
    final selectedCards = playing.map((i) => hand[i]).toList();
    final state = GameState(roomId: 'r', currentTurnPlayerId: _currentPlayer, hands: hand, deskCards: []);
    final ok = SimpleRuleChecker().isLegalPlay(selectedCards, state);
    
    _animationController.forward(from: 0);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? '出牌成功!' : '出牌不合法'),
        backgroundColor: ok ? Colors.green : Colors.red,
      ),
    );
    
    if (ok) {
      setState(() {
        for (var idx in playing.reversed) {
          if (idx < hand.length) {
            hand.removeAt(idx);
          }
        }
        _selected.clear();
        _nextPlayer();
      });
    }
  }

  void _nextPlayer() {
    final currentIdx = _players.indexOf(_currentPlayer);
    final nextIdx = (currentIdx + 1) % _players.length;
    setState(() {
      _currentPlayer = _players[nextIdx];
    });
  }

  void _handleReady() {
    setState(() {
      _isReady = !_isReady;
      if (_isReady) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
    
    final readyCount = _players.where((p) => p == _currentPlayer).length + 1;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isReady ? '已准备' : '已取消准备'),
        backgroundColor: _isReady ? Colors.green : Colors.orange,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _startGame() {
    setState(() {
      _gameStarted = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('游戏开始!'),
        backgroundColor: kGold,
        duration: Duration(seconds: 2),
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
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: _gameStarted ? Colors.green.withOpacity(0.2) : Colors.orange.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _gameStarted ? Colors.green : Colors.orange, width: 1),
            ),
            child: Text(
              _gameStarted ? '游戏中' : '等待中',
              style: TextStyle(
                color: _gameStarted ? Colors.green : Colors.orange,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
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
                  final isCurrentTurn = name == _currentPlayer && _gameStarted;
                  return _playerAvatar(name, isCurrentTurn, idx == 0);
                }).toList(),
              ),
            ),
            // Center: Table area
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnimation,
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
                          Icon(
                            _gameStarted ? Icons.style : Icons.table_restaurant,
                            size: 48,
                            color: _gameStarted ? kGold : Colors.white12,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _gameStarted ? '游戏中' : '等待开始...',
                            style: TextStyle(
                              color: _gameStarted ? Colors.white : Colors.white38,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _infoChip('底分', '1', kGold),
                              const SizedBox(width: 12),
                              _infoChip('玩家', '${_players.length}/4', Colors.white54),
                            ],
                          ),
                          if (!_gameStarted) ...[
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              onPressed: _startGame,
                              icon: const Icon(Icons.play_arrow),
                              label: const Text('开始游戏'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              ),
                            ),
                          ],
                        ],
                      ),
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
                        Row(
                          children: [
                            Text('手牌 (${hand.length}张)', style: TextStyle(color: Colors.white70, fontSize: 14)),
                            if (_selected.isNotEmpty)
                              Container(
                                margin: const EdgeInsets.only(left: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: kGold.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '已选 ${_selected.length}张',
                                  style: TextStyle(color: kGold, fontSize: 12),
                                ),
                              ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: (_currentPlayer == '玩家1' && _gameStarted) 
                              ? kGold.withOpacity(0.2) 
                              : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '当前: $_currentPlayer',
                            style: TextStyle(
                              color: (_currentPlayer == '玩家1' && _gameStarted) 
                                ? kGold 
                                : Colors.white54,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 100,
                      child: hand.isEmpty
                        ? Center(
                            child: Text(
                              '游戏结束!',
                              style: TextStyle(color: kGold, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          )
                        : CardDeck(
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
                            onPressed: hand.isEmpty ? null : _handlePlay,
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
                          onPressed: hand.isEmpty ? null : () {
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
                          onPressed: hand.isEmpty ? null : () {
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
                    if (!_gameStarted) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _handleReady,
                          icon: Icon(_isReady ? Icons.check_circle : Icons.radio_button_unchecked),
                          label: Text(_isReady ? '已准备' : '准备'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _isReady ? Colors.green : Colors.white54,
                            side: BorderSide(color: _isReady ? Colors.green : Colors.white24),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: TextStyle(color: Colors.white54, fontSize: 12)),
          const SizedBox(width: 4),
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _playerAvatar(String name, bool isCurrentTurn, bool isHost) {
    return Column(
      children: [
        Stack(
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
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            if (isHost)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: kGold,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.star, size: 10, color: kBackground),
                ),
              ),
            if (isCurrentTurn)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
                  ),
                ),
              ),
          ],
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
        if (isCurrentTurn)
          Container(
            margin: const EdgeInsets.only(top: 2),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              color: kGold.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '出牌',
              style: TextStyle(color: kGold, fontSize: 9),
            ),
          ),
      ],
    );
  }
}
