import 'package:aa_doudizhu/domain/game_logic/card.dart';
import 'package:aa_doudizhu/domain/game_logic/game_state.dart';
import 'package:aa_doudizhu/domain/game_logic/card_type.dart';

abstract class RuleChecker {
  // Determine if a player's handPlay is legal given the current game state
  bool isLegalPlay(List<CardModel> handPlay, GameState state);

  // Compare current play with last play to see if it beats it
  bool canBeat(List<CardModel> currentPlay, List<CardModel> lastPlay, GameState state);
}

// Simple in-memory placeholder implementation for Phase A with improved heuristics
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
      case Rank.joker:
        return 14;
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
    // Use CardTypeDetector for phase A legality
    final type = CardTypeDetector.detect(handPlay);
    return type != null;
  }

  @override
  bool canBeat(List<CardModel> currentPlay, List<CardModel> lastPlay, GameState state) {
    // If there is no last play, any valid current play wins
    if (lastPlay.isEmpty) return true;
    final lastType = CardTypeDetector.detect(lastPlay);
    final currType = CardTypeDetector.detect(currentPlay);
    final isRocketLast = lastType == CardType.rocket;
    final isRocketCurr = currType == CardType.rocket;

    // Rocket beats all non-rocket; if last is rocket, only rocket can beat
    if (isRocketLast) {
      return isRocketCurr;
    }
    if (isRocketCurr) {
      return true;
    }
    if (currType == null) return false;
    // If different lengths, longer wins (simplified)
    if (currentPlay.length != lastPlay.length) return currentPlay.length > lastPlay.length;
    // Same length: compare max rank as tie-breaker
    final currentMax = _maxRank(currentPlay);
    final lastMax = _maxRank(lastPlay);
    return currentMax > lastMax;
  }
}
  @override
  bool isLegalPlay(List<CardModel> handPlay, GameState state) {
    // Basic sanity: must play at least one card
    return handPlay.isNotEmpty;
  }

  @override
  bool canBeat(List<CardModel> currentPlay, List<CardModel> lastPlay, GameState state) {
    // Very naive comparison: beat if more cards or if there is no last play
    if (lastPlay.isEmpty) return true;
    if (currentPlay.isEmpty) return false;
    return currentPlay.length > lastPlay.length;
  }
}
