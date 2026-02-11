import 'package:flutter/material.dart';

import '../models/player.dart';

class GameTopBar extends StatelessWidget {
  final Player player;
  final VoidCallback onCharacterPressed;

  const GameTopBar({
    super.key,
    required this.player,
    required this.onCharacterPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        border: Border(bottom: BorderSide(color: Colors.grey[700]!)),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            Expanded(
              child: _BarLabel(
                label: 'HP',
                value: player.health,
                max: player.maxHealth,
                color: Colors.red,
                backgroundColor: Colors.red.shade900,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _BarLabel(
                label: 'Energy',
                value: player.energy,
                max: player.maxEnergy,
                color: Colors.amber,
                backgroundColor: Colors.amber.shade900,
              ),
            ),
            const SizedBox(width: 8),
            Material(
              color: Colors.blue.shade800,
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                onTap: onCharacterPressed,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Center(
                    child: Text(
                      '\u2699', // gear symbol (Unicode), always visible
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        height: 1,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BarLabel extends StatelessWidget {
  final String label;
  final int value;
  final int max;
  final Color color;
  final Color backgroundColor;

  const _BarLabel({
    required this.label,
    required this.value,
    required this.max,
    required this.color,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final t = max > 0 ? (value / max).clamp(0.0, 1.0) : 0.0;
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.grey[300],
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: t,
                  backgroundColor: backgroundColor,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  minHeight: 14,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '$value/$max',
              style: TextStyle(
                color: Colors.grey[300],
                fontSize: 10,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        );
      },
    );
  }
}
