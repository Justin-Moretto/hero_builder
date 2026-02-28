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
                  Text(
                    currentBiome?.name ?? 'Unknown',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 27,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final isPortrait = MediaQuery.orientationOf(context) == Orientation.portrait;
                        if (isPortrait) {
                          return SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                for (final node in eventNodes)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: _EventNodeButton(
                                      node: node,
                                      onTap: onEventTapped != null ? () => onEventTapped!(node) : null,
                                      compact: true,
                                    ),
                                  ),
                              ],
                            ),
                          );
                        }
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            for (final node in eventNodes)
                              _EventNodeButton(
                                node: node,
                                onTap: onEventTapped != null ? () => onEventTapped!(node) : null,
                                compact: false,
                              ),
                          ],
                        );
                      },
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
  /// In portrait/column layout, button is full width and compact height.
  final bool compact;

  const _EventNodeButton({required this.node, this.onTap, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final isCombat = node.isCombatEncounter;
    final color = isCombat ? Colors.red.shade700 : Theme.of(context).colorScheme.secondary;
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: compact
            ? SizedBox(
                width: double.infinity,
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
              )
            : SizedBox(
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

