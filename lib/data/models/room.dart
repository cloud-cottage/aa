class Room {
  final String roomId;
  final String hostUserId;
  List<String> players;
  Map<String, bool> playerConnected; // playerId -> isConnected
  String state; // waiting/ready/playing/finished
  String? entryTokenId; // NFT tokenId required for private rooms

  Room({required this.roomId, required this.hostUserId, required this.players, this.state = 'waiting', this.entryTokenId, Map<String, bool>? playerConnected}) 
    : playerConnected = playerConnected ?? {for (var p in players) p: true};

  bool isPlayerConnected(String playerId) => playerConnected[playerId] ?? false;

  void setPlayerDisconnected(String playerId) {
    playerConnected[playerId] = false;
  }

  void replaceWithBot(String playerId) {
    final index = players.indexOf(playerId);
    if (index != -1) {
      players[index] = 'bot_$playerId';
      playerConnected['bot_$playerId'] = true;
      playerConnected.remove(playerId);
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'roomId': roomId,
      'hostUserId': hostUserId,
      'players': players,
      'playerConnected': playerConnected,
      'state': state,
      'entryTokenId': entryTokenId,
    };
  }

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      roomId: json['roomId'],
      hostUserId: json['hostUserId'],
      players: List<String>.from(json['players'] ?? []),
      playerConnected: json['playerConnected'] != null ? Map<String, bool>.from(json['playerConnected']) : null,
      state: json['state'] ?? 'waiting',
      entryTokenId: json['entryTokenId'],
    );
  }
}
