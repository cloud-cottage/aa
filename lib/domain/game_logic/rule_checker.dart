import 'package:aa_doudizhu/domain/game_logic/card.dart';
import 'package:aa_doudizhu/domain/game_logic/game_state.dart';
import 'package:aa_doudizhu/domain/game_logic/card_type.dart';

abstract class RuleChecker {
  bool isLegalPlay(List<CardModel> handPlay, GameState state);
  bool canBeat(List<CardModel> currentPlay, List<CardModel> lastPlay, GameState state);

  /// 计算本手出牌的倍数贡献（炸弹×2、火箭×2 等，后续可扩展春天/反春天）
  int playMultiplier(List<CardModel> play, GameState state);

  /// 计算包含NFT效果的总倍数
  int calculateTotalMultiplier(List<CardModel> play, GameState state);
}

int _defaultPlayMultiplier(List<CardModel> play) {
  final pattern = CardTypeDetector.analyze(play);
  if (pattern == null) return 1;
  if (pattern.type == CardType.rocket) return 2;
  if (pattern.type == CardType.bomb) return 2;
  return 1;
}

class SimpleRuleChecker implements RuleChecker {
  @override
  bool isLegalPlay(List<CardModel> handPlay, GameState state) {
    final pattern = CardTypeDetector.analyze(handPlay);
    return pattern != null;
  }

  @override
  bool canBeat(List<CardModel> currentPlay, List<CardModel> lastPlay, GameState state) {
    if (lastPlay.isEmpty) return true;

    final lastPattern = CardTypeDetector.analyze(lastPlay);
    final currPattern = CardTypeDetector.analyze(currentPlay);

    if (lastPattern == null || currPattern == null) return false;

    // 火箭：最大牌型，不能被任何牌压过
    if (lastPattern.type == CardType.rocket) return false;

    // 当前出火箭：可以压任何牌
    if (currPattern.type == CardType.rocket) return true;

    // 炸弹压非炸弹
    if (currPattern.type == CardType.bomb && lastPattern.type != CardType.bomb) {
      return true;
    }

    // 炸弹对炸弹：比较牌点
    if (currPattern.type == CardType.bomb && lastPattern.type == CardType.bomb) {
      return currPattern.mainRankValue > lastPattern.mainRankValue;
    }

    // 标准规则：必须同牌型才能比较
    if (currPattern.type != lastPattern.type) return false;

    // 顺子、连对、飞机类：必须长度相同，且主体牌点更大
    const lengthTypes = [
      CardType.straight,
      CardType.doubleSequence,
      CardType.tripleSequence,
      CardType.tripleSequenceWithSingles,
      CardType.tripleSequenceWithPairs,
    ];
    if (lengthTypes.contains(currPattern.type)) {
      if (currPattern.length != lastPattern.length) return false;
      return currPattern.mainRankValue > lastPattern.mainRankValue;
    }

    // 四带二单、四带二对：同牌型，比较四张的主体牌点
    if (currPattern.type == CardType.fourWithTwoSingles ||
        currPattern.type == CardType.fourWithTwoPairs) {
      return currPattern.mainRankValue > lastPattern.mainRankValue;
    }

    // 单张、对子、三张、三带一、三带二、炸弹（炸弹对炸弹已处理）：比较 mainRankValue
    return currPattern.mainRankValue > lastPattern.mainRankValue;
  }

  @override
  int playMultiplier(List<CardModel> play, GameState state) {
    return _defaultPlayMultiplier(play);
  }

  @override
  int calculateTotalMultiplier(List<CardModel> play, GameState state) {
    final baseMultiplier = playMultiplier(play, state);
    final currentPlayerId = state.currentTurnPlayerId;
    final nftMultiplier = state.calculateNFTMultiplier(currentPlayerId, play);
    
    return baseMultiplier * nftMultiplier;
  }
}
