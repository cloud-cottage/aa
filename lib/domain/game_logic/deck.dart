import 'dart:math';
import 'package:aa_doudizhu/domain/game_logic/card.dart';

/// 标准斗地主牌组（54 张）
class Deck {
  final Random _random;

  Deck({Random? random}) : _random = random ?? Random();

  /// 生成并洗牌，返回 54 张牌的列表
  List<CardModel> shuffledCards() {
    final list = List<CardModel>.from(createFullDeck());
    for (var i = list.length - 1; i > 0; i--) {
      final j = _random.nextInt(i + 1);
      final t = list[i];
      list[i] = list[j];
      list[j] = t;
    }
    return list;
  }

  static List<CardModel> createFullDeck() {
    final cards = <CardModel>[];
    const ranks = [
      Rank.three, Rank.four, Rank.five, Rank.six, Rank.seven, Rank.eight,
      Rank.nine, Rank.ten, Rank.jack, Rank.queen, Rank.king, Rank.ace, Rank.two,
    ];
    int id = 0;
    for (final suit in Suit.values) {
      for (final rank in ranks) {
        cards.add(CardModel(suit: suit, rank: rank, id: id++));
      }
    }
    cards.add(CardModel(suit: Suit.clubs, rank: Rank.smallJoker, id: id++));
    cards.add(CardModel(suit: Suit.clubs, rank: Rank.bigJoker, id: id++));
    return cards;
  }


  /// 发牌：返回 [玩家0手牌, 玩家1手牌, 玩家2手牌, 底牌]
  /// 每人 17 张，底牌 3 张
  static List<List<CardModel>> deal(List<CardModel> deck) {
    if (deck.length != 54) return [];
    final list = List<CardModel>.from(deck);
    final p0 = list.sublist(0, 17);
    final p1 = list.sublist(17, 34);
    final p2 = list.sublist(34, 51);
    final landcards = list.sublist(51, 54);
    return [p0, p1, p2, landcards];
  }
}
