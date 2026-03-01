import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aa_doudizhu/data/services/user_database.dart';
import 'package:aa_doudizhu/data/models/user.dart';
import 'package:aa_doudizhu/domain/game_logic/game_engine.dart';
import 'package:aa_doudizhu/core/theme.dart';

class UserDemoScreen extends ConsumerStatefulWidget {
  const UserDemoScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<UserDemoScreen> createState() => _UserDemoScreenState();
}

class _UserDemoScreenState extends ConsumerState<UserDemoScreen> {
  late UserDatabase _userDatabase;
  late GameEngine _gameEngine;
  List<User> _displayedUsers = [];
  String _searchQuery = '';
  User? _selectedUser;
  Map<String, dynamic>? _statistics;

  @override
  void initState() {
    super.initState();
    _userDatabase = UserDatabase();
    _gameEngine = GameEngine();
    _gameEngine.initialize();
    _userDatabase.initialize();
    _loadUsers();
    _loadStatistics();
  }

  void _loadUsers() {
    setState(() {
      _displayedUsers = _userDatabase.getAllUsers();
    });
  }

  void _loadStatistics() {
    setState(() {
      _statistics = _userDatabase.getStatistics();
    });
  }

  void _searchUsers(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _displayedUsers = _userDatabase.getAllUsers();
      } else {
        _displayedUsers = _userDatabase.searchUsers(query);
      }
    });
  }

  void _selectRandomUser() {
    final randomUser = _userDatabase.getRandomUser();
    setState(() {
      _selectedUser = randomUser;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('已选择随机用户: ${randomUser.displayName}'),
        backgroundColor: kGold,
      ),
    );
  }

  void _selectRandomPlayers() {
    final randomPlayers = _userDatabase.getRandomUsers(3);
    setState(() {
      _selectedUser = randomPlayers.first;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('已为游戏选择3个玩家，第一个是: ${randomPlayers.first.displayName}'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showUserDetails(User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kSurface,
        title: Text(
          user.displayName,
          style: const TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('用户ID', user.userId),
              _buildDetailRow('邮箱', user.email ?? '无'),
              _buildDetailRow('钱包地址', user.walletAddress ?? '无'),
              _buildDetailRow('金币余额', '${user.goldBalance}'),
              _buildDetailRow('NFT数量', '${user.nftOwnedTokenIds.length}'),
              if (user.nftOwnedTokenIds.isNotEmpty) ...[
                const SizedBox(height: 8),
                const Text(
                  'NFT Token IDs:',
                  style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
                ),
                ...user.nftOwnedTokenIds.map((tokenId) => Padding(
                  padding: const EdgeInsets.only(left: 8, top: 2),
                  child: Text(
                    tokenId,
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                )),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        backgroundColor: kSurface,
        title: Row(
          children: [
            Icon(Icons.people, color: kGold, size: 20),
            const SizedBox(width: 8),
            const Text('用户数据库演示'),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _loadUsers,
            icon: const Icon(Icons.refresh),
            tooltip: '刷新',
          ),
        ],
      ),
      body: Column(
        children: [
          // 统计信息
          if (_statistics != null)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: kSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: kGold.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '用户统计',
                    style: TextStyle(color: kGold, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard('总用户数', '${_statistics!['totalUsers']}', Colors.blue),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard('总金币', '${_statistics!['totalGold']}', Colors.green),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard('平均金币', '${_statistics!['averageGold']}', Colors.orange),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard('NFT用户', '${_statistics!['usersWithNFT']}', Colors.purple),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          // 搜索和操作栏
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                // 搜索框
                Container(
                  decoration: BoxDecoration(
                    color: kSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: TextField(
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: '搜索用户...',
                      hintStyle: TextStyle(color: Colors.white38),
                      prefixIcon: const Icon(Icons.search, color: Colors.white38),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    onChanged: _searchUsers,
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // 操作按钮
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _selectRandomUser,
                        icon: const Icon(Icons.casino),
                        label: const Text('随机选择用户'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kGold,
                          foregroundColor: kBackground,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _selectRandomPlayers,
                        icon: const Icon(Icons.group),
                        label: const Text('选择游戏玩家'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 用户列表
          Expanded(
            child: _displayedUsers.isEmpty
                ? const Center(
                    child: Text(
                      '没有找到用户',
                      style: TextStyle(color: Colors.white38),
                    ),
                  )
                : ListView.builder(
                    itemCount: _displayedUsers.length,
                    itemBuilder: (context, index) {
                      final user = _displayedUsers[index];
                      return _buildUserCard(user);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(User user) {
    final isSelected = _selectedUser?.userId == user.userId;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? kGold : Colors.white12,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: ListTile(
        onTap: () => _showUserDetails(user),
        leading: CircleAvatar(
          backgroundColor: isSelected ? kGold : Colors.white24,
          backgroundImage: user.avatarPath != null 
            ? AssetImage(user.avatarPath!)
            : null,
          child: user.avatarPath == null 
            ? Text(
                user.displayName.isNotEmpty ? user.displayName[0] : '?',
                style: TextStyle(
                  color: isSelected ? kBackground : Colors.white70,
                  fontWeight: FontWeight.bold,
                ),
              )
            : null,
        ),
        title: Text(
          user.displayName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ID: ${user.userId} • 金币: ${user.goldBalance}',
              style: TextStyle(color: Colors.white70),
            ),
            if (user.email != null)
              Text(
                user.email!,
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (user.nftOwnedTokenIds.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'NFT ${user.nftOwnedTokenIds.length}',
                  style: const TextStyle(
                    color: Colors.purple,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right,
              color: Colors.white38,
            ),
          ],
        ),
      ),
    );
  }
}
