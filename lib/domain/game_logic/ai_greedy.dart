import 'package:aa_doudizhu/domain/game_logic/ai.dart';
import 'package:aa_doudizhu/domain/game_logic/card.dart';
import 'package:aa_doudizhu/domain/game_logic/card_type.dart';
import 'package:aa_doudizhu/domain/game_logic/game_state.dart';

/// 简单贪心 AI：选单张时出牌点最高的牌（标准斗地主顺序：3 < … < K < 2 < 小王 < 大王）
class GreedyAI implements AIEngine {
  @override
  List<CardModel> choosePlay(GameState state, List<CardModel> hand) {
    if (hand.isEmpty) return [];
    final sorted = List<CardModel>.from(hand)
      ..sort((a, b) => CardTypeDetector.rankValue(b.rank).compareTo(CardTypeDetector.rankValue(a.rank)));
    return [sorted.first];
  }
}
