import 'package:flutter_test/flutter_test.dart';
import 'package:aa_doudizhu/domain/game_logic/card.dart';
import 'package:aa_doudizhu/domain/game_logic/game_state.dart';
import 'package:aa_doudizhu/domain/game_logic/card_type.dart';
import 'package:aa_doudizhu/domain/game_logic/rule_checker.dart';
import 'package:aa_doudizhu/domain/game_logic/nft_effects.dart';
import 'package:aa_doudizhu/domain/game_logic/ai.dart';
import 'package:aa_doudizhu/domain/game_logic/game_engine.dart';
import 'package:aa_doudizhu/data/models/user.dart';
import 'package:aa_doudizhu/data/models/nft_card.dart';

void main() {
  group('斗地主游戏系统测试', () {
    late GameEngine gameEngine;
    late String testRoomId;

    setUp(() {
      gameEngine = GameEngine();
      gameEngine.initialize();
      testRoomId = 'test_room_001';
    });

    test('卡牌创建和序列化测试', () {
      final card = CardModel(
        suit: Suit.hearts,
        rank: Rank.ace,
        id: 1,
      );

      expect(card.suit, Suit.hearts);
      expect(card.rank, Rank.ace);
      expect(card.id, 1);

      // 测试序列化
      final json = card.toJson();
      final deserializedCard = CardModel.fromJson(json);

      expect(deserializedCard.suit, card.suit);
      expect(deserializedCard.rank, card.rank);
      expect(deserializedCard.id, card.id);
    });

    test('牌型识别测试', () {
      // 单张
      final single = [
        CardModel(suit: Suit.hearts, rank: Rank.ace, id: 1),
      ];
      expect(CardTypeDetector.detect(single), CardType.single);

      // 对子
      final pair = [
        CardModel(suit: Suit.hearts, rank: Rank.ace, id: 1),
        CardModel(suit: Suit.spades, rank: Rank.ace, id: 2),
      ];
      expect(CardTypeDetector.detect(pair), CardType.pair);

      // 炸弹
      final bomb = [
        CardModel(suit: Suit.hearts, rank: Rank.ace, id: 1),
        CardModel(suit: Suit.spades, rank: Rank.ace, id: 2),
        CardModel(suit: Suit.clubs, rank: Rank.ace, id: 3),
        CardModel(suit: Suit.diamonds, rank: Rank.ace, id: 4),
      ];
      expect(CardTypeDetector.detect(bomb), CardType.bomb);

      // 王炸
      final rocket = [
        CardModel(suit: Suit.clubs, rank: Rank.smallJoker, id: 52),
        CardModel(suit: Suit.clubs, rank: Rank.bigJoker, id: 53),
      ];
      expect(CardTypeDetector.detect(rocket), CardType.rocket);
    });

    test('规则检查器测试', () {
      final ruleChecker = SimpleRuleChecker();
      final gameState = GameState(
        roomId: 'test',
        players: {},
        currentTurnPlayerId: 'player1',
      );

      // 测试合法出牌
      final single = [
        CardModel(suit: Suit.hearts, rank: Rank.ace, id: 1),
      ];
      expect(ruleChecker.isLegalPlay(single, gameState), isTrue);

      // 测试非法出牌（空牌）
      expect(ruleChecker.isLegalPlay([], gameState), isFalse);

      // 测试压牌
      final smallerSingle = [
        CardModel(suit: Suit.hearts, rank: Rank.three, id: 2),
      ];
      final largerSingle = [
        CardModel(suit: Suit.hearts, rank: Rank.ace, id: 1),
      ];
      
      expect(ruleChecker.canBeat(largerSingle, smallerSingle, gameState), isTrue);
      expect(ruleChecker.canBeat(smallerSingle, largerSingle, gameState), isFalse);
    });

    test('NFT效果系统测试', () {
      // 创建炸弹NFT
      final bombNFT = NFTEffectManager.createBombDoublerNFT(
        tokenId: 'nft_001',
        contractAddress: '0x123',
        ownerAddress: '0xabc',
      );

      expect(bombNFT.metadata['effect_type'], 'bomb_doubler');
      expect(bombNFT.metadata['name'], '炸弹大师');

      // 创建玩家状态
      final player = PlayerState(
        userId: 'player1',
        handCards: [],
        activeNFTs: [bombNFT],
      );

      // 创建游戏状态
      final gameState = GameState(
        roomId: 'test',
        players: {'player1': player},
        currentTurnPlayerId: 'player1',
      );

      // 测试炸弹效果
      final bomb = [
        CardModel(suit: Suit.hearts, rank: Rank.ace, id: 1),
        CardModel(suit: Suit.spades, rank: Rank.ace, id: 2),
        CardModel(suit: Suit.clubs, rank: Rank.ace, id: 3),
        CardModel(suit: Suit.diamonds, rank: Rank.ace, id: 4),
      ];

      final multiplier = gameState.calculateNFTMultiplier('player1', bomb);
      expect(multiplier, 2.0); // 炸弹应该翻倍

      // 测试非炸弹效果
      final single = [
        CardModel(suit: Suit.hearts, rank: Rank.three, id: 5),
      ];

      final singleMultiplier = gameState.calculateNFTMultiplier('player1', single);
      expect(singleMultiplier, 1.0); // 非炸弹不应该翻倍
    });

    test('AI系统测试', () {
      final ai = RandomAI(difficulty: AIDifficulty.medium);
      
      // 创建测试手牌
      final hand = [
        CardModel(suit: Suit.hearts, rank: Rank.three, id: 1),
        CardModel(suit: Suit.spades, rank: Rank.three, id: 2),
        CardModel(suit: Suit.clubs, rank: Rank.three, id: 3),
        CardModel(suit: Suit.diamonds, rank: Rank.three, id: 4),
        CardModel(suit: Suit.hearts, rank: Rank.four, id: 5),
        CardModel(suit: Suit.spades, rank: Rank.four, id: 6),
        CardModel(suit: Suit.clubs, rank: Rank.four, id: 7),
        CardModel(suit: Suit.diamonds, rank: Rank.four, id: 8),
        CardModel(suit: Suit.hearts, rank: Rank.five, id: 9),
        CardModel(suit: Suit.spades, rank: Rank.five, id: 10),
      ];

      final gameState = GameState(
        roomId: 'test',
        players: {},
        currentTurnPlayerId: 'ai_player',
      );

      // 测试AI选择出牌
      final play = ai.choosePlay(gameState, hand);
      expect(play.isNotEmpty, isTrue);

      // 测试AI叫地主
      final shouldBid = ai.shouldBid(gameState, hand);
      expect(shouldBid, isA<bool>());

      // 测试AI名称
      expect(ai.getAIName(), '普通玩家');
    });

    test('游戏引擎测试', () {
      // 创建测试房间
      final room = gameEngine.roomManager.createRoom(
        roomId: testRoomId,
        hostUserId: 'player1',
      );

      expect(room.roomId, testRoomId);
      expect(room.players.length, 1);
      expect(room.players.first, 'player1');

      // 加入其他玩家
      gameEngine.roomManager.joinRoom(testRoomId, 'player2');
      gameEngine.roomManager.joinRoom(testRoomId, 'player3');

      final updatedRoom = gameEngine.roomManager.getRoom(testRoomId);
      expect(updatedRoom?.players.length, 3);

      // 开始游戏
      gameEngine.roomManager.startGame(testRoomId);

      final gameState = gameEngine.roomManager.getGameState(testRoomId);
      expect(gameState, isNotNull);
      expect(gameState!.currentPhase, GamePhase.bidding);
      expect(gameState.players.length, 3);

      // 测试出牌动作
      final currentPlayer = gameState.getCurrentPlayer();
      if (currentPlayer != null && currentPlayer.handCards.isNotEmpty) {
        final cardToPlay = [currentPlayer.handCards.first];
        
        final result = gameEngine.processAction(
          testRoomId,
          GameActionRequest(
            action: GameAction.play,
            playerId: currentPlayer.userId,
            cards: cardToPlay,
          ),
        );

        expect(result.success, isTrue);
        expect(result.updatedState, isNotNull);
      }
    });

    test('用户模型测试', () {
      final user = User(
        userId: 'user001',
        displayName: '测试玩家',
        email: 'test@example.com',
        walletAddress: '0x123456789',
        goldBalance: 1000,
        nftOwnedTokenIds: ['nft001', 'nft002'],
      );

      expect(user.userId, 'user001');
      expect(user.displayName, '测试玩家');
      expect(user.goldBalance, 1000);
      expect(user.nftOwnedTokenIds.length, 2);

      // 测试序列化
      final json = user.toJson();
      final deserializedUser = User.fromJson(json);

      expect(deserializedUser.userId, user.userId);
      expect(deserializedUser.displayName, user.displayName);
      expect(deserializedUser.goldBalance, user.goldBalance);
      expect(deserializedUser.nftOwnedTokenIds, user.nftOwnedTokenIds);
    });

    test('NFT模型测试', () {
      final nft = NFTCard(
        tokenId: 'nft001',
        contractAddress: '0xabcdef',
        ownerAddress: '0x123456',
        metadata: {
          'name': '测试NFT',
          'description': '这是一个测试NFT',
          'image': 'https://example.com/image.png',
        },
        mintedAt: DateTime.now(),
      );

      expect(nft.tokenId, 'nft001');
      expect(nft.contractAddress, '0xabcdef');
      expect(nft.metadata['name'], '测试NFT');

      // 测试序列化
      final json = nft.toJson();
      final deserializedNFT = NFTCard.fromJson(json);

      expect(deserializedNFT.tokenId, nft.tokenId);
      expect(deserializedNFT.contractAddress, nft.contractAddress);
      expect(deserializedNFT.metadata['name'], nft.metadata['name']);
    });

    test('游戏状态转换测试', () {
      final gameState = GameState(
        roomId: 'test',
        players: {},
        currentTurnPlayerId: 'player1',
        currentPhase: GamePhase.waiting,
      );

      // 测试状态转换
      final biddingState = gameState.copyWith(
        currentPhase: GamePhase.bidding,
      );
      expect(biddingState.currentPhase, GamePhase.bidding);

      final playingState = biddingState.copyWith(
        currentPhase: GamePhase.playing,
        startedAt: DateTime.now(),
      );
      expect(playingState.currentPhase, GamePhase.playing);
      expect(playingState.startedAt, isNotNull);

      final finishedState = playingState.copyWith(
        currentPhase: GamePhase.finished,
        finishedAt: DateTime.now(),
      );
      expect(finishedState.currentPhase, GamePhase.finished);
      expect(finishedState.finishedAt, isNotNull);
    });
  });

  group('集成测试', () {
    test('完整游戏流程测试', () {
      final gameEngine = GameEngine();
      gameEngine.initialize();
      final roomId = 'integration_test_room';

      // 1. 创建房间
      final room = gameEngine.roomManager.createRoom(
        roomId: roomId,
        hostUserId: 'player1',
      );

      // 2. 加入玩家
      gameEngine.roomManager.joinRoom(roomId, 'player2');
      gameEngine.roomManager.joinRoom(roomId, 'player3');

      // 3. 开始游戏
      gameEngine.roomManager.startGame(roomId);

      // 4. 验证游戏状态
      final gameState = gameEngine.roomManager.getGameState(roomId);
      expect(gameState, isNotNull);
      expect(gameState!.players.length, 3);
      expect(gameState.currentPhase, GamePhase.bidding);

      // 5. 叫地主
      final bidResult = gameEngine.processAction(
        roomId,
        GameActionRequest(
          action: GameAction.bid,
          playerId: 'player1',
        ),
      );
      expect(bidResult.success, isTrue);

      // 6. 验证地主设置
      final updatedGameState = gameEngine.roomManager.getGameState(roomId);
      expect(updatedGameState!.landlordPlayerId, 'player1');
      expect(updatedGameState.currentPhase, GamePhase.playing);

      // 7. 模拟几轮出牌
      var currentState = updatedGameState;
      for (int i = 0; i < 5; i++) {
        final currentPlayer = currentState.getCurrentPlayer();
        if (currentPlayer == null || currentPlayer.handCards.isEmpty) break;

        // 简单出牌：出第一张牌
        final cardToPlay = [currentPlayer.handCards.first];
        
        final playResult = gameEngine.processAction(
          roomId,
          GameActionRequest(
            action: GameAction.play,
            playerId: currentPlayer.userId,
            cards: cardToPlay,
          ),
        );

        if (playResult.success && playResult.updatedState != null) {
          currentState = playResult.updatedState!;
        } else {
          // 如果不能出牌，就过牌
          final passResult = gameEngine.processAction(
            roomId,
            GameActionRequest(
              action: GameAction.pass,
              playerId: currentPlayer.userId,
            ),
          );
          
          if (passResult.success && passResult.updatedState != null) {
            currentState = passResult.updatedState!;
          }
        }
      }

      // 8. 验证游戏进度
      final finalState = gameEngine.roomManager.getGameState(roomId);
      expect(finalState, isNotNull);
      expect(finalState!.playHistory.isNotEmpty, isTrue);
    });
  });
}
