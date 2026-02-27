import 'dart:convert';

import 'package:aa_doudizhu/data/models/user.dart';
import 'package:aa_doudizhu/data/models/room.dart';
import 'package:aa_doudizhu/data/models/nft_card.dart';

// In-memory local storage skeleton (Phase A)
class LocalStore {
  static final LocalStore _instance = LocalStore._internal();
  factory LocalStore() => _instance;
  LocalStore._internal();

  final Map<String, String> _store = {};

  Future<void> init() async {
    // no-op for skeleton
  }

  // User
  Future<void> saveUser(User user) async {
    _store['user'] = jsonEncode(user.toJson());
  }

  User? loadUser() {
    final s = _store['user'];
    if (s == null) return null;
    return User.fromJson(jsonDecode(s));
  }

  // Room
  Future<void> saveRoom(Room room) async {
    _store['room'] = jsonEncode(room.toJson());
  }

  Room? loadRoom() {
    final s = _store['room'];
    if (s == null) return null;
    return Room.fromJson(jsonDecode(s));
  }

  // NFT Cards (list)
  Future<void> saveNftCards(List<NFTCard> cards) async {
    final list = cards.map((c) => c.toJson()).toList();
    _store['nft_cards'] = jsonEncode(list);
  }

  List<NFTCard> loadNftCards() {
    final s = _store['nft_cards'];
    if (s == null) return [];
    final list = List<Map<String, dynamic>>.from(jsonDecode(s));
    return list.map((m) => NFTCard.fromJson(m)).toList();
  }
}
