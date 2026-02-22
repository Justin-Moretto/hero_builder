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
            ),
            _NavButton(
              icon: Icons.location_on,
              label: 'Current Biome',
              onPressed: onCurrentBiomePressed,
            ),
            _NavButton(
              icon: Icons.person,
              label: 'Character',
              onPressed: onCharacterPressed,
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

  const _NavButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.grey[800],
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 24),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[300],
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
