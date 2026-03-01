import 'package:flutter_test/flutter_test.dart';
import 'package:aa_doudizhu/data/services/user_database.dart';
import 'package:aa_doudizhu/data/models/user.dart';

void main() {
  group('用户数据库测试', () {
    late UserDatabase userDatabase;

    setUp(() {
      userDatabase = UserDatabase();
      userDatabase.initialize();
    });

    test('应该生成80个用户', () {
      final users = userDatabase.getAllUsers();
      expect(users.length, 80);
    });

    test('随机获取用户应该返回有效用户', () {
      final user = userDatabase.getRandomUser();
      expect(user, isNotNull);
      expect(user.userId, startsWith('user_'));
      expect(user.displayName, isNotEmpty);
      expect(user.goldBalance, greaterThanOrEqualTo(100));
      expect(user.goldBalance, lessThanOrEqualTo(10000));
      expect(user.avatarPath, isNotNull);
      expect(user.avatarPath, startsWith('avatar/'));
    });

    test('用户ID应该是唯一的', () {
      final users = userDatabase.getAllUsers();
      final userIds = users.map((user) => user.userId).toSet();
      expect(userIds.length, 80); // 所有ID都应该是唯一的
    });

    test('应该包含指定的用户名和昵称', () {
      final users = userDatabase.getAllUsers();
      
      // 检查一些特定的用户
      final happyBoy = users.firstWhere(
        (user) => user.email?.startsWith('happyboy1969') == true,
        orElse: () => User(userId: 'test', displayName: 'test'),
      );
      expect(happyBoy.displayName, '轻舞飞扬');
      
      final jayChou = users.firstWhere(
        (user) => user.email?.startsWith('jaychou') == true,
        orElse: () => User(userId: 'test', displayName: 'test'),
      );
      expect(jayChou.displayName, '发如雪');
      
      final pokemon = users.firstWhere(
        (user) => user.email?.startsWith('pokemon') == true,
        orElse: () => User(userId: 'test', displayName: 'test'),
      );
      expect(pokemon.displayName, '皮卡丘');
    });

    test('邮箱格式应该正确', () {
      final users = userDatabase.getAllUsers();
      for (final user in users.take(10)) {
        expect(user.email, matches(RegExp(r'^[^@]+@[^@]+\.[^@]+$')));
      }
    });

    test('钱包地址格式应该正确', () {
      final users = userDatabase.getAllUsers();
      for (final user in users.take(10)) {
        expect(user.walletAddress, startsWith('0x'));
        expect(user.walletAddress!.length, 42); // 0x + 40个字符
      }
    });

    test('头像路径应该正确', () {
      final users = userDatabase.getAllUsers();
      for (final user in users) {
        expect(user.avatarPath, isNotNull);
        expect(user.avatarPath, startsWith('avatar/'));
        expect(user.avatarPath, endsWith('.jpg'));
      }
    });

    test('获取指定数量的随机用户', () {
      final randomUsers = userDatabase.getRandomUsers(5);
      expect(randomUsers.length, 5);
      
      // 检查用户是否唯一
      final userIds = randomUsers.map((user) => user.userId).toSet();
      expect(userIds.length, 5);
    });

    test('按金币余额排序', () {
      final sortedUsers = userDatabase.getUsersByGoldBalance(descending: true);
      
      // 验证排序
      for (int i = 0; i < sortedUsers.length - 1; i++) {
        expect(sortedUsers[i].goldBalance, greaterThanOrEqualTo(sortedUsers[i + 1].goldBalance));
      }
    });

    test('获取拥有NFT的用户', () {
      final usersWithNFT = userDatabase.getUsersWithNFTs();
      expect(usersWithNFT.isNotEmpty, isTrue);
      
      for (final user in usersWithNFT) {
        expect(user.nftOwnedTokenIds.isNotEmpty, isTrue);
      }
    });

    test('按金币范围筛选用户', () {
      final usersInRange = userDatabase.getUsersByGoldRange(1000, 5000);
      
      for (final user in usersInRange) {
        expect(user.goldBalance, greaterThanOrEqualTo(1000));
        expect(user.goldBalance, lessThanOrEqualTo(5000));
      }
    });

    test('搜索用户功能', () {
      final searchResults = userDatabase.searchUsers('轻舞');
      expect(searchResults.isNotEmpty, isTrue);
      
      for (final user in searchResults) {
        expect(user.displayName, contains('轻舞'));
      }
    });

    test('按用户名搜索功能', () {
      final searchResults = userDatabase.searchByUsername('jaychou');
      expect(searchResults.isNotEmpty, isTrue);
      
      for (final user in searchResults) {
        expect(user.email?.contains('jaychou'), isTrue);
      }
    });

    test('获取统计信息', () {
      final stats = userDatabase.getStatistics();
      
      expect(stats['totalUsers'], 80);
      expect(stats['totalGold'], greaterThan(0));
      expect(stats['usersWithNFT'], greaterThanOrEqualTo(0));
      expect(stats['averageGold'], greaterThan(0));
      expect(stats['maxGold'], greaterThan(stats['minGold']));
    });

    test('选择玩家身份应该优先选择金币较多的用户', () {
      final playerIdentity = userDatabase.selectPlayerIdentity();
      expect(playerIdentity.goldBalance, greaterThanOrEqualTo(1000));
    });

    test('为房间选择合适的玩家', () {
      final roomPlayers = userDatabase.selectRoomPlayers(3, minGold: 500);
      expect(roomPlayers.length, 3);
      
      for (final player in roomPlayers) {
        expect(player.goldBalance, greaterThanOrEqualTo(500));
      }
    });

    test('用户数据一致性', () {
      final user = userDatabase.getRandomUser();
      final sameUser = userDatabase.getUserById(user.userId);
      
      expect(sameUser, isNotNull);
      expect(sameUser!.userId, user.userId);
      expect(sameUser.displayName, user.displayName);
      expect(sameUser.goldBalance, user.goldBalance);
      expect(sameUser.email, user.email);
      expect(sameUser.walletAddress, user.walletAddress);
      expect(sameUser.nftOwnedTokenIds, user.nftOwnedTokenIds);
      expect(sameUser.avatarPath, user.avatarPath);
    });

    test('NFT Token ID格式', () {
      final users = userDatabase.getAllUsers();
      for (final user in users) {
        for (final tokenId in user.nftOwnedTokenIds) {
          expect(tokenId, startsWith('nft_'));
          expect(tokenId.length, greaterThanOrEqualTo(5)); // nft_ + 至少4位数字
        }
      }
    });

    test('金币分布合理性', () {
      final users = userDatabase.getAllUsers();
      final goldBalances = users.map((user) => user.goldBalance).toList();
      
      final avgGold = goldBalances.reduce((a, b) => a + b) / goldBalances.length;
      final minGold = goldBalances.reduce((a, b) => a < b ? a : b);
      final maxGold = goldBalances.reduce((a, b) => a > b ? a : b);
      
      expect(avgGold, greaterThan(1000)); // 平均金币应该合理
      expect(minGold, greaterThanOrEqualTo(100)); // 最小金币应该符合设定
      expect(maxGold, lessThanOrEqualTo(10000)); // 最大金币应该符合设定
    });

    test('头像分配应该是随机的', () {
      final users1 = userDatabase.getAllUsers();
      final userDatabase2 = UserDatabase();
      userDatabase2.initialize();
      final users2 = userDatabase2.getAllUsers();
      
      // 比较前10个用户的头像路径
      bool hasDifferentAvatar = false;
      for (int i = 0; i < 10; i++) {
        if (users1[i].avatarPath != users2[i].avatarPath) {
          hasDifferentAvatar = true;
          break;
        }
      }
      
      expect(hasDifferentAvatar, isTrue); // 应该有不同的头像分配
    });

    test('特定用户索引访问', () {
      final user = userDatabase.getUserByIndex(0);
      expect(user, isNotNull);
      expect(user!.userId, 'user_001');
      
      final invalidUser = userDatabase.getUserByIndex(100);
      expect(invalidUser, isNull);
    });
  });

  group('游戏引擎用户身份集成测试', () {
    test('游戏引擎应该能够获取随机用户身份', () {
      final gameEngine = GameEngine();
      gameEngine.initialize();
      
      final randomUser = gameEngine.getRandomUserIdentity();
      expect(randomUser, isNotNull);
      expect(randomUser.userId, startsWith('user_'));
      expect(randomUser.avatarPath, isNotNull);
    });

    test('游戏引擎应该能够获取多个随机用户身份', () {
      final gameEngine = GameEngine();
      gameEngine.initialize();
      
      final randomUsers = gameEngine.getRandomUserIdentities(3);
      expect(randomUsers.length, 3);
      
      // 验证用户唯一性
      final userIds = randomUsers.map((user) => user.userId).toSet();
      expect(userIds.length, 3);
    });
  });
}
