import 'package:flutter/material.dart';
import 'package:aa_doudizhu/domain/game_logic/card.dart';

class PlayingCard extends StatelessWidget {
  final CardModel card;
  final double width;
  final double height;
  final bool isSelected;
  final VoidCallback? onTap;
  const PlayingCard({Key? key, required this.card, this.width = 72, this.height = 96, this.isSelected = false, this.onTap}) : super(key: key);

  String _rankLabel(Rank r) {
    switch (r) {
      case Rank.two: return '2';
      case Rank.three: return '3';
      case Rank.four: return '4';
      case Rank.five: return '5';
      case Rank.six: return '6';
      case Rank.seven: return '7';
      case Rank.eight: return '8';
      case Rank.nine: return '9';
      case Rank.ten: return '10';
      case Rank.jack: return 'J';
      case Rank.queen: return 'Q';
      case Rank.king: return 'K';
      case Rank.smallJoker: return 'SJ';
      case Rank.bigJoker: return 'BJ';
    }
  }

  String _suitSymbol(Suit s) {
    switch (s) {
      case Suit.clubs: return '♣';
      case Suit.diamonds: return '♦';
      case Suit.hearts: return '♥';
      case Suit.spades: return '♠';
    }
  }

  @override
  Widget build(BuildContext context) {
    final rank = _rankLabel(card.rank);
    final suit = _suitSymbol(card.suit);
    final cardWidget = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: const LinearGradient(
          colors: [Color(0xFF1F1F1F), Color(0xFF0A0A0A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: isSelected ? Colors.amber : Colors.white24, width: isSelected ? 2 : 1),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(rank, style: const TextStyle(fontSize: 18, color: Colors.white)),
            SizedBox(height: 6),
            Text(suit, style: const TextStyle(fontSize: 22, color: Colors.white)),
          ],
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: cardWidget);
    }
    return cardWidget;
  }
}
