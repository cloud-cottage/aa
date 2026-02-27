import 'package:aa_doudizhu/domain/game_logic/ai.dart';
import 'package:aa_doudizhu/domain/game_logic/card.dart';
import 'package:aa_doudizhu/domain/game_logic/game_state.dart';

// A very simple greedy AI: choose the highest-rank single card to play.
class GreedyAI implements AIEngine {
  @override
  List<CardModel> choosePlay(GameState state, List<CardModel> hand) {
    if (hand.isEmpty) return [];
    // Work on a copy to avoid mutating the caller's list
    final List<CardModel> sorted = List<CardModel>.from(hand)
      ..sort((a, b) => b.rank.index.compareTo(a.rank.index));
    // Return the highest card as the single-card play (placeholder for Phase B expansion)
    return [sorted.first];
  }
}
