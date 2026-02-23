import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/enemies.dart';
import '../game/world_state.dart';
import '../models/enemy_model.dart';
import '../models/event_node_model.dart';
import '../models/item_model.dart';
import '../models/player.dart';

/// Used when the hero has no equipped weapons for the encounter.
const ItemModel _unarmedAbility = ItemModel(
  key: 'unarmed',
  name: 'Unarmed',
  damage: 1,
  cost: 0,
  cooldown: 0.9,
);

/// Full-screen combat: hero left, enemy right, ability bars under each character.
/// Auto-battler: no input; when a cooldown fills, that item deals damage and resets.
class CombatScreen extends StatefulWidget {
  final Player player;
  final EventNodeModel eventNode;
  final WorldState worldState;
  final VoidCallback onVictory;
  final VoidCallback onDefeat;

  const CombatScreen({
    super.key,
    required this.player,
    required this.eventNode,
    required this.worldState,
    required this.onVictory,
    required this.onDefeat,
  });

  @override
  State<CombatScreen> createState() => _CombatScreenState();
}

class _CombatScreenState extends State<CombatScreen> with SingleTickerProviderStateMixin {
  EnemyModel? _enemy;
  int _enemyHealth = 0;
  /// Progress 0..1 for each hero equipped item (index matches getEquippedItems()).
  List<double> _heroCooldownProgress = [];
  /// Progress 0..1 for each enemy equipped item.
  List<double> _enemyCooldownProgress = [];
  bool _ended = false;
  Timer? _timer;

  /// Hero items used in combat: equipped weapons, or [Unarmed] if none.
  List<ItemModel> _getHeroItemsForCombat() {
    final equipped = widget.player.getEquippedItems();
    if (equipped.isEmpty) return [_unarmedAbility];
    return equipped;
  }

  @override
  void initState() {
    super.initState();
    _enemy = getEnemyByKey(widget.eventNode.enemyKey ?? '');
    if (_enemy != null) {
      _enemyHealth = _enemy!.maxHealth;
      _heroCooldownProgress = List.filled(_getHeroItemsForCombat().length, 0.0);
      _enemyCooldownProgress = List.filled(_enemy!.equippedItems.length, 0.0);
    }
    _startBattle();
  }

