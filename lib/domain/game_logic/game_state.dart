import 'package:aa_doudizhu/domain/game_logic/card.dart';
import 'package:aa_doudizhu/data/models/user.dart';
import 'package:aa_doudizhu/data/models/nft_card.dart';
import 'package:aa_doudizhu/domain/game_logic/nft_effects.dart';

enum GamePhase { waiting, dealing, bidding, playing, scoring, finished }

enum PlayerRole { farmer, landlord, undefined }

class PlayerState {
  final String userId;
  final User? user;
  final List<CardModel> handCards;
  final PlayerRole role;
  final bool isAI;
  final bool isConnected;
  final int score;
  final List<NFTCard> activeNFTs;

  PlayerState({
    required this.userId,
    this.user,
    required this.handCards,
    this.role = PlayerRole.undefined,
    this.isAI = false,
    this.isConnected = true,
    this.score = 0,
    this.activeNFTs = const [],
  });

  PlayerState copyWith({
    String? userId,
    User? user,
    List<CardModel>? handCards,
    PlayerRole? role,
    bool? isAI,
    bool? isConnected,
    int? score,
    List<NFTCard>? activeNFTs,
  }) {
    return PlayerState(
      userId: userId ?? this.userId,
      user: user ?? this.user,
      handCards: handCards ?? this.handCards,
      role: role ?? this.role,
      isAI: isAI ?? this.isAI,
      isConnected: isConnected ?? this.isConnected,
      score: score ?? this.score,
      activeNFTs: activeNFTs ?? this.activeNFTs,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'user': user?.toJson(),
      'handCards': handCards.map((c) => c.toJson()).toList(),
      'role': role.index,
      'isAI': isAI,
      'isConnected': isConnected,
      'score': score,
      'activeNFTs': activeNFTs.map((nft) => nft.toJson()).toList(),
    };
  }

  factory PlayerState.fromJson(Map<String, dynamic> json) {
    return PlayerState(
      userId: json['userId'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      handCards: (json['handCards'] as List<dynamic>? ?? [])
          .map((e) => CardModel.fromJson(e)).toList(),
      role: PlayerRole.values[json['role'] ?? 0],
      isAI: json['isAI'] ?? false,
      isConnected: json['isConnected'] ?? true,
      score: json['score'] ?? 0,
      activeNFTs: (json['activeNFTs'] as List<dynamic>? ?? [])
          .map((e) => NFTCard.fromJson(e)).toList(),
    );
  }
}

class PlayRecord {
  final String playerId;
  final List<CardModel> cards;
  final DateTime timestamp;
  final int multiplierContribution;

  PlayRecord({
    required this.playerId,
    required this.cards,
    required this.timestamp,
    this.multiplierContribution = 1,
  });

  Map<String, dynamic> toJson() {
    return {
      'playerId': playerId,
      'cards': cards.map((c) => c.toJson()).toList(),
      'timestamp': timestamp.toIso8601String(),
      'multiplierContribution': multiplierContribution,
    };
  }

  factory PlayRecord.fromJson(Map<String, dynamic> json) {
    return PlayRecord(
      playerId: json['playerId'],
      cards: (json['cards'] as List<dynamic>? ?? [])
          .map((e) => CardModel.fromJson(e)).toList(),
      timestamp: DateTime.parse(json['timestamp']),
      multiplierContribution: json['multiplierContribution'] ?? 1,
    );
  }
}

class GameState {
  final String roomId;
  final GamePhase currentPhase;
  final Map<String, PlayerState> players;
  final String currentTurnPlayerId;
  final List<CardModel> deskCards;
  final List<CardModel> lastPlay;
  final String? lastPlayPlayerId;
  final int baseMultiplier;
  final int totalMultiplier;
  final List<PlayRecord> playHistory;
  final String? landlordPlayerId;
  final DateTime createdAt;
  final DateTime? startedAt;
  final DateTime? finishedAt;

