import 'package:flutter_test/flutter_test.dart';
import 'package:aa_doudizhu/domain/game_logic/card.dart';
import 'package:aa_doudizhu/domain/game_logic/game_state.dart';
import 'package:aa_doudizhu/domain/game_logic/rule_checker.dart';

void main() {
  test('Straight legality should be true for consecutive 5 cards', () {
    final checker = SimpleRuleChecker();
    final straight = [
      CardModel(suit: Suit.clubs, rank: Rank.five, id: 1),
      CardModel(suit: Suit.diamonds, rank: Rank.six, id: 2),
      CardModel(suit: Suit.hearts, rank: Rank.seven, id: 3),
      CardModel(suit: Suit.spades, rank: Rank.eight, id: 4),
      CardModel(suit: Suit.clubs, rank: Rank.nine, id: 5),
    ];
    final state = GameState(roomId: 'r', currentTurnPlayerId: 'p', hands: straight, deskCards: []);
    expect(checker.isLegalPlay(straight, state), isTrue);
  });

  test('Straight beat higher straight with same length', () {
    final checker = SimpleRuleChecker();
    final last = [
      CardModel(suit: Suit.clubs, rank: Rank.five, id: 10),
      CardModel(suit: Suit.diamonds, rank: Rank.six, id: 11),
      CardModel(suit: Suit.hearts, rank: Rank.seven, id: 12),
      CardModel(suit: Suit.spades, rank: Rank.eight, id: 13),
      CardModel(suit: Suit.clubs, rank: Rank.nine, id: 14),
    ];
    final current = [
      CardModel(suit: Suit.clubs, rank: Rank.six, id: 20),
      CardModel(suit: Suit.diamonds, rank: Rank.seven, id: 21),
      CardModel(suit: Suit.hearts, rank: Rank.eight, id: 22),
      CardModel(suit: Suit.spades, rank: Rank.nine, id: 23),
      CardModel(suit: Suit.clubs, rank: Rank.ten, id: 24),
    ];
    final state = GameState(roomId: 'r', currentTurnPlayerId: 'p', hands: current, deskCards: []);
    expect(checker.canBeat(current, last, state), isTrue);
  });

  test('Rocket beats non-rocket', () {
    final checker = SimpleRuleChecker();
    final last = [CardModel(suit: Suit.clubs, rank: Rank.king, id: 100)];
    final rocketCurrent = [
      CardModel(suit: Suit.hearts, rank: Rank.smallJoker, id: 102),
      CardModel(suit: Suit.spades, rank: Rank.bigJoker, id: 103),
    ];
    final state = GameState(roomId: 'r', currentTurnPlayerId: 'p', hands: rocketCurrent, deskCards: []);
    expect(checker.canBeat(rocketCurrent, last, state), isTrue);
  });

  test('Rocket cannot be beaten (even by rocket)', () {
    final checker = SimpleRuleChecker();
    final rocketLast = [
      CardModel(suit: Suit.clubs, rank: Rank.smallJoker, id: 100),
      CardModel(suit: Suit.diamonds, rank: Rank.bigJoker, id: 101),
    ];
    final rocketCurrent = [
      CardModel(suit: Suit.hearts, rank: Rank.smallJoker, id: 102),
      CardModel(suit: Suit.spades, rank: Rank.bigJoker, id: 103),
    ];
    final state = GameState(roomId: 'r', currentTurnPlayerId: 'p', hands: rocketCurrent, deskCards: []);
    expect(checker.canBeat(rocketCurrent, rocketLast, state), isFalse);
  });
}
