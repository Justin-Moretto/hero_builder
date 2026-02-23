import 'package:flutter/material.dart';

import '../game/world_state.dart';
import '../models/event_node_model.dart';

/// Called when user taps an event node. [node] identifies which node was tapped.
typedef OnEventNodeTapped = void Function(EventNodeModel node);

class WorldPhase extends StatelessWidget {
  final WorldStateInterface state;
  final OnEventNodeTapped? onEventTapped;

  const WorldPhase({super.key, required this.state, this.onEventTapped});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: state.currentBiomeKeyNotifier,
      builder: (context, _currentBiomeKey, _) {
        final currentBiome = state.getCurrentBiome();
        final eventNodes = state.getCurrentEventNodeOptions();

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Current biome
                  Text(
                    currentBiome?.name ?? 'Unknown',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 27,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Event nodes here',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Event node buttons (no functionality yet)
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        for (final node in eventNodes)
                          _EventNodeButton(
                            node: node,
                            onTap: onEventTapped != null ? () => onEventTapped!(node) : null,
                          ),
                        if (eventNodes.length < 2)
                          ...List.generate(
                            2 - eventNodes.length,
                            (_) => const SizedBox(width: 120, height: 80),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _EventNodeButton extends StatelessWidget {
  final EventNodeModel node;
  final VoidCallback? onTap;

  const _EventNodeButton({required this.node, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isCombat = node.isCombatEncounter;
    final color = isCombat ? Colors.red.shade700 : Colors.amber.shade800;
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 120,
          height: 80,
          child: Center(
            child: Text(
              node.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

