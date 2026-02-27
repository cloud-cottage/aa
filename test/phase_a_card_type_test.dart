import 'package:flutter_test/flutter_test.dart';
import 'package:aa_doudizhu/domain/game_logic/card.dart';
import 'package:aa_doudizhu/domain/game_logic/card_type.dart';

void main() {
  test('CardTypeDetector detects single', () {
    final c = CardModel(suit: Suit.hearts, rank: Rank.four, id: 1);
    expect(CardTypeDetector.detect([c]), CardType.single);
  });

  test('CardTypeDetector detects pair', () {
    final a = CardModel(suit: Suit.hearts, rank: Rank.five, id: 2);
    final b = CardModel(suit: Suit.clubs, rank: Rank.five, id: 3);
    expect(CardTypeDetector.detect([a, b]), CardType.pair);
  });

  test('CardTypeDetector detects straight', () {
    final cards = [
      CardModel(suit: Suit.clubs, rank: Rank.five, id: 4),
      CardModel(suit: Suit.diamonds, rank: Rank.six, id: 5),
      CardModel(suit: Suit.hearts, rank: Rank.seven, id: 6),
      CardModel(suit: Suit.spades, rank: Rank.eight, id: 7),
      CardModel(suit: Suit.clubs, rank: Rank.nine, id: 8),
    ];
    expect(CardTypeDetector.detect(cards), CardType.straight);
  });

  test('CardTypeDetector detects bomb', () {
    final cards = [
      CardModel(suit: Suit.hearts, rank: Rank.king, id: 9),
      CardModel(suit: Suit.clubs, rank: Rank.king, id: 10),
      CardModel(suit: Suit.diamonds, rank: Rank.king, id: 11),
      CardModel(suit: Suit.spades, rank: Rank.king, id: 12),
    ];
    expect(CardTypeDetector.detect(cards), CardType.bomb);
  });

  test('CardTypeDetector detects rocket', () {
    final cards = [
      CardModel(suit: Suit.clubs, rank: Rank.smallJoker, id: 13),
      CardModel(suit: Suit.diamonds, rank: Rank.bigJoker, id: 14),
    ];
    expect(CardTypeDetector.detect(cards), CardType.rocket);
  });
}
