import 'package:flutter/material.dart';
import 'package:aa_doudizhu/presentation/widgets/room_card.dart';

class LobbyScreen extends StatefulWidget {
  const LobbyScreen({Key? key}) : super(key: key);

  @override
  _LobbyScreenState createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  final List<Map<String, dynamic>> _sampleRooms = [
    {'name': '私人房-Alice', 'host': 'Alice', 'players': 2, 'token': 't1'},
    {'name': '私人房-Bob', 'host': 'Bob', 'players': 3, 'token': 't2'},
    {'name': '公开房-快来', 'host': 'System', 'players': 1, 'token': ''},
  ];
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final filtered = _sampleRooms.where((r) => r['name'].toString().toLowerCase().contains(_query.toLowerCase())).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('AlleyAce - Lobby')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: '搜索房间...',
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, i) {
                final r = filtered[i];
                return RoomCard(
                  name: r['name'],
                  host: r['host'],
                  players: r['players'],
                  onTap: () {
                    Navigator.of(context).pushNamed('/room');
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('创建私人房（占位）')));
        },
        child: const Icon(Icons.add),
        tooltip: '新建私人房',
      ),
    );
  }
}
