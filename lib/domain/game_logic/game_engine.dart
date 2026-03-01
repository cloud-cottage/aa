import 'package:aa_doudizhu/domain/game_logic/card.dart';
import 'package:aa_doudizhu/domain/game_logic/game_state.dart';
import 'package:aa_doudizhu/domain/game_logic/rule_checker.dart';
import 'package:aa_doudizhu/domain/game_logic/ai.dart';
import 'package:aa_doudizhu/domain/game_logic/nft_effects.dart';
import 'package:aa_doudizhu/domain/game_logic/room_manager.dart';
import 'package:aa_doudizhu/data/models/user.dart';
import 'package:aa_doudizhu/data/models/nft_card.dart';
import 'package:aa_doudizhu/data/services/user_database.dart';
import 'dart:math';

enum GameAction { play, pass, bid, skipBid }

class GameActionRequest {
  final GameAction action;
  final String playerId;
  final List<CardModel> cards;
  final Map<String, dynamic> metadata;

  GameActionRequest({
    required this.action,
    required this.playerId,
    this.cards = const [],
    this.metadata = const {},
  });
}

class GameActionResult {
  final bool success;
  final String? errorMessage;
  final GameState? updatedState;
  final Map<String, dynamic> metadata;

  GameActionResult({
    required this.success,
    this.errorMessage,
    this.updatedState,
    this.metadata = const {},
  });
}

class GameEngine {
  static final GameEngine _instance = GameEngine._internal();
  factory GameEngine() => _instance;
  GameEngine._internal();

  final RoomManager _roomManager = RoomManager();
  final SimpleRuleChecker _ruleChecker = SimpleRuleChecker();
  final Random _random = Random();

  // 初始化
  void initialize() {
    // 初始化用户数据库
    UserDatabase().initialize();
    
    // 监听房间事件
    _roomManager.eventStream.listen(_handleRoomEvent);
  }

  // 处理房间事件
  void _handleRoomEvent(RoomEventInfo event) {
    switch (event.type) {
      case RoomEvent.gameStarted:
        _initializeGame(event.roomId);
        break;
      case RoomEvent.aiReplacedPlayer:
        _handleAIReplacement(event.roomId, event.playerId!);
        break;
      default:
        break;
    }
  }

  // 初始化游戏
  void _initializeGame(String roomId) {
    final gameState = _roomManager.getGameState(roomId);
    if (gameState == null) return;

    // 创建牌组
    final deck = _createDeck();
    
    // 洗牌
    final shuffledDeck = List<CardModel>.from(deck)..shuffle(_random);
    
    // 发牌
    final hands = _dealCards(shuffledDeck, gameState.players.keys.toList());
    
    // 更新玩家手牌
    final updatedPlayers = <String, PlayerState>{};
    for (final entry in gameState.players.entries) {
      final playerId = entry.key;
      final playerState = entry.value;
      updatedPlayers[playerId] = playerState.copyWith(
        handCards: hands[playerId] ?? [],
      );
    }

    // 留3张底牌
    final deskCards = shuffledDeck.takeLast(3).toList();

    // 更新游戏状态
    final updatedState = gameState.copyWith(
      players: updatedPlayers,
      deskCards: deskCards,
      currentPhase: GamePhase.bidding,
      startedAt: DateTime.now(),
    );

    _roomManager.gameStates[roomId] = updatedState;
  }

  // 创建标准牌组
  List<CardModel> _createDeck() {
    final deck = <CardModel>[];
    int cardId = 0;

    // 普通牌
    for (final suit in Suit.values) {
      for (final rank in Rank.values) {
        if (rank != Rank.smallJoker && rank != Rank.bigJoker) {
          deck.add(CardModel(
            suit: suit,
            rank: rank,
            id: cardId++,
          ));
        }
      }
    }

    // 大小王
    deck.add(CardModel(
      suit: Suit.clubs, // 王没有花色，随便选一个
      rank: Rank.smallJoker,
      id: cardId++,
    ));

    deck.add(CardModel(
      suit: Suit.clubs,
      rank: Rank.bigJoker,
      id: cardId++,
    ));

    return deck;
  }

