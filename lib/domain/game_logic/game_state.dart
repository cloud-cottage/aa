import 'package:aa_doudizhu/domain/game_logic/card.dart';

class GameState {
  final String roomId;
  String currentTurnPlayerId;
  List<CardModel> hands;
  List<CardModel> deskCards;
  int multipliers;
  String? winner;

  GameState({required this.roomId,
    required this.currentTurnPlayerId,
    required this.hands,
    required this.deskCards,
    this.multipliers = 1,
    this.winner});

  Map<String, dynamic> toJson() {
    return {
      'roomId': roomId,
      'currentTurnPlayerId': currentTurnPlayerId,
      'hands': hands.map((c) => c.toJson()).toList(),
      'deskCards': deskCards.map((c) => c.toJson()).toList(),
      'multipliers': multipliers,
      'winner': winner,
    };
  }

  factory GameState.fromJson(Map<String, dynamic> json) {
    return GameState(
      roomId: json['roomId'],
      currentTurnPlayerId: json['currentTurnPlayerId'],
      hands: (json['hands'] as List<dynamic>? ?? []).map((e) => CardModel.fromJson(e)).toList(),
      deskCards: (json['deskCards'] as List<dynamic>? ?? []).map((e) => CardModel.fromJson(e)).toList(),
      multipliers: json['multipliers'] ?? 1,
      winner: json['winner'],
    );
  }
}
