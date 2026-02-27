import 'package:flutter/material.dart';
import 'package:aa_doudizhu/domain/game_logic/card.dart';
import 'package:aa_doudizhu/presentation/widgets/playing_card.dart';

class CardDeck extends StatelessWidget {
  final List<CardModel> cards;
  final double cardWidth;
  final double cardHeight;
  final double spacing;
  final Set<int> selectedIndices;
  final void Function(int)? onCardTap;
  const CardDeck({Key? key, required this.cards, this.cardWidth = 72, this.cardHeight = 96, this.spacing = 8, this.selectedIndices = const {}, this.onCardTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: spacing,
      runSpacing: spacing,
      children: List.generate(cards.length, (idx) {
        final c = cards[idx];
        return PlayingCard(
          card: c,
          width: cardWidth,
          height: cardHeight,
          isSelected: selectedIndices.contains(idx),
          onTap: onCardTap != null ? () => onCardTap!(idx) : null,
        );
      }),
    );
  }
}
