import 'package:aa_doudizhu/domain/game_logic/card.dart';

/// 斗地主完整牌型枚举（标准规则）
enum CardType {
  single,
  pair,
  triplet,
  tripletWithSingle,
  tripletWithPair,
  straight,
  doubleSequence,
  tripleSequence,
  tripleSequenceWithSingles,
  tripleSequenceWithPairs,
  fourWithTwoSingles,
  fourWithTwoPairs,
  bomb,
  rocket,
}

class CardPattern {
  final CardType type;
  final int mainRankValue;
  final int length;
  final int totalCards;

  const CardPattern({
    required this.type,
    required this.mainRankValue,
    required this.length,
    required this.totalCards,
  });
}

class CardTypeDetector {
  /// 标准斗地主牌点大小：3 < 4 < … < K < 2 < 小王 < 大王
  static int rankValue(Rank r) {
    switch (r) {
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
      case Rank.two:
        return 14;
      case Rank.smallJoker:
        return 15;
      case Rank.bigJoker:
        return 16;
    }
  }

  static Map<Rank, int> _countByRank(List<CardModel> cards) {
    final map = <Rank, int>{};
    for (final c in cards) {
      map[c.rank] = (map[c.rank] ?? 0) + 1;
    }
    return map;
  }

  static List<Rank> _sortedRanks(Iterable<Rank> ranks) {
    final list = ranks.toList();
    list.sort((a, b) => rankValue(a).compareTo(rankValue(b)));
    return list;
  }

  static bool _isMainSeqRank(Rank r) {
    return r != Rank.two && r != Rank.smallJoker && r != Rank.bigJoker;
  }

  static bool _isConsecutiveRanks(List<Rank> ranks) {
    if (ranks.isEmpty) return false;
    final values = ranks.map(rankValue).toList()..sort();
    for (var i = 1; i < values.length; i++) {
      if (values[i] != values[i - 1] + 1) return false;
    }
    return true;
  }