  // 发牌
  Map<String, List<CardModel>> _dealCards(List<CardModel> deck, List<String> playerIds) {
    final hands = <String, List<CardModel>>{};
    
    // 每人17张牌，留3张底牌
    final cardsPerPlayer = 17;
    
    for (int i = 0; i < playerIds.length; i++) {
      final start = i * cardsPerPlayer;
      final end = start + cardsPerPlayer;
      hands[playerIds[i]] = deck.sublist(start, end);
    }

    return hands;
  }

  // 处理游戏动作
  GameActionResult processAction(String roomId, GameActionRequest request) {
    final gameState = _roomManager.getGameState(roomId);
    if (gameState == null) {
      return GameActionResult(
        success: false,
        errorMessage: 'Game not found',
      );
    }

    // 验证玩家
    if (gameState.currentTurnPlayerId != request.playerId) {
      return GameActionResult(
        success: false,
        errorMessage: 'Not your turn',
      );
    }

    switch (request.action) {
      case GameAction.play:
        return _handlePlayAction(gameState, request);
      case GameAction.pass:
        return _handlePassAction(gameState, request);
      case GameAction.bid:
        return _handleBidAction(gameState, request);
      case GameAction.skipBid:
        return _handleSkipBidAction(gameState, request);
    }
  }

  // 处理出牌动作
  GameActionResult _handlePlayAction(GameState gameState, GameActionRequest request) {
    final player = gameState.getCurrentPlayer();
    if (player == null) {
      return GameActionResult(
        success: false,
        errorMessage: 'Player not found',
      );
    }

    // 验证手牌
    if (!_playerHasCards(player, request.cards)) {
      return GameActionResult(
        success: false,
        errorMessage: 'Invalid cards: not in hand',
      );
    }

    // 验证出牌合法性
    if (!_ruleChecker.isLegalPlay(request.cards, gameState)) {
      return GameActionResult(
        success: false,
        errorMessage: 'Invalid play',
      );
    }

    // 验证是否能压过上家
    if (gameState.lastPlay.isNotEmpty && 
        !_ruleChecker.canBeat(request.cards, gameState.lastPlay, gameState)) {
      return GameActionResult(
        success: false,
        errorMessage: 'Cannot beat last play',
      );
    }

    // 计算倍数
    final multiplier = _ruleChecker.calculateTotalMultiplier(request.cards, gameState);
    final nftEffects = gameState.getActiveNFTEffects(request.playerId, request.cards);

    // 更新玩家手牌
    final updatedHand = List<CardModel>.from(player.handCards)
      ..where((card) => !request.cards.contains(card)).toList();

    final updatedPlayer = player.copyWith(handCards: updatedHand);
    final updatedPlayers = Map<String, PlayerState>.from(gameState.players)
      ..[request.playerId] = updatedPlayer;

    // 创建出牌记录
    final playRecord = PlayRecord(
      playerId: request.playerId,
      cards: request.cards,
      timestamp: DateTime.now(),
      multiplierContribution: multiplier,
    );

    // 更新游戏状态
    final updatedState = gameState.copyWith(
      players: updatedPlayers,
      lastPlay: request.cards,
      lastPlayPlayerId: request.playerId,
      totalMultiplier: gameState.totalMultiplier * multiplier,
      playHistory: [...gameState.playHistory, playRecord],
    );

    // 检查游戏是否结束
    if (updatedHand.isEmpty) {
      return _handleGameEnd(updatedState, request.playerId);
    }

    // 切换到下一个玩家
    final nextPlayerId = _getNextPlayerId(updatedState, request.playerId);
    final finalState = updatedState.copyWith(
      currentTurnPlayerId: nextPlayerId,
    );

    _roomManager._gameStates[gameState.roomId] = finalState;

    return GameActionResult(
      success: true,
      updatedState: finalState,
      metadata: {
        'multiplier': multiplier,
        'nftEffects': nftEffects,
        'nextPlayer': nextPlayerId,
      },
    );
  }

