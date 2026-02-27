import 'package:aa_doudizhu/domain/game_logic/card.dart';
import 'package:aa_doudizhu/domain/game_logic/game_state.dart';
import 'package:aa_doudizhu/domain/game_logic/card_type.dart';

abstract class RuleChecker {
  bool isLegalPlay(List<CardModel> handPlay, GameState state);
  bool canBeat(List<CardModel> currentPlay, List<CardModel> lastPlay, GameState state);
}

class SimpleRuleChecker implements RuleChecker {
  int _rankValue(Rank r) {
    switch (r) {
      case Rank.two:
        return 2;
      case Rank.three:
        return 3;
      case Rank.four:
        return 4;
      case Rank.five:
        return 5;
      case Rank.six:
        return 6;
      case Rank.seven:
        return 7;
      case Rank.eight:
        return 8;
      case Rank.nine:
        return 9;
      case Rank.ten:
        return 10;
      case Rank.jack:
        return 11;
      case Rank.queen:
        return 12;
      case Rank.king:
        return 13;
      case Rank.smallJoker:
        return 14;
      case Rank.bigJoker:
        return 15;
    }
  }

  int _maxRank(List<CardModel> cards) {
    if (cards.isEmpty) return 0;
    int maxV = 0;
    for (var c in cards) {
      final v = _rankValue(c.rank);
      if (v > maxV) maxV = v;
    }
    return maxV;
  }

  @override
  bool isLegalPlay(List<CardModel> handPlay, GameState state) {
    final type = CardTypeDetector.detect(handPlay);
    return type != null;
  }

  @override
  bool canBeat(List<CardModel> currentPlay, List<CardModel> lastPlay, GameState state) {
    if (lastPlay.isEmpty) return true;
    final lastType = CardTypeDetector.detect(lastPlay);
    final currType = CardTypeDetector.detect(currentPlay);
    final isRocketLast = lastType == CardType.rocket;
    final isRocketCurr = currType == CardType.rocket;

    if (isRocketLast) {
      return isRocketCurr;
    }
    if (isRocketCurr) {
      return true;
    }
    if (currType == null) return false;
    if (currentPlay.length != lastPlay.length) return currentPlay.length > lastPlay.length;
    final currentMax = _maxRank(currentPlay);
    final lastMax = _maxRank(lastPlay);
    return currentMax > lastMax;
  }
}
