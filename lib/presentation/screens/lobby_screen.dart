import 'package:flutter/material.dart';

class LobbyScreen extends StatelessWidget {
  const LobbyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sampleRooms = [
      {'name': '私人房-Alice', 'host': 'Alice', 'players': 2, 'token': 't1'},
      {'name': '私人房-Bob', 'host': 'Bob', 'players': 3, 'token': 't2'},
      {'name': '公开房-快来', 'host': 'System', 'players': 1, 'token': ''},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('AlleyAce - Lobby')), 
      body: ListView.builder(
        itemCount: sampleRooms.length,
        itemBuilder: (context, i) {
          final r = sampleRooms[i];
          return ListTile(
            leading: CircleAvatar(child: Text(r['name'][0])),
            title: Text(r['name']),
            subtitle: Text('Host: ${r['host']}  Players: ${r['players']}'),
            trailing: ElevatedButton(
              onPressed: () {
                // Navigate to房间占位
                Navigator.of(context).pushNamed('/room');
              },
              child: const Text('进入'),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // New private room create placeholder
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('创建私人房（占位）')),
          );
        },
        child: const Icon(Icons.add),
        tooltip: '新建私人房',
      ),
    );
  }
}