  GameState({
    required this.roomId,
    this.currentPhase = GamePhase.waiting,
    required this.players,
    required this.currentTurnPlayerId,
    this.deskCards = const [],
    this.lastPlay = const [],
    this.lastPlayPlayerId,
    this.baseMultiplier = 1,
    this.totalMultiplier = 1,
    this.playHistory = const [],
    this.landlordPlayerId,
    DateTime? createdAt,
    this.startedAt,
    this.finishedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  PlayerState? getCurrentPlayer() {
    return players[currentTurnPlayerId];
  }

  List<PlayerState> getActivePlayers() {
    return players.values.where((p) => p.isConnected || p.isAI).toList();
  }

  List<PlayerState> getHumanPlayers() {
    return players.values.where((p) => !p.isAI).toList();
  }

  List<PlayerState> getAIPlayers() {
    return players.values.where((p) => p.isAI).toList();
  }

  bool hasActiveNFTs(String playerId) {
    final player = players[playerId];
    return player?.activeNFTs.isNotEmpty ?? false;
  }

  int calculateNFTMultiplier(String playerId, List<CardModel> play) {
    return NFTEffectManager.calculateTotalMultiplier(play, this, playerId);
  }

  List<String> getActiveNFTEffects(String playerId, List<CardModel> play) {
    return NFTEffectManager.getActiveEffectDescriptions(play, this, playerId);
  }

  GameState copyWith({
    String? roomId,
    GamePhase? currentPhase,
    Map<String, PlayerState>? players,
    String? currentTurnPlayerId,
    List<CardModel>? deskCards,
    List<CardModel>? lastPlay,
    String? lastPlayPlayerId,
    int? baseMultiplier,
    int? totalMultiplier,
    List<PlayRecord>? playHistory,
    String? landlordPlayerId,
    DateTime? createdAt,
    DateTime? startedAt,
    DateTime? finishedAt,
  }) {
    return GameState(
      roomId: roomId ?? this.roomId,
      currentPhase: currentPhase ?? this.currentPhase,
      players: players ?? this.players,
      currentTurnPlayerId: currentTurnPlayerId ?? this.currentTurnPlayerId,
      deskCards: deskCards ?? this.deskCards,
      lastPlay: lastPlay ?? this.lastPlay,
      lastPlayPlayerId: lastPlayPlayerId ?? this.lastPlayPlayerId,
      baseMultiplier: baseMultiplier ?? this.baseMultiplier,
      totalMultiplier: totalMultiplier ?? this.totalMultiplier,
      playHistory: playHistory ?? this.playHistory,
      landlordPlayerId: landlordPlayerId ?? this.landlordPlayerId,
      createdAt: createdAt ?? this.createdAt,
      startedAt: startedAt ?? this.startedAt,
      finishedAt: finishedAt ?? this.finishedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'roomId': roomId,
      'currentPhase': currentPhase.index,
      'players': players.map((k, v) => MapEntry(k, v.toJson())),
      'currentTurnPlayerId': currentTurnPlayerId,
      'deskCards': deskCards.map((c) => c.toJson()).toList(),
      'lastPlay': lastPlay.map((c) => c.toJson()).toList(),
      'lastPlayPlayerId': lastPlayPlayerId,
      'baseMultiplier': baseMultiplier,
      'totalMultiplier': totalMultiplier,
      'playHistory': playHistory.map((r) => r.toJson()).toList(),
      'landlordPlayerId': landlordPlayerId,
      'createdAt': createdAt.toIso8601String(),
      'startedAt': startedAt?.toIso8601String(),
      'finishedAt': finishedAt?.toIso8601String(),
    };
  }

  factory GameState.fromJson(Map<String, dynamic> json) {
    return GameState(
      roomId: json['roomId'],
      currentPhase: GamePhase.values[json['currentPhase'] ?? 0],
      players: Map<String, PlayerState>.from(
        (json['players'] as Map<String, dynamic>?)?.map(
          (k, v) => MapEntry(k, PlayerState.fromJson(v)),
        ) ?? {},
      ),
      currentTurnPlayerId: json['currentTurnPlayerId'] ?? '',
      deskCards: (json['deskCards'] as List<dynamic>? ?? [])
          .map((e) => CardModel.fromJson(e)).toList(),
      lastPlay: (json['lastPlay'] as List<dynamic>? ?? [])
          .map((e) => CardModel.fromJson(e)).toList(),
      lastPlayPlayerId: json['lastPlayPlayerId'],
      baseMultiplier: json['baseMultiplier'] ?? 1,
      totalMultiplier: json['totalMultiplier'] ?? 1,
      playHistory: (json['playHistory'] as List<dynamic>? ?? [])
          .map((e) => PlayRecord.fromJson(e)).toList(),
      landlordPlayerId: json['landlordPlayerId'],
      createdAt: DateTime.parse(json['createdAt']),
      startedAt: json['startedAt'] != null ? DateTime.parse(json['startedAt']) : null,
      finishedAt: json['finishedAt'] != null ? DateTime.parse(json['finishedAt']) : null,
    );
  }
}