  void _startBattle() {
    const step = 0.016; // ~60fps
    _timer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (_ended || !mounted) return;
      _tick(step);
    });
  }

  void _tick(double dt) {
    final heroItems = _getHeroItemsForCombat();
    final enemyItems = _enemy?.equippedItems ?? [];

    // Hero items: advance progress, fire when >= 1
    for (int i = 0; i < heroItems.length; i++) {
      if (i >= _heroCooldownProgress.length) break;
      final item = heroItems[i];
      if (item.cooldown <= 0) continue;
      _heroCooldownProgress[i] += dt / item.cooldown;
      if (_heroCooldownProgress[i] >= 1.0) {
        _heroCooldownProgress[i] = 0.0;
        _enemyHealth = (_enemyHealth - item.damage).clamp(0, _enemy!.maxHealth);
        if (_enemyHealth <= 0) {
          _endBattle(victory: true);
          return;
        }
      }
    }

    // Enemy items: advance progress, fire when >= 1
    for (int i = 0; i < enemyItems.length; i++) {
      if (i >= _enemyCooldownProgress.length) break;
      final item = enemyItems[i];
      if (item.cooldown <= 0) continue;
      _enemyCooldownProgress[i] += dt / item.cooldown;
      if (_enemyCooldownProgress[i] >= 1.0) {
        _enemyCooldownProgress[i] = 0.0;
        widget.player.health = (widget.player.health - item.damage).clamp(0, widget.player.maxHealth);
        if (widget.player.health <= 0) {
          _endBattle(victory: false);
          return;
        }
      }
    }

    if (mounted) setState(() {});
  }

  void _endBattle({required bool victory}) {
    if (_ended) return;
    _ended = true;
    _timer?.cancel();
    _timer = null;
    if (mounted) setState(() {});
    if (victory) {
      _showVictoryLoot();
    } else {
      _showDefeatDialog();
    }
  }

  void _showVictoryLoot() {
    final lootGold = 5 + (_enemy?.maxHealth ?? 0) ~/ 3;
    widget.player.gold += lootGold;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Victory!'),
        content: Text('You defeated ${_enemy?.name ?? "the enemy"}.\n\n+$lootGold gold'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              widget.onVictory();
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _showDefeatDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Defeat'),
        content: const Text('You have been defeated.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              widget.player.health = widget.player.maxHealth;
              widget.onDefeat();
            },
            child: const Text('New run'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              widget.onDefeat();
              SystemNavigator.pop();
            },
            child: const Text('Quit'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_enemy == null) {
      return const Material(
        color: Colors.grey,
        child: Center(child: Text('Unknown enemy', style: TextStyle(color: Colors.white))),
      );
    }

    return Material(
      color: Colors.grey[900],
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white54),
                    onPressed: null, // no escape during combat
                    tooltip: 'No exit during combat',
                  ),
                  const Text(
                    'Combat',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _CharacterCard(
                          name: 'Hero',
                          currentHealth: widget.player.health,
                          maxHealth: widget.player.maxHealth,
                          isEnemy: false,
                        ),
                        const SizedBox(height: 12),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            'Abilities',
                            style: TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                        ),
                        const SizedBox(height: 4),
                        _EquippedItemsBar(
                          items: _getHeroItemsForCombat(),
                          progress: _heroCooldownProgress,
                          isEnemy: false,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _CharacterCard(
                          name: _enemy!.name,
                          currentHealth: _enemyHealth,
                          maxHealth: _enemy!.maxHealth,
                          isEnemy: true,
                        ),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            '${_enemy!.name} abilities',
                            style: const TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                        ),
                        const SizedBox(height: 4),
                        _EquippedItemsBar(
                          items: _enemy!.equippedItems,
                          progress: _enemyCooldownProgress,
                          isEnemy: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _CharacterCard extends StatelessWidget {
  final String name;
  final int currentHealth;
  final int maxHealth;
  final bool isEnemy;

  const _CharacterCard({
    required this.name,
    required this.currentHealth,
    required this.maxHealth,
    required this.isEnemy,
  });

  @override
  Widget build(BuildContext context) {
    final fraction = maxHealth > 0 ? (currentHealth / maxHealth).clamp(0.0, 1.0) : 0.0;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: isEnemy ? Colors.red.shade900 : Colors.blue.shade900,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[700]!, width: 2),
          ),
          child: Icon(
            isEnemy ? Icons.person_off : Icons.person,
            size: 48,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 120,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: fraction,
                  backgroundColor: Colors.grey[800],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    fraction > 0.25 ? Colors.green : Colors.red,
                  ),
                  minHeight: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$currentHealth / $maxHealth',
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EquippedItemsBar extends StatelessWidget {
  final List<ItemModel> items;
  final List<double> progress;
  final bool isEnemy;

  const _EquippedItemsBar({
    required this.items,
    required this.progress,
    this.isEnemy = false,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty && !isEnemy) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[850],
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            'No weapons equipped — equip items in Character to deal damage.',
            style: TextStyle(color: Colors.grey, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (items.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 88,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final item = items[index];
          final prog = index < progress.length ? progress[index].clamp(0.0, 1.0) : 0.0;
          return _CooldownSquircle(
            item: item,
            cooldownProgress: prog,
            isEnemy: isEnemy,
          );
        },
      ),
    );
  }
}

/// Single equipped item tile with bottom-to-top cooldown fill overlay.
/// Background and overlay use the same size so the progress bar matches the box exactly.
class _CooldownSquircle extends StatelessWidget {
  static const double _size = 72;
  static const double _radius = 18;

  final ItemModel item;
  final double cooldownProgress;
  final bool isEnemy;

  const _CooldownSquircle({
    required this.item,
    required this.cooldownProgress,
    this.isEnemy = false,
  });

  @override
  Widget build(BuildContext context) {
    final overlayColor = isEnemy
        ? Colors.red.withValues(alpha: 0.5)
        : Colors.blue.withValues(alpha: 0.5);
    return SizedBox(
      width: _size,
      height: _size,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_radius),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background box: full size so it matches the clip
            Container(
              width: _size,
              height: _size,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(_radius),
                border: Border.all(color: Colors.grey[700]!, width: 1),
              ),
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (item.damage > 0)
                      Text(
                        '${item.damage} dmg',
                        style: TextStyle(color: Colors.grey[400], fontSize: 10),
                      ),
                  ],
                ),
              ),
            ),
            // Cooldown overlay: same size, fills from bottom to top
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: _size * cooldownProgress.clamp(0.0, 1.0),
              child: Container(
                width: _size,
                color: overlayColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

