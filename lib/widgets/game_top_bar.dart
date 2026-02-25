import 'package:flutter/material.dart';

import '../game/time_of_day.dart' as game_clock;
import '../models/player.dart';

/// Top bar: first row HP/Energy; second row Day, time, biome name (center, with pin), gold.
class GameTopBar extends StatelessWidget {
  final Player player;
  final int day;
  final game_clock.TimeOfDay timeOfDay;
  final String? currentBiomeName;

  const GameTopBar({
    super.key,
    required this.player,
    required this.day,
    required this.timeOfDay,
    this.currentBiomeName,
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
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
                    color: Theme.of(context).colorScheme.primary,
                    backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.4),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Text(
                  'Day: $day',
                  style: TextStyle(
                    color: Colors.grey[300],
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  timeOfDay.label,
                  style: TextStyle(
                    color: timeOfDay.color,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.push_pin,
                        size: 16,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        currentBiomeName ?? '—',
                        style: TextStyle(
                          color: Colors.grey[300],
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Text(
                  '${player.gold} gold',
                  style: TextStyle(
                    color: Colors.amber.shade300,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
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
                fontSize: 14,
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
                fontSize: 13,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        );
      },
    );
  }
}
