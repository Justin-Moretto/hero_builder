import 'package:flutter/material.dart';

/// Bottom app bar with world map, character/inventory, and current biome (home) actions.
/// [selectedIndex]: 0 = World Map, 1 = Current Biome, 2 = Character.
class GameBottomBar extends StatelessWidget {
  final VoidCallback onMapPressed;
  final VoidCallback onCharacterPressed;
  final VoidCallback onCurrentBiomePressed;
  final int selectedIndex;

  const GameBottomBar({
    super.key,
    required this.onMapPressed,
    required this.onCharacterPressed,
    required this.onCurrentBiomePressed,
    this.selectedIndex = 1,
  });

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
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
              color: accent,
              isSelected: selectedIndex == 0,
            ),
            _NavButton(
              icon: Icons.location_on,
              label: 'Current Biome',
              onPressed: onCurrentBiomePressed,
              color: accent,
              isSelected: selectedIndex == 1,
            ),
            _NavButton(
              icon: Icons.person,
              label: 'Character',
              onPressed: onCharacterPressed,
              color: accent,
              isSelected: selectedIndex == 2,
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
  final bool isSelected;

  const _NavButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.color,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isSelected ? color.withValues(alpha: 0.5) : color.withValues(alpha: 0.2);
    final iconColor = isSelected ? color : Colors.grey[500]!;
    final textColor = isSelected ? color : Colors.grey[500]!;

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
            border: Border(
              bottom: BorderSide(
                color: isSelected ? color : Colors.transparent,
                width: 3,
              ),
            ),
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
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
