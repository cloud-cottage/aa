import 'package:flutter_test/flutter_test.dart';
import 'package:aa_doudizhu/domain/game_logic/card.dart';
import 'package:aa_doudizhu/domain/game_logic/game_state.dart';
import 'package:aa_doudizhu/domain/game_logic/rule_checker.dart';

void main() {
  test('SimpleRuleChecker isLegalPlay', () {
    final checker = SimpleRuleChecker();
    final hand = [CardModel(suit: Suit.spades, rank: Rank.king, id: 1)];
    final state = GameState(
      roomId: 'test_room',
      currentTurnPlayerId: 'test_player',
      players: {
        'test_player': PlayerState(
          userId: 'test_player',
          handCards: hand,
        ),
      },
      currentPhase: GamePhase.playing,
    );
    expect(checker.isLegalPlay(hand, state), isTrue);
  });

  test('SimpleRuleChecker canBeat: pair beats pair (higher rank)', () {
    final checker = SimpleRuleChecker();
    final last = [CardModel(suit: Suit.spades, rank: Rank.jack, id: 1), CardModel(suit: Suit.hearts, rank: Rank.jack, id: 2)];
    final current = [CardModel(suit: Suit.spades, rank: Rank.king, id: 2), CardModel(suit: Suit.clubs, rank: Rank.king, id: 3)];
    final state = GameState(
      roomId: 'test_room',
      currentTurnPlayerId: 'test_player',
      players: {
        'test_player': PlayerState(
          userId: 'test_player',
          handCards: current,
        ),
      },
      currentPhase: GamePhase.playing,
    );
    expect(checker.canBeat(current, last, state), isTrue);
  });
}
