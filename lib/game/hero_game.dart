import 'dart:math';

import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';

import '../data/biomes.dart';
import '../data/event_nodes.dart';
import '../models/biome_model.dart';
import '../models/event_node_model.dart';
import '../models/item_model.dart';
import '../models/player.dart';
import 'world_state.dart';

enum GamePhase { world, shop, combat }

class HeroGame extends FlameGame implements WorldStateInterface {
  GamePhase phase = GamePhase.world;
  late Player player;
  List<ItemModel> shopItems = [];

  late List<BiomeModel> biomes;
  late List<EventNodeModel> eventNodes;
  final Random _random = Random();

  /// Current biome key; changes when the player travels. Listen to this to rebuild world UI.
  final ValueNotifier<String> currentBiomeKeyNotifier = ValueNotifier('');

  @override
  Future<void> onLoad() async {
    player = Player();
    player.gold = 10;
    biomes = createDefaultBiomes();
    eventNodes = createDefaultEventNodes();
    currentBiomeKeyNotifier.value = biomes[_random.nextInt(biomes.length)].key;
    _generateShopItems();

    overlays.add('world');
  }

  String get currentBiomeKey => currentBiomeKeyNotifier.value;

  BiomeModel? getCurrentBiome() {
    try {
      return biomes.firstWhere((b) => b.key == currentBiomeKey);
    } catch (_) {
      return null;
    }
  }

  /// Two random event nodes that can appear in the current biome. New draw each time (e.g. after travel).
  List<EventNodeModel> getCurrentEventNodeOptions() {
    final eligible = eventNodes
        .where((n) => n.canSpawnInBiome(currentBiomeKey))
        .toList(growable: false);
    if (eligible.length <= 2) return List.from(eligible);
    eligible.shuffle(_random);
    return eligible.take(2).toList();
  }

  /// Two biomes the player can travel to. Random for now; replace later with world map / connections.
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

  void _generateShopItems() {
    // TODO: Replace with random generation logic
    shopItems = [
      ItemModel(
        key: 'dagger_1',
        name: 'Dagger',
        size: ItemSize.small,
        damage: 2,
      ),
      ItemModel(
        key: 'short_sword_1',
        name: 'Short Sword',
        size: ItemSize.small,
        damage: 3,
      ),
      ItemModel(
        key: 'wand_1',
        name: 'Wand',
        size: ItemSize.small,
        damage: 1,
      ),
      ItemModel(
        key: 'platemail_1',
        name: 'Platemail',
        size: ItemSize.medium,
        damage: 4,
      ),
    ];
  }

  void buyItem(ItemModel item) {
    if (player.gold >= item.cost &&
        player.hasInventorySpace(item.slotsToOccupy)) {
      player.gold -= item.cost;
      player.addToBoard(item);
    }
  }

  void startCombat() {
    phase = GamePhase.combat;
    overlays.remove('shop');
    // TODO: Add combat overlay
    // TODO: Implement combat resolution
  }

  void endCombat() {
    phase = GamePhase.shop;
    _generateShopItems();
    overlays.add('shop');
    // TODO: Reward gold based on outcome
  }
}
