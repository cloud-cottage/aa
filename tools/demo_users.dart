import 'dart:io';
import 'package:aa_doudizhu/data/services/user_database.dart';
import 'package:aa_doudizhu/data/models/user.dart';

void main() {
  print('🎮 AA斗地主用户数据库演示\n');
  
  // 初始化用户数据库
  final userDatabase = UserDatabase();
  userDatabase.initialize();
  
  // 获取所有用户
  final allUsers = userDatabase.getAllUsers();
  print('📊 用户统计:');
  print('   总用户数: ${allUsers.length}');
  
  // 获取统计信息
  final stats = userDatabase.getStatistics();
  print('   总金币: ${stats['totalGold']}');
  print('   平均金币: ${stats['averageGold']}');
  print('   拥有NFT的用户: ${stats['usersWithNFT']}');
  print('   最高金币: ${stats['maxGold']}');
  print('   最低金币: ${stats['minGold']}');
  
  print('\n🎲 随机选择10个用户:');
  final randomUsers = userDatabase.getRandomUsers(10);
  for (int i = 0; i < randomUsers.length; i++) {
    final user = randomUsers[i];
    print('   ${i + 1}. ${user.displayName} (${user.userId})');
    print('      邮箱: ${user.email}');
    print('      金币: ${user.goldBalance}');
    print('      头像: ${user.avatarPath}');
    print('      NFT数量: ${user.nftOwnedTokenIds.length}');
    if (user.nftOwnedTokenIds.isNotEmpty) {
      print('      NFT列表: ${user.nftOwnedTokenIds.join(', ')}');
    }
    print('');
  }
  
  print('🔍 搜索演示:');
  print('   搜索"皮卡丘":');
  final searchResults = userDatabase.searchUsers('皮卡丘');
  for (final user in searchResults) {
    print('     找到: ${user.displayName} (${user.email})');
  }
  
  print('\n   搜索"jaychou"用户名:');
  final usernameResults = userDatabase.searchByUsername('jaychou');
  for (final user in usernameResults) {
    print('     找到: ${user.displayName} (${user.email})');
  }
  
  print('\n💰 金币排行榜 (前5名):');
  final richUsers = userDatabase.getUsersByGoldBalance(descending: true).take(5);
  for (int i = 0; i < richUsers.length; i++) {
    final user = richUsers.elementAt(i);
    print('   ${i + 1}. ${user.displayName}: ${user.goldBalance} 金币');
  }
  
  print('\n🎴 拥有NFT的用户:');
  final nftUsers = userDatabase.getUsersWithNFTs().take(5);
  for (final user in nftUsers) {
    print('   ${user.displayName}: ${user.nftOwnedTokenIds.length} 个NFT');
  }
  
  print('\n🎮 游戏玩家选择演示:');
  final gamePlayers = userDatabase.selectRoomPlayers(3);
  print('   为游戏选择的3个玩家:');
  for (final player in gamePlayers) {
    print('   ${player.displayName} (${player.userId}) - ${player.goldBalance} 金币');
  }
  
  print('\n✨ 演示完成！');
  print('   可以在应用中访问 /user_demo 路由查看完整的用户界面');
}