  // 处理过牌动作
  GameActionResult _handlePassAction(GameState gameState, GameActionRequest request) {
    // 如果是自由出牌（上家没出牌），不能过牌
    if (gameState.lastPlay.isEmpty) {
      return GameActionResult(
        success: false,
        errorMessage: 'Cannot pass when free play',
      );
    }

    // 切换到下一个玩家
    final nextPlayerId = _getNextPlayerId(gameState, request.playerId);
    
    // 如果回到出牌的玩家，清空桌面
    final newLastPlay = (nextPlayerId == gameState.lastPlayPlayerId) 
        ? <CardModel>[] 
        : gameState.lastPlay;

    final updatedState = gameState.copyWith(
      currentTurnPlayerId: nextPlayerId,
      lastPlay: newLastPlay,
      lastPlayPlayerId: newLastPlay.isEmpty ? null : gameState.lastPlayPlayerId,
    );

    _roomManager._gameStates[gameState.roomId] = updatedState;

    return GameActionResult(
      success: true,
      updatedState: updatedState,
      metadata: {'nextPlayer': nextPlayerId},
    );
  }

  // 处理叫地主动作
  GameActionResult _handleBidAction(GameState gameState, GameActionRequest request) {
    if (gameState.currentPhase != GamePhase.bidding) {
      return GameActionResult(
        success: false,
        errorMessage: 'Not in bidding phase',
      );
    }

    // 设置地主
    final updatedPlayers = Map<String, PlayerState>.from(gameState.players);
    for (final entry in updatedPlayers.entries) {
      if (entry.key == request.playerId) {
        updatedPlayers[entry.key] = entry.value.copyWith(
          role: PlayerRole.landlord,
        );
      } else {
        updatedPlayers[entry.key] = entry.value.copyWith(
          role: PlayerRole.farmer,
        );
      }
    }

    // 地主获得底牌
    final landlordPlayer = updatedPlayers[request.playerId];
    final updatedLandlordCards = [...landlordPlayer.handCards, ...gameState.deskCards];
    updatedPlayers[request.playerId] = landlordPlayer.copyWith(
      handCards: updatedLandlordCards,
    );

    final updatedState = gameState.copyWith(
      players: updatedPlayers,
      landlordPlayerId: request.playerId,
      currentPhase: GamePhase.playing,
      currentTurnPlayerId: request.playerId,
      deskCards: [], // 底牌已发给地主
    );

    _roomManager._gameStates[gameState.roomId] = updatedState;

    return GameActionResult(
      success: true,
      updatedState: updatedState,
      metadata: {'landlord': request.playerId},
    );
  }

  // 处理不叫动作
  GameActionResult _handleSkipBidAction(GameState gameState, GameActionRequest request) {
    // 简化版本：跳过叫地主，随机选择一个地主
    final players = gameState.players.keys.toList();
    final landlordId = players[_random.nextInt(players.length)];
    
    return _handleBidAction(gameState, GameActionRequest(
      action: GameAction.bid,
      playerId: landlordId,
    ));
  }

  // 处理游戏结束
  GameActionResult _handleGameEnd(GameState gameState, String winnerId) {
    final updatedState = gameState.copyWith(
      currentPhase: GamePhase.finished,
      finishedAt: DateTime.now(),
    );

    _roomManager._gameStates[gameState.roomId] = updatedState;
    _roomManager.finishGame(gameState.roomId);

    // 计算得分
    final scores = _calculateScores(updatedState);

    return GameActionResult(
      success: true,
      updatedState: updatedState,
      metadata: {
        'winner': winnerId,
        'scores': scores,
      },
    );
  }

  // 处理AI替换
  void _handleAIReplacement(String roomId, String originalPlayerId) {
    final gameState = _roomManager.getGameState(roomId);
    if (gameState == null) return;

    // 如果当前轮到被替换的玩家，让AI自动出牌
    if (gameState.currentTurnPlayerId == originalPlayerId) {
      final aiPlayerId = AIManager.generateAIPlayerId(originalPlayerId);
      _makeAIMove(roomId, aiPlayerId);
    }
  }

  // AI自动出牌
  void _makeAIMove(String roomId, String aiPlayerId) {
    final gameState = _roomManager.getGameState(roomId);
    if (gameState == null) return;

    final player = gameState.players[aiPlayerId];
    if (player == null || !player.isAI) return;

    final ai = AIManager.getAI(aiPlayerId, AIDifficulty.medium);
    final hand = player.handCards;

    List<CardModel> chosenPlay;
    if (gameState.lastPlay.isEmpty) {
      chosenPlay = ai.choosePlay(gameState, hand);
    } else {
      chosenPlay = ai.choosePlay(gameState, hand);
      if (chosenPlay.isEmpty || 
          !_ruleChecker.canBeat(chosenPlay, gameState.lastPlay, gameState)) {
        // AI选择过牌
        processAction(roomId, GameActionRequest(
          action: GameAction.pass,
          playerId: aiPlayerId,
        ));
        return;
      }
    }

    if (chosenPlay.isNotEmpty) {
      processAction(roomId, GameActionRequest(
        action: GameAction.play,
        playerId: aiPlayerId,
        cards: chosenPlay,
      ));
    }
  }

