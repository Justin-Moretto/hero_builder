import 'dart:math';

import '../models/item_model.dart';

/// Pool of all items that can appear in the shop. Weapons have damage and cooldown (seconds).
List<ItemModel> get shopItemPool => [
      // Weapons
      const ItemModel(key: 'dagger', name: 'Dagger', damage: 2, cost: 5, cooldown: 0.8),
      const ItemModel(key: 'short_sword', name: 'Short Sword', damage: 4, cost: 10, cooldown: 1.2),
      const ItemModel(key: 'long_sword', name: 'Long Sword', damage: 7, cost: 18, cooldown: 1.5),
      const ItemModel(key: 'axe', name: 'Hand Axe', damage: 5, cost: 12, cooldown: 1.4),
      const ItemModel(key: 'battle_axe', name: 'Battle Axe', damage: 9, cost: 22, cooldown: 2.0),
      const ItemModel(key: 'mace', name: 'Mace', damage: 6, cost: 14, cooldown: 1.6),
      const ItemModel(key: 'spear', name: 'Spear', damage: 6, cost: 15, cooldown: 1.3),
      const ItemModel(key: 'bow', name: 'Short Bow', damage: 5, cost: 14, cooldown: 1.0),
      const ItemModel(key: 'crossbow', name: 'Crossbow', damage: 8, cost: 20, cooldown: 2.2),
      const ItemModel(key: 'rapier', name: 'Rapier', damage: 3, cost: 11, cooldown: 0.6),
      const ItemModel(key: 'club', name: 'Club', damage: 3, cost: 4, cooldown: 1.0),
      // Non-weapons
      const ItemModel(key: 'health_potion', name: 'Health Potion', damage: 0, cost: 3, cooldown: 0.0),
      const ItemModel(key: 'leather_armor', name: 'Leather Armor', damage: 0, cost: 12, cooldown: 0.0),
      const ItemModel(key: 'chain_armor', name: 'Chain Armor', damage: 0, cost: 20, cooldown: 0.0),
    ];

final _rng = Random();

/// Returns a randomized list of [count] items from the shop pool (no duplicates).
List<ItemModel> getRandomShopItems({int count = 6}) {
  final pool = List<ItemModel>.from(shopItemPool);
  pool.shuffle(_rng);
  return pool.take(count).toList();
}
