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
      expect(user.avatarPath, startsWith('assets/avatars/'));
    });

    test('用户ID应该是唯一的', () {
      final users = userDatabase.getAllUsers();
      final userIds = users.map((user) => user.userId).toSet();
      expect(userIds.length, 80);
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
    });

    test('邮箱格式应该正确', () {
      final users = userDatabase.getAllUsers();
      for (final user in users.take(5)) {
        expect(user.email, matches(RegExp(r'^[^@]+@[^@]+\.[^@]+$')));
      }
    });

    test('头像路径应该正确', () {
      final users = userDatabase.getAllUsers();
      for (final user in users.take(5)) {
        expect(user.avatarPath, isNotNull);
        expect(user.avatarPath, startsWith('assets/avatars/'));
        expect(user.avatarPath, endsWith('.jpg'));
      }
    });

    test('获取指定数量的随机用户', () {
      final randomUsers = userDatabase.getRandomUsers(5);
      expect(randomUsers.length, 5);
      
      final userIds = randomUsers.map((user) => user.userId).toSet();
      expect(userIds.length, 5);
    });

    test('搜索用户功能', () {
      final searchResults = userDatabase.searchUsers('轻舞');
      expect(searchResults.isNotEmpty, isTrue);
      
      for (final user in searchResults) {
        expect(user.displayName, contains('轻舞'));
      }
    });

    test('获取统计信息', () {
      final stats = userDatabase.getStatistics();
      
      expect(stats['totalUsers'], 80);
      expect(stats['totalGold'], greaterThan(0));
      expect(stats['averageGold'], greaterThan(0));
      expect(stats['maxGold'], greaterThan(stats['minGold']));
    });
  });
}
