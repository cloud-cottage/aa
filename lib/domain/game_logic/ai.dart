import 'package:aa_doudizhu/domain/game_logic/card.dart';
import 'package:aa_doudizhu/domain/game_logic/game_state.dart';

abstract class AIEngine {
  List<CardModel> choosePlay(GameState state, List<CardModel> hand);
}
