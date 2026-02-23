import 'package:flutter/material.dart';

import '../models/item_model.dart';
import '../models/player.dart';

/// Full-screen character and inventory view. Inventory is a grid of squircle item tiles.
/// Tapping an item selects it; selected item shows a gold border and details below.
class CharacterView extends StatefulWidget {
  final Player player;

  const CharacterView({super.key, required this.player});

  @override
  State<CharacterView> createState() => _CharacterViewState();
}

class _CharacterViewState extends State<CharacterView> {
  /// Slot index of the currently selected inventory item, or null if none.
  int? _selectedSlotIndex;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.grey[900],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Character & Inventory',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 23,
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Stats',
                    style: TextStyle(
                      color: Colors.grey[300],
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _StatRow('Health', '${widget.player.health} / ${widget.player.maxHealth}'),
                  _StatRow('Energy', '${widget.player.energy} / ${widget.player.maxEnergy}'),
                  _StatRow('Gold', '${widget.player.gold}'),
                  const SizedBox(height: 16),
                  Text(
                    'Inventory',
                    style: TextStyle(
                      color: Colors.grey[300],
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _InventoryGrid(
                    player: widget.player,
                    selectedSlotIndex: _selectedSlotIndex,
                    onSlotTap: (index) {
                      setState(() {
                        if (_selectedSlotIndex == index) {
                          _selectedSlotIndex = null;
                        } else {
                          _selectedSlotIndex = index;
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  _ItemInfoPanel(
                    item: _selectedSlotIndex != null
                        ? widget.player.getItemAtSlot(_selectedSlotIndex!)
                        : null,
                    player: widget.player,
                    onToggled: () => setState(() {}),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InventoryGrid extends StatelessWidget {
  final Player player;
  final int? selectedSlotIndex;
  final ValueChanged<int> onSlotTap;

  const _InventoryGrid({
    required this.player,
    required this.selectedSlotIndex,
    required this.onSlotTap,
  });

  @override
  Widget build(BuildContext context) {
    const crossAxisCount = 5;
    const spacing = 8.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = (constraints.maxWidth - spacing * (crossAxisCount - 1)) / crossAxisCount;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: List.generate(Player.boardSize, (index) {
            final item = player.shouldRenderItemAtSlot(index) ? player.getItemAtSlot(index) : null;
            final isSelected = selectedSlotIndex == index;
            final itemKey = item?.key;
            final isEquipped = itemKey != null && player.isEquipped(itemKey);
            return SizedBox(
              width: width,
              height: width,
              child: GestureDetector(
                onTap: () {
                  if (item != null) onSlotTap(index);
                },
                child: _SquircleTile(
                  item: item,
                  isSelected: isSelected,
                  isEquipped: isEquipped,
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

class _SquircleTile extends StatelessWidget {
  final ItemModel? item;
  final bool isSelected;
  final bool isEquipped;

  const _SquircleTile({this.item, this.isSelected = false, this.isEquipped = false});

  @override
  Widget build(BuildContext context) {
    final borderColor = isSelected
        ? Colors.amber
        : isEquipped
            ? Colors.green
            : Colors.grey[700]!;

    return Container(
      decoration: BoxDecoration(
        color: item != null ? Colors.grey[800] : Colors.grey[850],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: borderColor,
          width: isSelected ? 3 : 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: item == null
              ? Center(
                  child: Icon(Icons.inventory_2_outlined, color: Colors.grey[600], size: 32),
                )
              : Center(
                  child: Text(
                    item!.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
        ),
      ),
    );
  }
}

/// Panel below the inventory showing the selected item's details.
/// Equip/Unequip button is in the top-right of the box, same row as the item name.
class _ItemInfoPanel extends StatelessWidget {
  final ItemModel? item;
  final Player player;
  final VoidCallback onToggled;

  const _ItemInfoPanel({
    this.item,
    required this.player,
    required this.onToggled,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[700]!),
      ),
      child: item == null
          ? Center(
              child: Text(
                'Select an item to view details',
                style: TextStyle(color: Colors.grey[500], fontSize: 15),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        item!.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (item!.slotType == ItemSlotType.weapon || item!.slotType == ItemSlotType.armor || item!.slotType == ItemSlotType.consumable)
                      _EquipChip(
                        item: item!,
                        player: player,
                        onToggled: onToggled,
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                if (item!.slotType == ItemSlotType.weapon) ...[
                  _InfoRow('Slot', item!.isTwoHanded ? 'Two-handed (uses 2 slots)' : 'One-handed'),
                  _InfoRow('Damage', '${item!.damage}'),
                  _InfoRow('Cooldown', '${item!.cooldownDisplay}s'),
                ],
                if (item!.slotType == ItemSlotType.armor)
                  _InfoRow('Slot', 'Armor (1 slot)'),
                if (item!.isConsumable && item!.consumableHeal > 0)
                  _InfoRow('Use in combat', 'Tap to heal ${item!.consumableHeal} HP (consumed)'),
                if (item!.cost > 0) _InfoRow('Value', '${item!.cost} gold'),
              ],
            ),
    );
  }
}

/// Orange Equip/Unequip chip in the item panel header. Respects slot limits (2 weapons, 1 armor, 2 consumables).
class _EquipChip extends StatelessWidget {
  final ItemModel item;
  final Player player;
  final VoidCallback onToggled;

  const _EquipChip({
    required this.item,
    required this.player,
    required this.onToggled,
  });

  @override
  Widget build(BuildContext context) {
    final equipped = player.isEquipped(item.key);
    final canEquip = equipped || player.canEquipMore(item.slotType);
    return Material(
      color: canEquip ? Colors.orange.shade700 : Colors.grey[600],
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: () {
          if (equipped) {
            player.setEquipped(item.key, false);
            onToggled();
          } else if (player.canEquipMore(item.slotType)) {
            final ok = player.setEquipped(item.key, true);
            if (ok) {
              onToggled();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('No ${item.slotType.name} slot available')),
              );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('No ${item.slotType.name} slot available (max ${item.slotType == ItemSlotType.weapon ? "2" : item.slotType == ItemSlotType.consumable ? "2" : "1"})')),
            );
          }
        },
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                equipped ? Icons.check_circle : Icons.add_circle_outline,
                size: 16,
                color: Colors.white,
              ),
              const SizedBox(width: 4),
              Text(
                equipped ? 'Unequip' : 'Equip',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 15)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 16)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
