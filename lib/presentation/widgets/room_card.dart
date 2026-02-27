import 'package:flutter/material.dart';

class RoomCard extends StatelessWidget {
  final String name;
  final String host;
  final int players;
  final VoidCallback? onTap;
  const RoomCard({Key? key, required this.name, required this.host, required this.players, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(name),
        subtitle: Text('Host: $host  Players: $players'),
        trailing: ElevatedButton(onPressed: onTap, child: const Text('进入')),
      ),
    );
  }
}
