import 'package:flutter_test/flutter_test.dart';
import 'package:aa_doudizhu/domain/game_logic/card.dart';
import 'package:aa_doudizhu/domain/game_logic/game_state.dart';
import 'package:aa_doudizhu/domain/game_logic/rule_checker.dart';
import 'package:aa_doudizhu/domain/game_logic/card_type.dart';

void main() {
  test('CanBeat: straight of higher rank beats same length', () {
    final checker = SimpleRuleChecker();
    final last = [
      CardModel(suit: Suit.clubs, rank: Rank.five, id: 1),
      CardModel(suit: Suit.clubs, rank: Rank.six, id: 2),
      CardModel(suit: Suit.clubs, rank: Rank.seven, id: 3),
      CardModel(suit: Suit.clubs, rank: Rank.eight, id: 4),
      CardModel(suit: Suit.clubs, rank: Rank.nine, id: 5),
    ];
    final current = [
      CardModel(suit: Suit.clubs, rank: Rank.six, id: 6),
      CardModel(suit: Suit.clubs, rank: Rank.seven, id: 7),
      CardModel(suit: Suit.clubs, rank: Rank.eight, id: 8),
      CardModel(suit: Suit.clubs, rank: Rank.nine, id: 9),
      CardModel(suit: Suit.clubs, rank: Rank.ten, id: 10),
    ];
    final state = GameState(roomId: 'r', currentTurnPlayerId: 'p', hands: last, deskCards: []);
    expect(checker.canBeat(current, last, state), isTrue);
  });

  test('CanBeat: nil last play with any valid current play', () {
    final checker = SimpleRuleChecker();
    final current = [
      CardModel(suit: Suit.clubs, rank: Rank.five, id: 11),
    ];
    final state = GameState(roomId: 'r', currentTurnPlayerId: 'p', hands: current, deskCards: []);
    expect(checker.canBeat(current, [], state), isTrue);
  });

  test('CanBeat: rocket vs non-rocket', () {
    final checker = SimpleRuleChecker();
    final last = [CardModel(suit: Suit.clubs, rank: Rank.smallJoker, id: 20), CardModel(suit: Suit.diamonds, rank: Rank.bigJoker, id: 21)];
    final current = [CardModel(suit: Suit.hearts, rank: Rank.smallJoker, id: 22), CardModel(suit: Suit.spades, rank: Rank.bigJoker, id: 23)];
    final state = GameState(roomId: 'r', currentTurnPlayerId: 'p', hands: current, deskCards: []);
    expect(checker.canBeat(current, last, state), isTrue);
  });
}
