import 'package:flutter/material.dart';
import 'package:aa_doudizhu/core/theme.dart';

class RoomCard extends StatelessWidget {
  final String name;
  final String host;
  final int players;
  final bool isPrivate;
  final VoidCallback? onTap;
  const RoomCard({Key? key, required this.name, required this.host, required this.players, this.isPrivate = false, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: kSurface,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.white.withOpacity(0.05)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: kSurfaceLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: kGold.withOpacity(0.3)),
                ),
                child: Icon(
                  isPrivate ? Icons.lock : Icons.public,
                  color: isPrivate ? kGold : Colors.white54,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('房主: $host', style: TextStyle(color: Colors.white54, fontSize: 13)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: players >= 3 ? kRed.withOpacity(0.2) : kPrimary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: players >= 3 ? kRed : kPrimary),
                ),
                child: Text(
                  '$players/4',
                  style: TextStyle(
                    color: players >= 3 ? kRed : kPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kGold,
                  foregroundColor: kBackground,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: const Text('进入'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
