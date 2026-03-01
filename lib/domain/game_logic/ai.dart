import 'package:aa_doudizhu/domain/game_logic/card.dart';
import 'package:aa_doudizhu/domain/game_logic/game_state.dart';
import 'package:aa_doudizhu/domain/game_logic/card_type.dart';
import 'package:aa_doudizhu/domain/game_logic/rule_checker.dart';
import 'dart:math';

enum AIDifficulty { easy, medium, hard }

abstract class AIEngine {
  List<CardModel> choosePlay(GameState state, List<CardModel> hand);
  bool shouldBid(GameState state, List<CardModel> hand);
  String getAIName();
}

class RandomAI implements AIEngine {
  final AIDifficulty difficulty;
  final Random _random = Random();
  late final SimpleRuleChecker _ruleChecker;

  RandomAI({this.difficulty = AIDifficulty.medium}) {
    _ruleChecker = SimpleRuleChecker();
  }

  @override
  String getAIName() {
    switch (difficulty) {
      case AIDifficulty.easy:
        return '新手玩家';
      case AIDifficulty.medium:
        return '普通玩家';
      case AIDifficulty.hard:
        return '高手玩家';
    }
  }

  @override
  bool shouldBid(GameState state, List<CardModel> hand) {
    // 根据难度决定叫地主的积极性
    double bidProbability;
    switch (difficulty) {
      case AIDifficulty.easy:
        bidProbability = 0.2;
        break;
      case AIDifficulty.medium:
        bidProbability = 0.4;
        break;
      case AIDifficulty.hard:
        bidProbability = 0.6;
        break;
    }
    
    // 根据手牌质量调整概率
    final cardScore = _evaluateHandStrength(hand);
    bidProbability *= (cardScore / 100.0);
    
    return _random.nextDouble() < bidProbability;
  }

  @override
  List<CardModel> choosePlay(GameState state, List<CardModel> hand) {
    final lastPlay = state.lastPlay;
    
    if (lastPlay.isEmpty) {
      // 自由出牌
      return _chooseFreePlay(hand);
    } else {
      // 必须压过上家的牌
      return _chooseCounterPlay(hand, lastPlay, state);
    }
  }

  List<CardModel> _chooseFreePlay(List<CardModel> hand) {
    final possiblePlays = _generateAllPossiblePlays(hand);
    
    if (possiblePlays.isEmpty) return [];
    
    // 根据难度选择策略
    switch (difficulty) {
      case AIDifficulty.easy:
        // 随机选择
        return possiblePlays[_random.nextInt(possiblePlays.length)];
      
      case AIDifficulty.medium:
        // 偏向选择较小的牌型
        possiblePlays.sort((a, b) => a.length.compareTo(b.length));
        return possiblePlays.first;
      
      case AIDifficulty.hard:
        // 智能选择，考虑手牌数量
        return _chooseStrategicPlay(possiblePlays, hand);
    }
  }

  List<CardModel> _chooseCounterPlay(
    List<CardModel> hand, 
    List<CardModel> lastPlay, 
    GameState state
  ) {
    final counterPlays = _generateCounterPlays(hand, lastPlay, state);
    
    if (counterPlays.isEmpty) return [];
    
    // 根据难度选择策略
    switch (difficulty) {
      case AIDifficulty.easy:
        // 随机选择能压过的牌
        return counterPlays[_random.nextInt(counterPlays.length)];
      
      case AIDifficulty.medium:
        // 选择最小的能压过的牌
        counterPlays.sort((a, b) {
          final patternA = CardTypeDetector.analyze(a);
          final patternB = CardTypeDetector.analyze(b);
          if (patternA == null || patternB == null) return 0;
          return patternA.mainRankValue.compareTo(patternB.mainRankValue);
        });
        return counterPlays.first;
      
      case AIDifficulty.hard:
        // 智能选择，考虑是否要使用炸弹等大牌
        return _chooseSmartCounterPlay(counterPlays, lastPlay, hand);
    }
  }

  List<List<CardModel>> _generateAllPossiblePlays(List<CardModel> hand) {
    final plays = <List<CardModel>>[];
    
    // 生成所有可能的牌型组合
    // 单张
    for (final card in hand) {
      plays.add([card]);
    }
    
    // 对子
    final rankGroups = _groupCardsByRank(hand);
    for (final group in rankGroups.values) {
      if (group.length >= 2) {
        plays.add(group.take(2).toList());
      }
    }
    
    // 三张
    for (final group in rankGroups.values) {
      if (group.length >= 3) {
        plays.add(group.take(3).toList());
      }
    }
    
    // 炸弹
    for (final group in rankGroups.values) {
      if (group.length == 4) {
        plays.add(group);
      }
    }
    
    // 顺子等复杂牌型（简化版本）
    final straightPlays = _generateStraights(hand);
    plays.addAll(straightPlays);
    
    return plays.where((play) => _ruleChecker.isLegalPlay(play, GameState(
      roomId: 'temp',
      players: {},
      currentTurnPlayerId: 'temp',
    ))).toList();
  }

