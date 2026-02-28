enum Suit { clubs, diamonds, hearts, spades }

enum Rank {
  three, four, five, six, seven, eight, nine, ten,
  jack, queen, king, ace, two, smallJoker, bigJoker
}

class CardModel {
  final Suit suit;
  final Rank rank;
  final int id;
  bool isFaceUp;

  CardModel({required this.suit, required this.rank, required this.id, this.isFaceUp = true});

  Map<String, dynamic> toJson() {
    return {
      'suit': suit.index,
      'rank': rank.index,
      'id': id,
      'isFaceUp': isFaceUp,
    };
  }

  factory CardModel.fromJson(Map<String, dynamic> json) {
    return CardModel(
      suit: Suit.values[json['suit'] ?? 0],
      rank: Rank.values[json['rank'] ?? 0],
      id: json['id'] ?? 0,
      isFaceUp: json['isFaceUp'] ?? true,
    );
  }
}