  static CardPattern? analyze(List<CardModel> cards) {
    if (cards.isEmpty) return null;
    final total = cards.length;
    final counts = _countByRank(cards);

    if (total == 2 &&
        counts.length == 2 &&
        counts[Rank.smallJoker] == 1 &&
        counts[Rank.bigJoker] == 1) {
      return CardPattern(
        type: CardType.rocket,
        mainRankValue: rankValue(Rank.bigJoker),
        length: 1,
        totalCards: total,
      );
    }

    if (total == 4 && counts.length == 1 && counts.values.first == 4) {
      final r = counts.keys.first;
      return CardPattern(
        type: CardType.bomb,
        mainRankValue: rankValue(r),
        length: 1,
        totalCards: total,
      );
    }

    if (counts.values.any((v) => v == 4)) {
      final quadRank = counts.entries.firstWhere((e) => e.value == 4).key;
      final others = Map<Rank, int>.from(counts)..remove(quadRank);

      if (total == 8) {
        final isTwoPairs =
            others.length == 2 && others.values.every((v) => v == 2);
        if (isTwoPairs) {
          return CardPattern(
            type: CardType.fourWithTwoPairs,
            mainRankValue: rankValue(quadRank),
            length: 1,
            totalCards: total,
          );
        }
      }

      if (total == 6) {
        final singleCount = others.values.fold<int>(0, (p, c) => p + c);
        if (singleCount == 2) {
          return CardPattern(
            type: CardType.fourWithTwoSingles,
            mainRankValue: rankValue(quadRank),
            length: 1,
            totalCards: total,
          );
        }
      }
    }

    final tripRanks =
        counts.entries.where((e) => e.value == 3 && _isMainSeqRank(e.key)).map((e) => e.key).toList();
    final tripCount = tripRanks.length;
    if (tripCount >= 2) {
      final sortedTrip = _sortedRanks(tripRanks);
      final isTripConsecutive = _isConsecutiveRanks(sortedTrip);

      if (isTripConsecutive) {
        final tripCards = tripCount * 3;
        if (total == tripCards) {
          return CardPattern(
            type: CardType.tripleSequence,
            mainRankValue: rankValue(sortedTrip.last),
            length: tripCount,
            totalCards: total,
          );
        }

        final leftovers = Map<Rank, int>.from(counts)
          ..removeWhere((rank, _) => tripRanks.contains(rank));
        final leftoverTotal = leftovers.values.fold<int>(0, (p, c) => p + c);

        if (total == tripCards + tripCount && leftoverTotal == tripCount) {
          return CardPattern(
            type: CardType.tripleSequenceWithSingles,
            mainRankValue: rankValue(sortedTrip.last),
            length: tripCount,
            totalCards: total,
          );
        }

        if (total == tripCards + tripCount * 2 &&
            leftoverTotal == tripCount * 2 &&
            leftovers.values.every((v) => v == 2)) {
          return CardPattern(
            type: CardType.tripleSequenceWithPairs,
            mainRankValue: rankValue(sortedTrip.last),
            length: tripCount,
            totalCards: total,
          );
        }
      }
    }

    if (total >= 6 && total.isEven) {
      final pairRanks = counts.entries
          .where((e) => e.value == 2 && _isMainSeqRank(e.key))
          .map((e) => e.key)
          .toList();
      final numPairs = pairRanks.length;
      if (numPairs >= 3 && numPairs * 2 == total) {
        final sortedPairRanks = _sortedRanks(pairRanks);
        if (_isConsecutiveRanks(sortedPairRanks)) {
          return CardPattern(
            type: CardType.doubleSequence,
            mainRankValue: rankValue(sortedPairRanks.last),
            length: numPairs,
            totalCards: total,
          );
        }
      }
    }

    if (total >= 5) {
      final singleRanks = counts.entries
          .where((e) => e.value == 1 && _isMainSeqRank(e.key))
          .map((e) => e.key)
          .toList();
      if (singleRanks.length == counts.length && singleRanks.length == total) {
        final sortedSingles = _sortedRanks(singleRanks);
        if (_isConsecutiveRanks(sortedSingles)) {
          return CardPattern(
            type: CardType.straight,
            mainRankValue: rankValue(sortedSingles.last),
            length: sortedSingles.length,
            totalCards: total,
          );
        }
      }
    }

    if (total == 5 && counts.length == 2) {
      final entry3 = counts.entries.firstWhere(
            (e) => e.value == 3,
            orElse: () => MapEntry<Rank, int>(Rank.three, 0),
          );
      final entry2 = counts.entries.firstWhere(
            (e) => e.value == 2,
            orElse: () => MapEntry<Rank, int>(Rank.three, 0),
          );
      if (entry3.value == 3 && entry2.value == 2) {
        return CardPattern(
          type: CardType.tripletWithPair,
          mainRankValue: rankValue(entry3.key),
          length: 1,
          totalCards: total,
        );
      }
    }

    if (total == 4 && counts.length == 2) {
      final entry3 = counts.entries.firstWhere(
            (e) => e.value == 3,
            orElse: () => MapEntry<Rank, int>(Rank.three, 0),
          );
      if (entry3.value == 3) {
        return CardPattern(
          type: CardType.tripletWithSingle,
          mainRankValue: rankValue(entry3.key),
          length: 1,
          totalCards: total,
        );
      }
    }

    if (total == 3 && counts.length == 1 && counts.values.first == 3) {
      final r = counts.keys.first;
      return CardPattern(
        type: CardType.triplet,
        mainRankValue: rankValue(r),
        length: 1,
        totalCards: total,
      );
    }

    if (total == 2 && counts.length == 1 && counts.values.first == 2) {
      final r = counts.keys.first;
      return CardPattern(
        type: CardType.pair,
        mainRankValue: rankValue(r),
        length: 1,
        totalCards: total,
      );
    }

    if (total == 1) {
      final r = cards.first.rank;
      return CardPattern(
        type: CardType.single,
        mainRankValue: rankValue(r),
        length: 1,
        totalCards: total,
      );
    }

    return null;
  }

  static CardType? detect(List<CardModel> cards) {
    final pattern = analyze(cards);
    return pattern?.type;
  }
}
