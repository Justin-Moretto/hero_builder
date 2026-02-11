import 'package:flutter/material.dart';

import '../game/world_state.dart';
import '../models/biome_model.dart';
import '../models/event_node_model.dart';

class WorldPhase extends StatelessWidget {
  final WorldStateInterface state;

  const WorldPhase({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: state.currentBiomeKeyNotifier,
      builder: (context, _currentBiomeKey, _) {
        final currentBiome = state.getCurrentBiome();
        final eventNodes = state.getCurrentEventNodeOptions();
        final travelOptions = state.getTravelOptions();

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
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Event nodes here',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Two event node buttons (no functionality yet)
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        for (final node in eventNodes) _EventNodeButton(node: node),
                        if (eventNodes.length < 2)
                          ...List.generate(
                            2 - eventNodes.length,
                            (_) => const SizedBox(width: 120, height: 80),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Travel to another biome
                  const Text(
                    'Travel to',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      for (final biome in travelOptions)
                        _TravelButton(
                          biome: biome,
                          onTap: () => state.travelToBiome(biome.key),
                        ),
                    ],
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

  const _EventNodeButton({required this.node});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.amber.shade800,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: () {
          // No functionality yet
        },
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 120,
          height: 80,
          child: Center(
            child: Text(
              node.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
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

class _TravelButton extends StatelessWidget {
  final BiomeModel biome;
  final VoidCallback onTap;

  const _TravelButton({required this.biome, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.green.shade800,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Text(
            biome.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
