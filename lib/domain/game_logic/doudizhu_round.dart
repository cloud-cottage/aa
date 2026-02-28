import 'dart:math';
import 'package:aa_doudizhu/domain/game_logic/card.dart';
import 'package:aa_doudizhu/domain/game_logic/card_type.dart';
import 'package:aa_doudizhu/domain/game_logic/deck.dart';

/// 单局斗地主对局状态
class DoudizhuRound {
  final List<List<CardModel>> hands;
  final int landlordIndex;
  final List<CardModel> lastPlay;
  final int? lastPlayPlayerIndex;
  final int currentPlayerIndex;
  final int multipliers;
  final String? winnerPlayerId;

  const DoudizhuRound({
    required this.hands,
    required this.landlordIndex,
    this.lastPlay = const [],
    this.lastPlayPlayerIndex,
    required this.currentPlayerIndex,
    this.multipliers = 1,
    this.winnerPlayerId,
  });

  /// 是否当前玩家领头（上家出牌后都过了，或刚开局）
  bool get isCurrentPlayerLeading =>
      lastPlay.isEmpty || lastPlayPlayerIndex == currentPlayerIndex;

  List<CardModel> handAt(int i) => hands[i];

  /// 玩家出牌后的新状态，[multiplierFactor] 为本次出牌的倍数（炸弹×2 等）
  DoudizhuRound withPlay(int playerIndex, List<CardModel> cards, {int multiplierFactor = 1}) {
    final newHands = hands.map((h) => List<CardModel>.from(h)).toList();
    for (final c in cards) {
      newHands[playerIndex].removeWhere((x) => x.id == c.id);
    }
    final nextPlayer = (playerIndex + 1) % 3;
    final isWin = newHands[playerIndex].isEmpty;
    return DoudizhuRound(
      hands: newHands,
      landlordIndex: landlordIndex,
      lastPlay: cards,
      lastPlayPlayerIndex: playerIndex,
      currentPlayerIndex: isWin ? playerIndex : nextPlayer,
      multipliers: multipliers * multiplierFactor,
      winnerPlayerId: isWin ? 'p$playerIndex' : winnerPlayerId,
    );
  }

  /// 玩家过牌后的新状态
  DoudizhuRound withPass(int playerIndex) {
    final nextPlayer = (playerIndex + 1) % 3;
    final nextIsLeading = nextPlayer == lastPlayPlayerIndex;
    return DoudizhuRound(
      hands: hands,
      landlordIndex: landlordIndex,
      lastPlay: nextIsLeading ? [] : lastPlay,
      lastPlayPlayerIndex: nextIsLeading ? null : lastPlayPlayerIndex,
      currentPlayerIndex: nextPlayer,
      multipliers: multipliers,
      winnerPlayerId: winnerPlayerId,
    );
  }

  /// 新建一局：洗牌、发牌、随机地主、底牌给地主
  factory DoudizhuRound.newGame({int? randomLandlord, Random? random}) {
    final rng = random ?? Random();
    final shuffled = Deck(random: rng).shuffledCards();
    final d = Deck.deal(shuffled);
    if (d.isEmpty) return DoudizhuRound(hands: [[], [], []], landlordIndex: 0);

    final p0 = List<CardModel>.from(d[0]);
    final p1 = List<CardModel>.from(d[1]);
    final p2 = List<CardModel>.from(d[2]);
    final landcards = d[3];
    final landlord = randomLandlord ?? rng.nextInt(3);
    final hands = [p0, p1, p2];
    hands[landlord].addAll(landcards);
    for (final h in hands) {
      h.sort((a, b) =>
          CardTypeDetector.rankValue(a.rank).compareTo(CardTypeDetector.rankValue(b.rank)));
    }

    return DoudizhuRound(
      hands: hands,
      landlordIndex: landlord,
      currentPlayerIndex: landlord,
      lastPlay: [],
      lastPlayPlayerIndex: null,
    );
  }
}
