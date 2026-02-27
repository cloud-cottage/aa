class Room {
  final String roomId;
  final String hostUserId;
  List<String> players;
  String state; // waiting/ready/playing/finished
  String? entryTokenId; // NFT tokenId required for private rooms

  Room({required this.roomId, required this.hostUserId, required this.players, this.state = 'waiting', this.entryTokenId});

  Map<String, dynamic> toJson() {
    return {
      'roomId': roomId,
      'hostUserId': hostUserId,
      'players': players,
      'state': state,
      'entryTokenId': entryTokenId,
    };
  }

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      roomId: json['roomId'],
      hostUserId: json['hostUserId'],
      players: List<String>.from(json['players'] ?? []),
      state: json['state'] ?? 'waiting',
      entryTokenId: json['entryTokenId'],
    );
  }
}
