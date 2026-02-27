import 'package:flutter_test/flutter_test.dart';
import 'package:aa_doudizhu/domain/game_logic/ai_greedy.dart';
import 'package:aa_doudizhu/domain/game_logic/card.dart';
import 'package:aa_doudizhu/domain/game_logic/game_state.dart';

void main() {
  test('GreedyAI selects highest single card', () {
    final ai = GreedyAI();
    final hand = [
      CardModel(suit: Suit.clubs, rank: Rank.five, id: 1),
      CardModel(suit: Suit.clubs, rank: Rank.king, id: 2),
      CardModel(suit: Suit.spades, rank: Rank.ten, id: 3),
    ];
    final state = GameState(roomId: 'r', currentTurnPlayerId: 'p', hands: hand, deskCards: []);
    final play = ai.choosePlay(state, hand);
    expect(play.isNotEmpty, isTrue);
    expect(play.first.rank.index, equals(Rank.king.index));
  });
}
