import 'package:flutter_test/flutter_test.dart';
import 'package:aa_doudizhu/domain/game_logic/card.dart';
import 'package:aa_doudizhu/domain/game_logic/deck.dart';
import 'package:aa_doudizhu/domain/game_logic/doudizhu_round.dart';

void main() {
  test('createFullDeck returns 54 cards', () {
    final deck = Deck.createFullDeck();
    expect(deck.length, 54);
  });

  test('Deck.deal splits 54 cards correctly', () {
    final deck = Deck.createFullDeck();
    final dealt = Deck.deal(deck);
    expect(dealt.length, 4);
    expect(dealt[0].length, 17);
    expect(dealt[1].length, 17);
    expect(dealt[2].length, 17);
    expect(dealt[3].length, 3);
  });

  test('DoudizhuRound.newGame has 20 cards for landlord', () {
    final round = DoudizhuRound.newGame(randomLandlord: 0);
    expect(round.handAt(0).length, 20);
    expect(round.handAt(1).length, 17);
    expect(round.handAt(2).length, 17);
  });
}
