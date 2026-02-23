import 'item_model.dart';

/// Enemy in a combat encounter. Has health and a list of equipped items (weapons) that deal damage on cooldown.
class EnemyModel {
  final String key;
  final String name;
  final int maxHealth;
  final List<ItemModel> equippedItems;

  const EnemyModel({
    required this.key,
    required this.name,
    required this.maxHealth,
    required this.equippedItems,
  });
}
