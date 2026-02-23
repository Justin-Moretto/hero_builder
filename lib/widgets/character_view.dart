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
                  if (_selectedSlotIndex != null) ...[
                    const SizedBox(height: 8),
                    _EquipButton(
                      player: widget.player,
                      itemKey: widget.player.board[_selectedSlotIndex!],
                      onToggled: () => setState(() {}),
                    ),
                  ],
                  const SizedBox(height: 16),
                  _ItemInfoPanel(
                    item: _selectedSlotIndex != null
                        ? widget.player.getItemAtSlot(_selectedSlotIndex!)
                        : null,
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
    final isWeapon = item != null && item!.damage > 0;
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
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
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
                    if (isWeapon) ...[
                      const SizedBox(height: 2),
                      Text(
                        '${item!.damage} dmg • ${item!.cooldownDisplay}s',
                        style: TextStyle(color: Colors.grey[400], fontSize: 12),
                      ),
                    ],
                    if (isEquipped)
                      Text(
                        'Equipped',
                        style: TextStyle(color: Colors.green[300], fontSize: 10),
                      ),
                  ],
                ),
        ),
      ),
    );
  }
}

/// Panel below the inventory showing the selected item's details.
class _EquipButton extends StatelessWidget {
  final Player player;
  final String? itemKey;
  final VoidCallback onToggled;

  const _EquipButton({
    required this.player,
    required this.itemKey,
    required this.onToggled,
  });

  @override
  Widget build(BuildContext context) {
    if (itemKey == null) return const SizedBox.shrink();
    final item = player.getItemByKey(itemKey!);
    if (item == null || item.damage <= 0) return const SizedBox.shrink();
    final equipped = player.isEquipped(itemKey!);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextButton.icon(
        onPressed: () {
          player.setEquipped(itemKey!, !equipped);
          onToggled();
        },
        icon: Icon(equipped ? Icons.check_circle : Icons.add_circle_outline, size: 18, color: Colors.white70),
        label: Text(equipped ? 'Unequip' : 'Equip'),
        style: TextButton.styleFrom(foregroundColor: Colors.white70),
      ),
    );
  }
}

class _ItemInfoPanel extends StatelessWidget {
  final ItemModel? item;

  const _ItemInfoPanel({this.item});

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
                Text(
                  item!.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                if (item!.damage > 0) ...[
                  _InfoRow('Damage', '${item!.damage}'),
                  _InfoRow('Cooldown', '${item!.cooldownDisplay}s'),
                ],
                if (item!.cost > 0) _InfoRow('Value', '${item!.cost} gold'),
              ],
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
