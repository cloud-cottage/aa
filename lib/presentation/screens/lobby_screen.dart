import 'package:flutter/material.dart';
import 'package:aa_doudizhu/presentation/widgets/room_card.dart';
import 'package:aa_doudizhu/core/theme.dart';

class LobbyScreen extends StatefulWidget {
  const LobbyScreen({Key? key}) : super(key: key);

  @override
  _LobbyScreenState createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  final List<Map<String, dynamic>> _sampleRooms = [
    {'name': '私人房-Alice', 'host': 'Alice', 'players': 2, 'token': 't1', 'isPrivate': true},
    {'name': '私人房-Bob', 'host': 'Bob', 'players': 3, 'token': 't2', 'isPrivate': true},
    {'name': '公开房-快来', 'host': 'System', 'players': 1, 'token': '', 'isPrivate': false},
    {'name': '新手房', 'host': 'System', 'players': 0, 'token': '', 'isPrivate': false},
    {'name': '高手房', 'host': 'ProPlayer', 'players': 2, 'token': '', 'isPrivate': false},
  ];
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final filtered = _sampleRooms.where((r) => r['name'].toString().toLowerCase().contains(_query.toLowerCase())).toList();
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.casino, color: kGold),
            const SizedBox(width: 8),
            const Text('AlleyAce 大厅'),
          ],
        ),
        backgroundColor: kSurface,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [kBackground, Color(0xFF0F0F0F)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: kSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white12),
                ),
                child: TextField(
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: '搜索房间...',
                    hintStyle: TextStyle(color: Colors.white38),
                    prefixIcon: const Icon(Icons.search, color: Colors.white38),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  onChanged: (v) => setState(() => _query = v),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text('房间列表 (${filtered.length})', style: TextStyle(color: Colors.white54, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: filtered.isEmpty 
                ? Center(child: Text('暂无房间', style: TextStyle(color: Colors.white38)))
                : ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, i) {
                      final r = filtered[i];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        child: RoomCard(
                          name: r['name'],
                          host: r['host'],
                          players: r['players'],
                          isPrivate: r['isPrivate'],
                          onTap: () {
                            Navigator.of(context).pushNamed('/room');
                          },
                        ),
                      );
                    },
                  ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showCreateRoomDialog();
        },
        backgroundColor: kGold,
        icon: const Icon(Icons.add, color: kBackground),
        label: const Text('创建房间', style: TextStyle(color: kBackground, fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _showCreateRoomDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kSurface,
        title: const Text('创建房间', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.lock, color: kGold),
              title: const Text('私人房', style: TextStyle(color: Colors.white)),
              subtitle: Text('需要 NFT 房卡', style: TextStyle(color: Colors.white54)),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('NFT 房卡功能开发中...')),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.public, color: Colors.white54),
              title: const Text('公开房', style: TextStyle(color: Colors.white)),
              subtitle: Text('免费创建', style: TextStyle(color: Colors.white54)),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('公开房功能开发中...')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