  // 验证玩家是否拥有这些牌
  bool _playerHasCards(PlayerState player, List<CardModel> cards) {
    final playerCardIds = player.handCards.map((c) => c.id).toSet();
    final requestedCardIds = cards.map((c) => c.id).toSet();
    return playerCardIds.containsAll(requestedCardIds);
  }

  // 获取下一个玩家ID
  String _getNextPlayerId(GameState gameState, String currentPlayerId) {
    final players = gameState.players.keys.toList();
    final currentIndex = players.indexOf(currentPlayerId);
    final nextIndex = (currentIndex + 1) % players.length;
    return players[nextIndex];
  }

  // 计算得分
  Map<String, int> _calculateScores(GameState gameState) {
    final scores = <String, int>{};
    final baseScore = 100;
    final totalMultiplier = gameState.totalMultiplier;

    // 找出获胜者
    String? winnerId;
    for (final player in gameState.players.values) {
      if (player.handCards.isEmpty) {
        winnerId = player.userId;
        break;
      }
    }

    if (winnerId == null) return scores;

    final winner = gameState.players[winnerId]!;
    final isLandlordWin = winner.role == PlayerRole.landlord;

    for (final player in gameState.players.values) {
      if (isLandlordWin) {
        // 地主获胜，农民输分
        if (player.role == PlayerRole.landlord) {
          scores[player.userId] = baseScore * totalMultiplier * 2;
        } else {
          scores[player.userId] = -baseScore * totalMultiplier;
        }
      } else {
        // 农民获胜，地主输分
        if (player.role == PlayerRole.landlord) {
          scores[player.userId] = -baseScore * totalMultiplier * 2;
        } else {
          scores[player.userId] = baseScore * totalMultiplier;
        }
      }
    }

    return scores;
  }

  // 获取房间管理器（用于测试）
  RoomManager get roomManager => _roomManager;

  // 获取随机用户身份（供外部调用）
  User getRandomUserIdentity() {
    return UserDatabase().selectPlayerIdentity();
  }

  // 获取多个随机用户身份
  List<User> getRandomUserIdentities(int count) {
    return UserDatabase().selectRoomPlayers(count);
  }

  // 为游戏分配随机用户身份
  void assignUserIdentitiesToGame(String roomId) {
    final gameState = _roomManager.getGameState(roomId);
    if (gameState == null) return;

    final userDatabase = UserDatabase();
    final updatedPlayers = <String, PlayerState>{};

    for (final entry in gameState.players.entries) {
      final playerId = entry.key;
      final playerState = entry.value;

      // 只为非AI玩家分配用户身份
      if (!playerState.isAI && playerState.user == null) {
        final randomUser = userDatabase.selectPlayerIdentity();
        
        // 为用户分配一些NFT（如果有的话）
        List<NFTCard> activeNFTs = [];
        if (randomUser.nftOwnedTokenIds.isNotEmpty) {
          activeNFTs = randomUser.nftOwnedTokenIds.take(2).map((tokenId) {
            return NFTEffectManager.createBombDoublerNFT(
              tokenId: tokenId,
              contractAddress: '0x${_generateHexString(40)}',
              ownerAddress: randomUser.walletAddress ?? '0x${_generateHexString(40)}',
            );
          }).toList();
        }

        updatedPlayers[playerId] = playerState.copyWith(
          user: randomUser,
          activeNFTs: activeNFTs,
        );
      } else {
        updatedPlayers[playerId] = playerState;
      }
    }

    // 更新游戏状态
    final updatedState = gameState.copyWith(players: updatedPlayers);
    _roomManager.gameStates[roomId] = updatedState;
  }

  String _generateHexString(int length) {
    final chars = '0123456789abcdef';
    String result = '';
    for (int i = 0; i < length; i++) {
      result += chars[_random.nextInt(chars.length)];
    }
    return result;
  }
}