  List<List<CardModel>> _generateCounterPlays(
    List<CardModel> hand, 
    List<CardModel> lastPlay, 
    GameState state
  ) {
    final possiblePlays = _generateAllPossiblePlays(hand);
    
    return possiblePlays.where((play) {
      return _ruleChecker.canBeat(play, lastPlay, state);
    }).toList();
  }

  Map<Rank, List<CardModel>> _groupCardsByRank(List<CardModel> cards) {
    final groups = <Rank, List<CardModel>>{};
    for (final card in cards) {
      groups.putIfAbsent(card.rank, () => []).add(card);
    }
    return groups;
  }

  List<List<CardModel>> _generateStraights(List<CardModel> hand) {
    final straights = <List<CardModel>>[];
    final rankGroups = _groupCardsByRank(hand);
    final ranks = rankGroups.keys.where((r) => r != Rank.two && r != Rank.smallJoker && r != Rank.bigJoker).toList();
    ranks.sort((a, b) => CardTypeDetector.rankValue(a).compareTo(CardTypeDetector.rankValue(b)));
    
    // 查找5张以上的顺子
    for (int i = 0; i <= ranks.length - 5; i++) {
      for (int length = 5; length <= ranks.length - i; length++) {
        bool isStraight = true;
        for (int j = 0; j < length - 1; j++) {
          if (CardTypeDetector.rankValue(ranks[i + j + 1]) - 
              CardTypeDetector.rankValue(ranks[i + j]) != 1) {
            isStraight = false;
            break;
          }
        }
        
        if (isStraight) {
          final straightCards = <CardModel>[];
          for (int j = 0; j < length; j++) {
            straightCards.add(rankGroups[ranks[i + j]]!.first);
          }
          straights.add(straightCards);
        }
      }
    }
    
    return straights;
  }

  List<CardModel> _chooseStrategicPlay(
    List<List<CardModel>> possiblePlays, 
    List<CardModel> hand
  ) {
    // 优先出单张小牌，保留大牌型
    final singleCards = possiblePlays.where((play) => play.length == 1).toList();
    if (singleCards.isNotEmpty) {
      singleCards.sort((a, b) => CardTypeDetector.rankValue(a.first.rank)
          .compareTo(CardTypeDetector.rankValue(b.first.rank)));
      return singleCards.first;
    }
    
    // 其次出对子
    final pairs = possiblePlays.where((play) => play.length == 2).toList();
    if (pairs.isNotEmpty) {
      pairs.sort((a, b) => CardTypeDetector.rankValue(a.first.rank)
          .compareTo(CardTypeDetector.rankValue(b.first.rank)));
      return pairs.first;
    }
    
    // 最后选择其他牌型
    return possiblePlays.first;
  }

  List<CardModel> _chooseSmartCounterPlay(
    List<List<CardModel>> counterPlays, 
    List<CardModel> lastPlay, 
    List<CardModel> hand
  ) {
    // 如果手牌很少，积极出牌
    if (hand.length <= 3) {
      return counterPlays.first;
    }
    
    // 避免过早使用炸弹，除非是火箭
    final lastPattern = CardTypeDetector.analyze(lastPlay);
    if (lastPattern?.type != CardType.rocket) {
      final nonBombs = counterPlays.where((play) {
        final pattern = CardTypeDetector.analyze(play);
        return pattern?.type != CardType.bomb;
      }).toList();
      
      if (nonBombs.isNotEmpty) {
        nonBombs.sort((a, b) {
          final patternA = CardTypeDetector.analyze(a);
          final patternB = CardTypeDetector.analyze(b);
          if (patternA == null || patternB == null) return 0;
          return patternA.mainRankValue.compareTo(patternB.mainRankValue);
        });
        return nonBombs.first;
      }
    }
    
    // 选择最小的能压过的牌
    counterPlays.sort((a, b) {
      final patternA = CardTypeDetector.analyze(a);
      final patternB = CardTypeDetector.analyze(b);
      if (patternA == null || patternB == null) return 0;
      return patternA.mainRankValue.compareTo(patternB.mainRankValue);
    });
    
    return counterPlays.first;
  }

  double _evaluateHandStrength(List<CardModel> hand) {
    double score = 0.0;
    final rankGroups = _groupCardsByRank(hand);
    
    // 大牌分数
    for (final card in hand) {
      score += CardTypeDetector.rankValue(card.rank);
    }
    
    // 炸弹加分
    for (final group in rankGroups.values) {
      if (group.length == 4) {
        score += 50; // 炸弹大幅加分
      }
    }
    
    // 王炸加分
    if (rankGroups.containsKey(Rank.smallJoker) && rankGroups.containsKey(Rank.bigJoker)) {
      score += 100;
    }
    
    return score;
  }
}

class AIManager {
  static Map<String, AIEngine> _aiInstances = {};
  
  static AIEngine getAI(String playerId, AIDifficulty difficulty) {
    return _aiInstances.putIfAbsent(playerId, () => RandomAI(difficulty: difficulty));
  }
  
  static void removeAI(String playerId) {
    _aiInstances.remove(playerId);
  }
  
  static bool isAIPlayer(String playerId) {
    return playerId.startsWith('bot_') || _aiInstances.containsKey(playerId);
  }
  
  static String generateAIPlayerId(String originalPlayerId) {
    return 'bot_$originalPlayerId';
  }
}
