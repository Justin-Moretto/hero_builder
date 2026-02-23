import '../models/enemy_model.dart';
import '../models/item_model.dart';

/// Default enemy definitions for combat encounters.
/// Equipped items are used in auto-battle (damage on cooldown).
final Map<String, EnemyModel> defaultEnemies = {
  'slime': EnemyModel(
    key: 'slime',
    name: 'Slime',
    maxHealth: 15,
    equippedItems: const [
      ItemModel(key: 'slime_bash', name: 'Bash', damage: 2, cost: 0, cooldown: 1.2),
    ],
  ),
  'skeleton': EnemyModel(
    key: 'skeleton',
    name: 'Skeleton',
    maxHealth: 22,
    equippedItems: const [
      ItemModel(key: 'bone_sword', name: 'Bone Sword', damage: 4, cost: 0, cooldown: 1.3),
    ],
  ),
  'bandit': EnemyModel(
    key: 'bandit',
    name: 'Bandit',
    maxHealth: 28,
    equippedItems: const [
      ItemModel(key: 'bandit_dagger', name: 'Dagger', damage: 3, cost: 0, cooldown: 1.0),
    ],
  ),
};

EnemyModel? getEnemyByKey(String key) => defaultEnemies[key];
