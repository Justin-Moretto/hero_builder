import 'dart:math';

import 'package:flutter/foundation.dart';

import '../data/biomes.dart';
import '../data/event_nodes.dart';
import '../models/biome_model.dart';
import '../models/event_node_model.dart';

/// Interface for world UI: current biome, event nodes, travel options.
/// Implemented by [WorldState] (standalone) and [HeroGame] (with Flame).
abstract class WorldStateInterface {
  ValueNotifier<String> get currentBiomeKeyNotifier;
  BiomeModel? getCurrentBiome();
  List<EventNodeModel> getCurrentEventNodeOptions();
  List<BiomeModel> getTravelOptions();
  void travelToBiome(String biomeKey);
}

/// World map state: current biome, event nodes, and travel options.
/// Used for the initial world screen (no Flame) so the app loads immediately.
class WorldState implements WorldStateInterface {
  final List<BiomeModel> biomes = createDefaultBiomes();
  final List<EventNodeModel> eventNodes = createDefaultEventNodes();
  final Random _random = Random();

  final ValueNotifier<String> currentBiomeKeyNotifier = ValueNotifier('');

  WorldState() {
    currentBiomeKeyNotifier.value = biomes[_random.nextInt(biomes.length)].key;
  }

  String get currentBiomeKey => currentBiomeKeyNotifier.value;

  BiomeModel? getCurrentBiome() {
    try {
      return biomes.firstWhere((b) => b.key == currentBiomeKey);
    } catch (_) {
      return null;
    }
  }

  List<EventNodeModel> getCurrentEventNodeOptions() {
    final eligible = eventNodes
        .where((n) => n.canSpawnInBiome(currentBiomeKey))
        .toList(growable: false);
    if (eligible.length <= 2) return List.from(eligible);
    eligible.shuffle(_random);
    return eligible.take(2).toList();
  }

  List<BiomeModel> getTravelOptions() {
    final other = biomes.where((b) => b.key != currentBiomeKey).toList();
    if (other.length <= 2) return other;
    other.shuffle(_random);
    return other.take(2).toList();
  }

  void travelToBiome(String biomeKey) {
    if (biomeKey == currentBiomeKey) return;
    currentBiomeKeyNotifier.value = biomeKey;
  }
}
