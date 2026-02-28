import 'dart:math';

import 'package:flutter/foundation.dart';

import '../data/biomes.dart';
import '../data/event_nodes.dart';
import '../data/shop_items.dart';
import '../models/biome_model.dart';
import '../models/event_node_model.dart';
import '../models/item_model.dart';

/// Interface for world UI: current biome, event nodes, travel options.
/// Implemented by [WorldState] (standalone) and [HeroGame] (with Flame).
abstract class WorldStateInterface {
  ValueNotifier<String> get currentBiomeKeyNotifier;
  BiomeModel? getCurrentBiome();
  List<EventNodeModel> getCurrentEventNodeOptions();
  List<BiomeModel> getTravelOptions();
  void travelToBiome(String biomeKey);
  void clearEncounter(String eventNodeKey);
  bool isEncounterCleared(String eventNodeKey);
}

/// World map state: current biome, event nodes, and travel options.
/// Used for the initial world screen (no Flame) so the app loads immediately.
class WorldState implements WorldStateInterface {
  final List<BiomeModel> biomes = createDefaultBiomes();
  final List<EventNodeModel> eventNodes = createDefaultEventNodes();
  final Random _random = Random();
  /// Cleared combat encounter node keys per biome (so the node disappears after victory).
  final Map<String, Set<String>> _clearedEncountersByBiome = {};
  /// Fixed event nodes per biome for this run. Set by [initializeRun].
  Map<String, List<EventNodeModel>>? _biomeEventNodes;
  /// Shop stock per shop instance (key: '${biomeKey}_${eventNodeKey}').
  final Map<String, List<ItemModel>> _shopStock = {};

  final ValueNotifier<String> currentBiomeKeyNotifier = ValueNotifier('');

  WorldState() {
    currentBiomeKeyNotifier.value = biomes[_random.nextInt(biomes.length)].key;
  }

  /// Max event nodes per biome so the bottom bar is never cut off.
  static const int _maxNodesPerBiome = 3;

  /// Populate event nodes in each biome for the whole run. Call once at Start Game.
  /// Each biome gets at most 3 nodes so the bottom app bar always stays visible.
  void initializeRun() {
    _biomeEventNodes = {};
    for (final biome in biomes) {
      final eligible = eventNodes
          .where((n) => n.canSpawnInBiome(biome.key))
          .toList(growable: true);
      eligible.shuffle(_random);
      final count = eligible.length.clamp(0, _maxNodesPerBiome);
      _biomeEventNodes![biome.key] = eligible.take(count).toList();
    }
  }

  /// Restock all shop nodes (day 1 and start of each new day).
  void restockAllShops() {
    if (_biomeEventNodes == null) return;
    for (final entry in _biomeEventNodes!.entries) {
      final biomeKey = entry.key;
      for (final node in entry.value) {
        if (node.isShop) {
          final shopId = '${biomeKey}_${node.key}';
          _shopStock[shopId] = getRandomShopItems(count: 6, random: _random);
        }
      }
    }
  }

  /// Current stock for a shop (mutable list; remove items on purchase).
  List<ItemModel> getShopStock(String biomeKey, String eventNodeKey) {
    final shopId = '${biomeKey}_${eventNodeKey}';
    return _shopStock[shopId] ?? [];
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
    if (_biomeEventNodes != null) {
      final nodes = _biomeEventNodes![currentBiomeKey] ?? [];
      final cleared = _clearedEncountersByBiome[currentBiomeKey];
      if (cleared == null || cleared.isEmpty) return List.from(nodes);
      return nodes.where((n) => !cleared.contains(n.key)).toList();
    }
    final cleared = _clearedEncountersByBiome[currentBiomeKey];
    final eligible = eventNodes
        .where((n) =>
            n.canSpawnInBiome(currentBiomeKey) &&
            (cleared == null || !cleared.contains(n.key)))
        .toList(growable: false);
    if (eligible.length <= 3) return List.from(eligible);
    eligible.shuffle(_random);
    return eligible.take(3).toList();
  }

  @override
  void clearEncounter(String eventNodeKey) {
    _clearedEncountersByBiome
        .putIfAbsent(currentBiomeKey, () => {})
        .add(eventNodeKey);
  }

  @override
  bool isEncounterCleared(String eventNodeKey) {
    return _clearedEncountersByBiome[currentBiomeKey]?.contains(eventNodeKey) ?? false;
  }

  /// Biomes the player can travel to (adjacent nodes only).
  List<BiomeModel> getTravelOptions() {
    final current = getCurrentBiome();
    if (current == null) return [];
    return biomes
        .where((b) => b.key != currentBiomeKey && current.isAdjacent(b.key))
        .toList(growable: false);
  }

  void travelToBiome(String biomeKey) {
    if (biomeKey == currentBiomeKey) return;
    currentBiomeKeyNotifier.value = biomeKey;
  }
}
