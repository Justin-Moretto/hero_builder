import 'package:flutter/material.dart';

/// Bottom app bar with world map, character/inventory, and current biome (home) actions.
class GameBottomBar extends StatelessWidget {
  final VoidCallback onMapPressed;
  final VoidCallback onCharacterPressed;
  final VoidCallback onCurrentBiomePressed;

  const GameBottomBar({
    super.key,
    required this.onMapPressed,
    required this.onCharacterPressed,
    required this.onCurrentBiomePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        border: Border(top: BorderSide(color: Colors.grey[700]!)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _NavButton(
              icon: Icons.map,
              label: 'World Map',
              onPressed: onMapPressed,
              color: Colors.teal,
            ),
            _NavButton(
              icon: Icons.location_on,
              label: 'Current Biome',
              onPressed: onCurrentBiomePressed,
              color: Colors.amber,
            ),
            _NavButton(
              icon: Icons.person,
              label: 'Character',
              onPressed: onCharacterPressed,
              color: Colors.deepPurple,
            ),
          ],
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color color;

  const _NavButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = color.withValues(alpha: 0.3);
    final iconColor = Color.lerp(Colors.white, color, 0.85) ?? color;
    final textColor = Color.lerp(Colors.white, color, 0.9) ?? color;

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.7), width: 1.5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: iconColor, size: 26),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: textColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
