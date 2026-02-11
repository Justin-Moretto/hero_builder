import 'package:flutter/material.dart';

import '../models/player.dart';

enum CharacterPanelState { closed, minimized, maximized }

class CharacterSheetOverlay extends StatelessWidget {
  final CharacterPanelState panelState;
  final ValueChanged<CharacterPanelState> onPanelStateChanged;
  final Player player;

  const CharacterSheetOverlay({
    super.key,
    required this.panelState,
    required this.onPanelStateChanged,
    required this.player,
  });

  @override
  Widget build(BuildContext context) {
    if (panelState == CharacterPanelState.closed) return const SizedBox.shrink();

    return Stack(
      children: [
        if (panelState == CharacterPanelState.maximized)
          GestureDetector(
            onTap: () => onPanelStateChanged(CharacterPanelState.closed),
            behavior: HitTestBehavior.opaque,
            child: Container(color: Colors.black54),
          ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Material(
            elevation: 8,
            borderRadius: panelState == CharacterPanelState.minimized
                ? BorderRadius.circular(20)
                : const BorderRadius.vertical(top: Radius.circular(16)),
            color: Colors.grey[850],
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              width: double.infinity,
              height: panelState == CharacterPanelState.minimized ? 56 : null,
              constraints: panelState == CharacterPanelState.maximized
                  ? BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.6)
                  : null,
              child: panelState == CharacterPanelState.minimized
                  ? _MinimizedBar(
                      onExpand: () => onPanelStateChanged(CharacterPanelState.maximized),
                      onClose: () => onPanelStateChanged(CharacterPanelState.closed),
                    )
                  : _MaximizedContent(
                      player: player,
                      onMinimize: () => onPanelStateChanged(CharacterPanelState.minimized),
                      onClose: () => onPanelStateChanged(CharacterPanelState.closed),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MinimizedBar extends StatelessWidget {
  final VoidCallback onExpand;
  final VoidCallback onClose;

  const _MinimizedBar({required this.onExpand, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Text(
            '\u2699',
            style: TextStyle(color: Colors.grey[400], fontSize: 22, height: 1),
          ),
          const SizedBox(width: 8),
          const Text(
            'Character',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const Spacer(),
          _TextIconButton(
            label: '\u25A1', // □ expand
            onPressed: onExpand,
            tooltip: 'Expand',
          ),
          _TextIconButton(
            label: '\u00D7', // × close
            onPressed: onClose,
            tooltip: 'Close',
          ),
        ],
      ),
    );
  }
}

class _MaximizedContent extends StatelessWidget {
  final Player player;
  final VoidCallback onMinimize;
  final VoidCallback onClose;

  const _MaximizedContent({
    required this.player,
    required this.onMinimize,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _HeaderBar(
          onMinimize: onMinimize,
          onClose: onClose,
        ),
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Stats',
                  style: TextStyle(
                    color: Colors.grey[300],
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                _StatRow('Health', '${player.health} / ${player.maxHealth}'),
                _StatRow('Energy', '${player.energy} / ${player.maxEnergy}'),
                _StatRow('Gold', '${player.gold}'),
                const SizedBox(height: 16),
                Text(
                  'Inventory',
                  style: TextStyle(
                    color: Colors.grey[300],
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[700]!),
                  ),
                  child: player.items.isEmpty
                      ? Center(
                          child: Text(
                            'Empty (inventory will be redone)',
                            style: TextStyle(color: Colors.grey[500], fontSize: 14),
                          ),
                        )
                      : Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final entry in player.items.entries)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.grey[800],
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  entry.value.name,
                                  style: const TextStyle(color: Colors.white, fontSize: 12),
                                ),
                              ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _HeaderBar extends StatelessWidget {
  final VoidCallback onMinimize;
  final VoidCallback onClose;

  const _HeaderBar({required this.onMinimize, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[700]!)),
      ),
      child: Row(
        children: [
          const Text(
            'Character & Inventory',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const Spacer(),
          _TextIconButton(
            label: '\u2013', // – minimize
            onPressed: onMinimize,
            tooltip: 'Minimize',
          ),
          _TextIconButton(
            label: '\u00D7', // × close
            onPressed: onClose,
            tooltip: 'Close',
          ),
        ],
      ),
    );
  }
}

class _TextIconButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final String tooltip;

  const _TextIconButton({
    required this.label,
    required this.onPressed,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 20,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 14)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
