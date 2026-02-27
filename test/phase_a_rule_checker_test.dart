import 'package:flutter_test/flutter_test.dart';
import 'package:aa_doudizhu/domain/game_logic/card.dart';
import 'package:aa_doudizhu/domain/game_logic/game_state.dart';
import 'package:aa_doudizhu/domain/game_logic/rule_checker.dart';

void main() {
  test('SimpleRuleChecker isLegalPlay', () {
    final checker = SimpleRuleChecker();
    final hand = [CardModel(suit: Suit.spades, rank: Rank.king, id: 1)];
    final state = GameState(roomId: 'r', currentTurnPlayerId: 'p', hands: hand, deskCards: []);
    expect(checker.isLegalPlay(hand, state), isTrue);
  });

  test('SimpleRuleChecker canBeat', () {
    final checker = SimpleRuleChecker();
    final last = [CardModel(suit: Suit.spades, rank: Rank.king, id: 1)];
    final current = [CardModel(suit: Suit.spades, rank: Rank.king, id: 2), CardModel(suit: Suit.spades, rank: Rank.king, id: 3)];
    final state = GameState(roomId: 'r', currentTurnPlayerId: 'p', hands: current, deskCards: []);
    expect(checker.canBeat(current, last, state), isTrue);
  });

  test('RuleChecker: higher rank same length beats', () {
    final checker = SimpleRuleChecker();
    final last = [CardModel(suit: Suit.clubs, rank: Rank.jack, id: 4)];
    final current = [CardModel(suit: Suit.clubs, rank: Rank.king, id: 5)];
    final state = GameState(roomId: 'r', currentTurnPlayerId: 'p', hands: current, deskCards: []);
    expect(checker.canBeat(current, last, state), isTrue);
  });

  test('RuleChecker: lower rank same length cannot beat', () {
    final checker = SimpleRuleChecker();
    final last = [CardModel(suit: Suit.clubs, rank: Rank.king, id: 6)];
    final current = [CardModel(suit: Suit.clubs, rank: Rank.jack, id: 7)];
    final state = GameState(roomId: 'r', currentTurnPlayerId: 'p', hands: current, deskCards: []);
    expect(checker.canBeat(current, last, state), isFalse);
  });
}
