import 'package:flutter/material.dart';
import 'package:aa_doudizhu/domain/game_logic/card.dart';
import 'package:aa_doudizhu/core/theme.dart';

class CardWidget extends StatelessWidget {
  final CardModel card;
  final double width;
  final double height;
  final bool isSelectable;
  final bool isSelected;
  final VoidCallback? onTap;

  const CardWidget({
    Key? key,
    required this.card,
    this.width = 60,
    this.height = 84,
    this.isSelectable = true,
    this.isSelected = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: width,
      height: height,
      child: GestureDetector(
        onTap: isSelectable ? onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              if (isSelected)
                BoxShadow(
                  color: kGold.withOpacity(0.6),
                  blurRadius: 8,
                  spreadRadius: 2,
                )
              else
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              children: [
                // 卡牌背景
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _getSuitColor().withOpacity(0.9),
                        _getSuitColor().withOpacity(0.7),
                      ],
                    ),
                    border: Border.all(
                      color: isSelected ? kGold : Colors.white.withOpacity(0.3),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                ),
                
                // 卡牌内容
                if (card.isFaceUp)
                  _buildCardFace()
                else
                  _buildCardBack(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardFace() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 牌面图标
        Expanded(
          flex: 3,
          child: Center(
            child: Text(
              _getRankDisplay(),
              style: TextStyle(
                fontSize: width * 0.4,
                fontWeight: FontWeight.bold,
                color: _getRankColor(),
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.5),
                    offset: const Offset(1, 1),
                    blurRadius: 2,
                  ),
                ],
              ),
            ),
          ),
        ),
        
        // 花色图标
        Expanded(
          flex: 2,
          child: Center(
            child: Icon(
              _getSuitIcon(),
              color: _getSuitColor(),
              size: width * 0.3,
            ),
          ),
        ),
        
        // 小标记
        Positioned(
          top: 4,
          left: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getRankDisplay(),
                style: TextStyle(
                  fontSize: width * 0.15,
                  fontWeight: FontWeight.bold,
                  color: _getRankColor(),
                ),
              ),
              Icon(
                _getSuitIcon(),
                color: _getSuitColor(),
                size: width * 0.12,
              ),
            ],
          ),
        ),
        
        // 右下角小标记（倒置）
        Positioned(
          bottom: 4,
          right: 4,
          child: Transform.rotate(
            angle: 3.14159, // 180度
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getRankDisplay(),
                  style: TextStyle(
                    fontSize: width * 0.15,
                    fontWeight: FontWeight.bold,
                    color: _getRankColor(),
                  ),
                ),
                Icon(
                  _getSuitIcon(),
                  color: _getSuitColor(),
                  size: width * 0.12,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCardBack() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            kSurface.withOpacity(0.9),
            kSurface.withOpacity(0.7),
          ],
        ),
        border: Border.all(
          color: kGold.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          // 背景图案
          Center(
            child: Icon(
              Icons.style,
              color: kGold.withOpacity(0.3),
              size: width * 0.4,
            ),
          ),
          
          // 装饰边框
          Positioned.fill(
            child: CustomPaint(
              painter: CardBackPainter(width: width, height: height),
            ),
          ),
        ],
      ),
    );
  }

  String _getRankDisplay() {
    switch (card.rank) {
      case Rank.three:
        return '3';
      case Rank.four:
        return '4';
      case Rank.five:
        return '5';
      case Rank.six:
        return '6';
      case Rank.seven:
        return '7';
      case Rank.eight:
        return '8';
      case Rank.nine:
        return '9';
      case Rank.ten:
        return '10';
      case Rank.jack:
        return 'J';
      case Rank.queen:
        return 'Q';
      case Rank.king:
        return 'K';
      case Rank.ace:
        return 'A';
      case Rank.two:
        return '2';
      case Rank.smallJoker:
        return '🃏';
      case Rank.bigJoker:
        return '🎭';
    }
  }

  Color _getRankColor() {
    if (card.rank == Rank.smallJoker) {
      return Colors.black;
    }
    if (card.rank == Rank.bigJoker) {
      return Colors.red;
    }
    
    switch (card.suit) {
      case Suit.hearts:
      case Suit.diamonds:
        return Colors.red;
      case Suit.clubs:
      case Suit.spades:
        return Colors.black;
    }
  }

  Color _getSuitColor() {
    if (card.rank == Rank.smallJoker) {
      return Colors.black87;
    }
    if (card.rank == Rank.bigJoker) {
      return Colors.redAccent;
    }
    
    switch (card.suit) {
      case Suit.hearts:
        return Colors.red;
      case Suit.diamonds:
        return Colors.redAccent;
      case Suit.clubs:
        return Colors.black87;
      case Suit.spades:
        return Colors.black;
    }
  }

  IconData _getSuitIcon() {
    switch (card.suit) {
      case Suit.hearts:
        return Icons.favorite;
      case Suit.diamonds:
        return Icons.diamond;
      case Suit.clubs:
        return Icons.grain;
      case Suit.spades:
        return Icons spa;
    }
  }
}

class CardBackPainter extends CustomPainter {
  final double width;
  final double height;

  CardBackPainter({required this.width, required this.height});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = kGold.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // 绘制装饰性边框
    final rect = Rect.fromLTWH(4, 4, width - 8, height - 8);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(4)),
      paint,
    );

    // 绘制角落装饰
    final cornerPaint = Paint()
      ..color = kGold.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    // 左上角
    canvas.drawCircle(const Offset(8, 8), 2, cornerPaint);
    // 右上角
    canvas.drawCircle(Offset(width - 8, 8), 2, cornerPaint);
    // 左下角
    canvas.drawCircle(Offset(8, height - 8), 2, cornerPaint);
    // 右下角
    canvas.drawCircle(Offset(width - 8, height - 8), 2, cornerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
