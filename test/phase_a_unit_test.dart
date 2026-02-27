import 'package:flutter_test/flutter_test.dart';
import 'package:aa_doudizhu/domain/game_logic/card.dart';

void main() {
  test('CardModel toJson/fromJson roundtrip', () {
    final c = CardModel(suit: Suit.spades, rank: Rank.king, id: 42, isFaceUp: true);
    final json = c.toJson();
    final c2 = CardModel.fromJson(json);
    expect(c2.suit, c.suit);
    expect(c2.rank, c.rank);
    expect(c2.id, c.id);
    expect(c2.isFaceUp, c.isFaceUp);
  });
}
