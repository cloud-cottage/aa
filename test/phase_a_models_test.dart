import 'package:flutter_test/flutter_test.dart';
import 'package:aa_doudizhu/data/models/user.dart';
import 'package:aa_doudizhu/data/models/room.dart';
import 'package:aa_doudizhu/data/models/nft_card.dart';

void main() {
  test('User toJson/fromJson', () {
    final user = User(userId: 'u1', displayName: 'Alice', email: 'alice@example.com', walletAddress: '0xABC', goldBalance: 100, nftOwnedTokenIds: ['t1','t2']);
    final json = user.toJson();
    final user2 = User.fromJson(json);
    expect(user2.userId, user.userId);
    expect(user2.displayName, user.displayName);
    expect(user2.email, user.email);
    expect(user2.walletAddress, user.walletAddress);
    expect(user2.goldBalance, user.goldBalance);
    expect(user2.nftOwnedTokenIds, user.nftOwnedTokenIds);
  });

  test('Room toJson/fromJson', () {
    final room = Room(roomId: 'r1', hostUserId: 'u1', players: ['u1','u2'], state: 'waiting', entryTokenId: 't1');
    final json = room.toJson();
    final room2 = Room.fromJson(json);
    expect(room2.roomId, room.roomId);
    expect(room2.hostUserId, room.hostUserId);
    expect(room2.players, room.players);
    expect(room2.state, room.state);
    expect(room2.entryTokenId, room.entryTokenId);
  });

  test('NFTCard toJson/fromJson', () {
    final nft = NFTCard(tokenId: 'tk1', contractAddress: '0xCA', ownerAddress: '0xOWNER', metadata: {'name':'Test'}, mintedAt: DateTime.now());
    final json = nft.toJson();
    final nft2 = NFTCard.fromJson(json);
    expect(nft2.tokenId, nft.tokenId);
    expect(nft2.contractAddress, nft.contractAddress);
    expect(nft2.ownerAddress, nft.ownerAddress);
    expect(nft2.metadata['name'], nft.metadata['name']);
  });
}
