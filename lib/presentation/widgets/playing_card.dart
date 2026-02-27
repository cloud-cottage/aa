import 'package:flutter/material.dart';
import 'package:aa_doudizhu/domain/game_logic/card.dart';
import 'package:aa_doudizhu/core/theme.dart';

class PlayingCard extends StatelessWidget {
  final CardModel card;
  final double width;
  final double height;
  final bool isSelected;
  final VoidCallback? onTap;
  const PlayingCard({Key? key, required this.card, this.width = 72, this.height = 96, this.isSelected = false, this.onTap}) : super(key: key);

  Color get _suitColor {
    return (card.suit == Suit.hearts || card.suit == Suit.diamonds) 
        ? kRed 
        : Colors.white;
  }

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
      case Rank.smallJoker: return '小王';
      case Rank.bigJoker: return '大王';
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
    final borderColor = isSelected ? kGold : Colors.white24;
    final borderWidth = isSelected ? 2.5 : 1.0;
    
    final cardWidget = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: const LinearGradient(
          colors: [Color(0xFF2A2A2A), Color(0xFF0F0F0F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: borderColor, width: borderWidth),
        boxShadow: [
          BoxShadow(
            color: isSelected ? kGold.withOpacity(0.3) : Colors.black.withOpacity(0.3),
            blurRadius: isSelected ? 8 : 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Corner rank
          Positioned(
            top: 2,
            left: 4,
            child: Text(rank, style: TextStyle(fontSize: 14, color: _suitColor, fontWeight: FontWeight.bold)),
          ),
          // Center suit
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(rank, style: TextStyle(fontSize: width * 0.28, color: _suitColor, fontWeight: FontWeight.bold)),
                Text(suit, style: TextStyle(fontSize: width * 0.35, color: _suitColor)),
              ],
            ),
          ),
          // Corner suit
          Positioned(
            bottom: 2,
            right: 4,
            child: Transform.rotate(
              angle: 3.14159,
              child: Text(suit, style: TextStyle(fontSize: 14, color: _suitColor)),
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: cardWidget);
    }
    return cardWidget;
  }
}
