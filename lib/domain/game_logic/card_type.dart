import 'package:aa_doudizhu/domain/game_logic/card.dart';

enum CardType { single, pair, triplet, straight, bomb, rocket }

class CardTypeDetector {
  static int _rankValue(Rank r) {
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

  static bool _isConsecutive(List<CardModel> cards) {
    if (cards.length < 5) return false;
    // Jokers not allowed in straights in this simplified rule
    if (cards.any((c) => c.rank == Rank.smallJoker || c.rank == Rank.bigJoker)) return false;
    final ranks = cards.map((c) => _rankValue(c.rank)).toList()..sort();
    for (int i = 1; i < ranks.length; i++) {
      if (ranks[i] != ranks[i - 1] + 1) return false;
    }
    return true;
  }

  static CardType? detect(List<CardModel> cards) {
    if (cards.isEmpty) return null;
    // Rocket: small joker + big joker
    if (cards.length == 2) {
      final ranks = cards.map((c) => c.rank).toList();
      if (ranks.contains(Rank.smallJoker) && ranks.contains(Rank.bigJoker)) {
        return CardType.rocket;
      }
    }
    // Bomb: four of a kind
    if (cards.length == 4) {
      final first = cards.first.rank;
      if (cards.every((c) => c.rank == first)) return CardType.bomb;
    }
    // Pair
    if (cards.length == 2) {
      if (cards[0].rank == cards[1].rank) return CardType.pair;
    }
    // Single
    if (cards.length == 1) return CardType.single;
    // Triplet
    if (cards.length == 3) {
      if (cards[0].rank == cards[1].rank && cards[1].rank == cards[2].rank) return CardType.triplet;
    }
    // Straight
    if (cards.length >= 5 && _isConsecutive(cards)) {
      return CardType.straight;
    }
    return null;
  }
}
