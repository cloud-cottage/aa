import 'package:flutter/material.dart';
import 'package:aa_doudizhu/core/theme.dart';

class RoomCard extends StatefulWidget {
  final String name;
  final String host;
  final int players;
  final bool isPrivate;
  final int stake;
  final VoidCallback? onTap;
  const RoomCard({Key? key, required this.name, required this.host, required this.players, this.isPrivate = false, this.stake = 1, this.onTap}) : super(key: key);

  @override
  State<RoomCard> createState() => _RoomCardState();
}

class _RoomCardState extends State<RoomCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isFull = widget.players >= 3;
    return Card(
      color: _isPressed ? kSurfaceLight : kSurface,
      elevation: _isPressed ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: widget.isPrivate ? kGold.withOpacity(0.3) : Colors.white.withOpacity(0.05),
        ),
      ),
      child: InkWell(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: isFull ? null : widget.onTap,
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
                  border: Border.all(color: widget.isPrivate ? kGold.withOpacity(0.3) : Colors.white12),
                ),
                child: Icon(
                  widget.isPrivate ? Icons.lock : Icons.public,
                  color: widget.isPrivate ? kGold : Colors.white54,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(widget.name, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                        ),
                        if (widget.isPrivate) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: kGold.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: kGold.withOpacity(0.3)),
                            ),
                            child: const Text('NFT', style: TextStyle(color: kGold, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text('房主: ${widget.host}', style: TextStyle(color: Colors.white54, fontSize: 13)),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.monetization_on, size: 12, color: kGold),
                              const SizedBox(width: 2),
                              Text('${widget.stake}', style: TextStyle(color: kGold, fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isFull ? kRed.withOpacity(0.2) : kPrimary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isFull ? kRed : kPrimary),
                ),
                child: Text(
                  '${widget.players}/4',
                  style: TextStyle(
                    color: isFull ? kRed : kPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: isFull ? null : widget.onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isFull ? Colors.grey : kGold,
                  foregroundColor: kBackground,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: Text(isFull ? '已满' : '进入'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
