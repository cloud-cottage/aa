import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aa_doudizhu/domain/game_logic/game_engine.dart';
import 'package:aa_doudizhu/domain/game_logic/game_state.dart';
import 'package:aa_doudizhu/domain/game_logic/card.dart';
import 'package:aa_doudizhu/domain/game_logic/card_type.dart';
import 'package:aa_doudizhu/domain/game_logic/nft_effects.dart';
import 'package:aa_doudizhu/domain/game_logic/ai.dart';
import 'package:aa_doudizhu/data/models/user.dart';
import 'package:aa_doudizhu/data/models/nft_card.dart';
import 'package:aa_doudizhu/data/services/user_database.dart';
import 'package:aa_doudizhu/presentation/widgets/card_widget.dart';
import 'package:aa_doudizhu/core/theme.dart';

// 游戏状态提供者
final gameStateProvider = StateProvider<GameState?>((ref) => null);
final currentPlayerProvider = StateProvider<String?>((ref) => 'user_001');

class GameScreen extends ConsumerStatefulWidget {
  final String roomId;
  
  const GameScreen({Key? key, required this.roomId}) : super(key: key);

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> with TickerProviderStateMixin {
  late GameEngine _gameEngine;
  late AnimationController _cardAnimationController;
  late AnimationController _effectAnimationController;
  late Animation<double> _cardSlideAnimation;
  late Animation<double> _effectPulseAnimation;
  
  final Set<int> _selectedCards = {};
  List<String> _activeEffects = [];
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _gameEngine = GameEngine();
    _gameEngine.initialize();
    
    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _effectAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _cardSlideAnimation = CurvedAnimation(
      parent: _cardAnimationController,
      curve: Curves.easeInOut,
    );
    
    _effectPulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _effectAnimationController,
      curve: Curves.easeInOut,
    ));
    
    _initializeGame();
  }

  void _initializeGame() {
    // 初始化用户数据库
    UserDatabase().initialize();
    
    // 创建示例游戏状态
    final gameState = _createSampleGameState();
    ref.read(gameStateProvider.notifier).state = gameState;
    
    // 为游戏分配随机用户身份
    _gameEngine.assignUserIdentitiesToGame(widget.roomId);
  }

  GameState _createSampleGameState() {
    // 获取随机用户身份
    final userDatabase = UserDatabase();
    final randomUsers = userDatabase.getRandomUsers(3);
    
    // 创建示例NFT
    final nft = NFTEffectManager.createBombDoublerNFT(
      tokenId: 'nft_001',
      contractAddress: '0x123...',
      ownerAddress: '0xabc...',
    );

    // 创建玩家状态
    final players = <String, PlayerState>{
      'user_001': PlayerState(
        userId: 'user_001',
        user: randomUsers[0], // 使用随机用户
        handCards: _generateSampleHand(),
        role: PlayerRole.landlord,
        isAI: false,
        activeNFTs: [nft],
      ),
      'bot_001': PlayerState(
        userId: 'bot_001',
        user: randomUsers[1], // AI也使用随机用户身份（可选）
        handCards: _generateSampleHand(),
        role: PlayerRole.farmer,
        isAI: true,
      ),
      'bot_002': PlayerState(
        userId: 'bot_002',
        user: randomUsers[2], // AI也使用随机用户身份（可选）
        handCards: _generateSampleHand(),
        role: PlayerRole.farmer,
        isAI: true,
      ),
    };

    return GameState(
      roomId: widget.roomId,
      currentPhase: GamePhase.playing,
      players: players,
      currentTurnPlayerId: 'user_001',
      totalMultiplier: 1,
      landlordPlayerId: 'user_001',
      startedAt: DateTime.now(),
    );
  }

  List<CardModel> _generateSampleHand() {
    final cards = <CardModel>[];
    int id = 0;
    
    // 生成示例手牌
    final ranks = [Rank.three, Rank.four, Rank.five, Rank.six, Rank.seven, Rank.eight];
    final suits = [Suit.clubs, Suit.diamonds, Suit.hearts, Suit.spades];
    
    for (int i = 0; i < 10; i++) {
      cards.add(CardModel(
        suit: suits[i % suits.length],
        rank: ranks[i % ranks.length],
        id: id++,
      ));
    }
    
    return cards;
  }

  @override
  void dispose() {
    _cardAnimationController.dispose();
    _effectAnimationController.dispose();
    super.dispose();
  }

  void _toggleCardSelection(int cardIndex) {
    setState(() {
      if (_selectedCards.contains(cardIndex)) {
        _selectedCards.remove(cardIndex);
      } else {
        _selectedCards.add(cardIndex);
      }
    });
    
    _cardAnimationController.forward(from: 0);
  }

  Future<void> _handlePlay() async {
    if (_isProcessing) return;
    
    final gameState = ref.read(gameStateProvider);
    if (gameState == null) return;
    
    final currentPlayer = gameState.getCurrentPlayer();
    if (currentPlayer == null || currentPlayer.isAI) return;
    
    final selectedCardModels = _selectedCards
        .map((index) => currentPlayer.handCards[index])
        .toList();
    
    if (selectedCardModels.isEmpty) {
      _showMessage('请选择要出的牌', Colors.orange);
      return;
    }

    setState(() => _isProcessing = true);
    
    try {
      final result = _gameEngine.processAction(
        widget.roomId,
        GameActionRequest(
          action: GameAction.play,
          playerId: currentPlayer.userId,
          cards: selectedCardModels,
        ),
      );

      if (result.success && result.updatedState != null) {
        ref.read(gameStateProvider.notifier).state = result.updatedState;
        
        // 显示NFT效果
        final effects = result.metadata['nftEffects'] as List<String>? ?? [];
        if (effects.isNotEmpty) {
          _showNFTEffects(effects);
        }
        
        _selectedCards.clear();
        _showMessage('出牌成功！', Colors.green);
        
        // AI自动响应
        _triggerAITurn();
      } else {
        _showMessage(result.errorMessage ?? '出牌失败', Colors.red);
      }
    } catch (e) {
      _showMessage('游戏错误: $e', Colors.red);
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _handlePass() async {
    if (_isProcessing) return;
    
    final gameState = ref.read(gameStateProvider);
    if (gameState == null) return;
    
    final currentPlayer = gameState.getCurrentPlayer();
    if (currentPlayer == null || currentPlayer.isAI) return;
    
    if (gameState.lastPlay.isEmpty) {
      _showMessage('您领头，不能过牌', Colors.orange);
      return;
    }

    setState(() => _isProcessing = true);
    
    try {
      final result = _gameEngine.processAction(
        widget.roomId,
        GameActionRequest(
          action: GameAction.pass,
          playerId: currentPlayer.userId,
        ),
      );

      if (result.success && result.updatedState != null) {
        ref.read(gameStateProvider.notifier).state = result.updatedState;
        _selectedCards.clear();
        _showMessage('过牌', Colors.blue);
        
        // AI自动响应
        _triggerAITurn();
      } else {
        _showMessage(result.errorMessage ?? '过牌失败', Colors.red);
      }
    } catch (e) {
      _showMessage('游戏错误: $e', Colors.red);
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _triggerAITurn() {
    Future.delayed(const Duration(milliseconds: 1000), () {
      final gameState = ref.read(gameStateProvider);
      if (gameState == null) return;
      
      final currentPlayer = gameState.getCurrentPlayer();
      if (currentPlayer?.isAI == true) {
        _makeAIMove();
      }
    });
  }

  void _makeAIMove() {
    final gameState = ref.read(gameStateProvider);
    if (gameState == null) return;
    
    final currentPlayer = gameState.getCurrentPlayer();
    if (currentPlayer == null || !currentPlayer.isAI) return;
    
    final ai = AIManager.getAI(currentPlayer.userId, AIDifficulty.medium);
    final hand = currentPlayer.handCards;
    
    List<CardModel> chosenPlay;
    if (gameState.lastPlay.isEmpty) {
      chosenPlay = ai.choosePlay(gameState, hand);
    } else {
      chosenPlay = ai.choosePlay(gameState, hand);
      // 检查是否能压过上家
      if (chosenPlay.isNotEmpty) {
        final result = _gameEngine.processAction(
          widget.roomId,
          GameActionRequest(
            action: GameAction.play,
            playerId: currentPlayer.userId,
            cards: chosenPlay,
          ),
        );
        if (!result.success) {
          chosenPlay = [];
        }
      }
    }

    if (chosenPlay.isNotEmpty) {
      // AI出牌
      final result = _gameEngine.processAction(
        widget.roomId,
        GameActionRequest(
          action: GameAction.play,
          playerId: currentPlayer.userId,
          cards: chosenPlay,
        ),
      );
      
      if (result.success && result.updatedState != null) {
        ref.read(gameStateProvider.notifier).state = result.updatedState;
        _showMessage('${ai.getAIName()} 出牌', Colors.blue);
        
        // 继续下一个AI回合
        _triggerAITurn();
      }
    } else {
      // AI过牌
      final result = _gameEngine.processAction(
        widget.roomId,
        GameActionRequest(
          action: GameAction.pass,
          playerId: currentPlayer.userId,
        ),
      );
      
      if (result.success && result.updatedState != null) {
        ref.read(gameStateProvider.notifier).state = result.updatedState;
        _showMessage('${ai.getAIName()} 过牌', Colors.blue);
        
        // 继续下一个AI回合
        _triggerAITurn();
      }
    }
  }

  void _showNFTEffects(List<String> effects) {
    setState(() => _activeEffects = effects);
    _effectAnimationController.repeat(reverse: true);
    
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _activeEffects.clear());
        _effectAnimationController.stop();
        _effectAnimationController.reset();
      }
    });
  }

  void _showMessage(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameStateProvider);
    final currentPlayerId = ref.watch(currentPlayerProvider);
    
    return Scaffold(
      backgroundColor: kBackground,
      body: gameState == null 
        ? const Center(child: CircularProgressIndicator())
        : _buildGameContent(gameState, currentPlayerId),
    );
  }

  Widget _buildGameContent(GameState gameState, String? currentPlayerId) {
    final currentPlayer = gameState.players[currentPlayerId ?? ''];
    final isMyTurn = gameState.currentTurnPlayerId == currentPlayerId;
    
    return Column(
      children: [
        // 顶部信息栏
        _buildTopBar(gameState),
        
        // 对手区域
        Expanded(
          flex: 2,
          child: _buildOpponentsArea(gameState),
        ),
        
        // 游戏桌面
        Expanded(
          flex: 3,
          child: _buildGameTable(gameState),
        ),
        
        // 玩家手牌区域
        Expanded(
          flex: 2,
          child: _buildPlayerHandArea(currentPlayer, isMyTurn),
        ),
      ],
    );
  }

  Widget _buildTopBar(GameState gameState) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: kSurface.withOpacity(0.8),
        border: Border(bottom: BorderSide(color: kGold.withOpacity(0.3))),
      ),
      child: Row(
        children: [
          // 房间信息
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: kGold.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: kGold.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.casino, color: kGold, size: 16),
                const SizedBox(width: 4),
                Text(
                  '房间 ${gameState.roomId}',
                  style: TextStyle(color: kGold, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          
          const Spacer(),
          
          // 倍数信息
          _buildInfoChip('倍数', '${gameState.totalMultiplier}x', kGold),
          
          const SizedBox(width: 12),
          
          // 游戏阶段
          _buildInfoChip(
            _getPhaseText(gameState.currentPhase),
            '',
            _getPhaseColor(gameState.currentPhase),
          ),
          
          const SizedBox(width: 12),
          
          // NFT效果
          if (_activeEffects.isNotEmpty)
            AnimatedBuilder(
              animation: _effectPulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _effectPulseAnimation.value,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.purple.withOpacity(0.5)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.auto_awesome, color: Colors.purple, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          _activeEffects.first,
                          style: TextStyle(color: Colors.purple, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label, String value, Color color) {
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
          Text(label, style: TextStyle(color: Colors.white70, fontSize: 12)),
          if (value.isNotEmpty) ...[
            const SizedBox(width: 4),
            Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
          ],
        ],
      ),
    );
  }

  Widget _buildOpponentsArea(GameState gameState) {
    final opponents = gameState.players.values
        .where((p) => p.userId != ref.read(currentPlayerProvider))
        .toList();
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: opponents.map((opponent) => _buildOpponentAvatar(opponent, gameState)).toList(),
      ),
    );
  }

  Widget _buildOpponentAvatar(PlayerState opponent, GameState gameState) {
    final isCurrentTurn = gameState.currentTurnPlayerId == opponent.userId;
    final cardCount = opponent.handCards.length;
    
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCurrentTurn ? kGold : kSurface,
                border: Border.all(
                  color: isCurrentTurn ? kGold : Colors.white24,
                  width: 2,
                ),
                boxShadow: isCurrentTurn ? [
                  BoxShadow(color: kGold.withOpacity(0.4), blurRadius: 12),
                ] : null,
              ),
              child: ClipOval(
                child: opponent.user?.avatarPath != null
                  ? Image.asset(
                      opponent.user!.avatarPath!,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isCurrentTurn ? kGold : kSurface,
                          ),
                          child: Center(
                            child: Icon(
                              opponent.isAI ? Icons.smart_toy : Icons.person,
                              color: isCurrentTurn ? kBackground : Colors.white70,
                              size: 24,
                            ),
                          ),
                        );
                      },
                    )
                  : Center(
                      child: Icon(
                        opponent.isAI ? Icons.smart_toy : Icons.person,
                        color: isCurrentTurn ? kBackground : Colors.white70,
                        size: 24,
                      ),
                    ),
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
        const SizedBox(height: 8),
        Text(
          opponent.isAI 
            ? AIManager.getAI(opponent.userId, AIDifficulty.medium).getAIName() 
            : (opponent.user?.displayName ?? '玩家'),
          style: TextStyle(
            color: isCurrentTurn ? kGold : Colors.white70,
            fontSize: 12,
            fontWeight: isCurrentTurn ? FontWeight.bold : FontWeight.normal,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '$cardCount张',
            style: TextStyle(color: Colors.white54, fontSize: 10),
          ),
        ),
        if (opponent.activeNFTs.isNotEmpty) ...[
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: opponent.activeNFTs.take(2).map((nft) {
              return Container(
                margin: const EdgeInsets.only(right: 2),
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.3),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.purple),
                ),
                child: Center(
                  child: Icon(Icons.auto_awesome, color: Colors.purple, size: 8),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildGameTable(GameState gameState) {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 最后出牌
          if (gameState.lastPlay.isNotEmpty) ...[
            Text(
              '上家出牌',
              style: TextStyle(color: Colors.white54, fontSize: 14),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: gameState.lastPlay.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: CardWidget(
                      card: gameState.lastPlay[index],
                      width: 50,
                      height: 70,
                      isSelectable: false,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          // 游戏信息
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTableInfo('底牌', '${gameState.deskCards.length}张'),
              const SizedBox(width: 20),
              _buildTableInfo('倍数', '${gameState.totalMultiplier}x'),
              const SizedBox(width: 20),
              _buildTableInfo('回合', '${gameState.playHistory.length}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTableInfo(String label, String value) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: Colors.white54, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: kGold, fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildPlayerHandArea(PlayerState? currentPlayer, bool isMyTurn) {
    if (currentPlayer == null) {
      return const Center(child: Text('玩家信息不存在', style: TextStyle(color: Colors.white54)));
    }
    
    return Container(
      decoration: BoxDecoration(
        color: kSurface.withOpacity(0.8),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // 玩家信息
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // 玩家头像
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isMyTurn ? kGold : kSurface,
                    border: Border.all(color: isMyTurn ? kGold : Colors.white24, width: 2),
                  ),
                  child: ClipOval(
                    child: currentPlayer?.user?.avatarPath != null
                      ? Image.asset(
                          currentPlayer!.user!.avatarPath!,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isMyTurn ? kGold : kSurface,
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.person,
                                  color: isMyTurn ? kBackground : Colors.white70,
                                  size: 20,
                                ),
                              ),
                            );
                          },
                        )
                      : Center(
                          child: Icon(
                            Icons.person,
                            color: isMyTurn ? kBackground : Colors.white70,
                            size: 20,
                          ),
                        ),
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // 玩家信息
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentPlayer?.user?.displayName ?? '玩家',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            '手牌: ${currentPlayer?.handCards.length}张',
                            style: TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                          if (_selectedCards.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: kGold.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '已选${_selectedCards.length}张',
                                style: TextStyle(color: kGold, fontSize: 10),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                
                // 状态指示
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isMyTurn ? kGold.withOpacity(0.2) : Colors.white10,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isMyTurn ? kGold : Colors.white24),
                  ),
                  child: Text(
                    isMyTurn ? '您的回合' : '等待中',
                    style: TextStyle(
                      color: isMyTurn ? kGold : Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // 手牌区域
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: currentPlayer.handCards.isEmpty
                ? Center(
                    child: Text(
                      '没有手牌',
                      style: TextStyle(color: Colors.white54, fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: currentPlayer.handCards.length,
                    itemBuilder: (context, index) {
                      final card = currentPlayer.handCards[index];
                      final isSelected = _selectedCards.contains(index);
                      
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        transform: Matrix4.translationValues(0, isSelected ? -10 : 0, 0),
                        child: GestureDetector(
                          onTap: isMyTurn && !_isProcessing 
                            ? () => _toggleCardSelection(index)
                            : null,
                          child: CardWidget(
                            card: card,
                            width: 60,
                            height: 84,
                            isSelectable: isMyTurn,
                            isSelected: isSelected,
                          ),
                        ),
                      );
                    },
                  ),
            ),
          ),
          
          // 操作按钮
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // 过牌按钮
                if (!isMyTurn || gameState.lastPlay.isEmpty)
                  Expanded(
                    child: Container(),
                  )
                else
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isProcessing ? null : _handlePass,
                      icon: const Icon(Icons.skip_next),
                      label: const Text('过牌'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kSurface,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                
                const SizedBox(width: 12),
                
                // 出牌按钮
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: (!isMyTurn || _isProcessing || _selectedCards.isEmpty)
                      ? null 
                      : _handlePlay,
                    icon: const Icon(Icons.arrow_upward),
                    label: Text(_isProcessing ? '处理中...' : '出牌'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isMyTurn ? kGold : Colors.grey,
                      foregroundColor: kBackground,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // 清除选择按钮
                ElevatedButton.icon(
                  onPressed: _selectedCards.isEmpty || _isProcessing
                    ? null
                    : () {
                        setState(() => _selectedCards.clear());
                      },
                  icon: const Icon(Icons.clear),
                  label: const Text('清除'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.withOpacity(0.2),
                    foregroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getPhaseText(GamePhase phase) {
    switch (phase) {
      case GamePhase.waiting:
        return '等待';
      case GamePhase.dealing:
        return '发牌';
      case GamePhase.bidding:
        return '叫地主';
      case GamePhase.playing:
        return '游戏中';
      case GamePhase.scoring:
        return '结算';
      case GamePhase.finished:
        return '结束';
    }
  }

  Color _getPhaseColor(GamePhase phase) {
    switch (phase) {
      case GamePhase.waiting:
        return Colors.grey;
      case GamePhase.dealing:
        return Colors.blue;
      case GamePhase.bidding:
        return Colors.orange;
      case GamePhase.playing:
        return Colors.green;
      case GamePhase.scoring:
        return Colors.purple;
      case GamePhase.finished:
        return Colors.red;
    }
  }
}
