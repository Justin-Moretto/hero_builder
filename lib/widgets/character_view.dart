import 'package:flutter/material.dart';

import '../models/item_model.dart';
import '../models/player.dart';

/// Full-screen character and inventory view. Tabs: Equipment and Loot. Inventory is a grid of squircle item tiles.
/// Tapping an item selects it; selected item shows accent border and details in a fixed-size panel below.
class CharacterView extends StatefulWidget {
  final Player player;

  const CharacterView({super.key, required this.player});

  @override
  State<CharacterView> createState() => _CharacterViewState();
}

class _CharacterViewState extends State<CharacterView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  /// Slot index of the currently selected item in the active tab, or null if none.
  int? _selectedSlotIndex;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      setState(() => _selectedSlotIndex = null);
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  ItemModel? get _selectedItem {
    if (_selectedSlotIndex == null) return null;
    if (_tabController.index == 0)
      return widget.player.getItemAtSlot(_selectedSlotIndex!);
    return widget.player.getLootItemAtSlot(_selectedSlotIndex!);
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
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
                  _HeroAndEquippedSlots(player: widget.player),
                  const SizedBox(height: 12),
                  Text(
                    'Stats',
                    style: TextStyle(
                      color: Colors.grey[300],
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _StatRow('Health',
                      '${widget.player.health} / ${widget.player.maxHealth}'),
                  _StatRow('Energy',
                      '${widget.player.energy} / ${widget.player.maxEnergy}'),
                  _StatRow('Gold', '${widget.player.gold}'),
                  const SizedBox(height: 16),
                  TabBar(
                    controller: _tabController,
                    onTap: (_) => setState(() => _selectedSlotIndex = null),
                    labelColor: accent,
                    unselectedLabelColor: Colors.grey[400],
                    indicatorColor: accent,
                    tabs: const [
                      Tab(text: 'Equipment'),
                      Tab(text: 'Loot'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      const crossAxisCount = 5;
                      const spacing = 8.0;
                      final tileSize = (constraints.maxWidth -
                              spacing * (crossAxisCount - 1)) /
                          crossAxisCount;
                      final gridHeight = 2 * tileSize + spacing;
                      return SizedBox(
                        height: gridHeight,
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _InventoryGrid(
                              player: widget.player,
                              isEquipment: true,
                              selectedSlotIndex: _tabController.index == 0
                                  ? _selectedSlotIndex
                                  : null,
                              onSlotTap: (index) {
                                setState(() {
                                  _selectedSlotIndex =
                                      (_selectedSlotIndex == index)
                                          ? null
                                          : index;
                                });
                              },
                            ),
                            _InventoryGrid(
                              player: widget.player,
                              isEquipment: false,
                              selectedSlotIndex: _tabController.index == 1
                                  ? _selectedSlotIndex
                                  : null,
                              onSlotTap: (index) {
                                setState(() {
                                  _selectedSlotIndex =
                                      (_selectedSlotIndex == index)
                                          ? null
                                          : index;
                                });
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  _ItemInfoPanel(
                    item: _selectedItem,
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

/// Hero image with the 5 equipped slots next to it: row of 3 (weapon, armor, weapon), row of 2 (consumables).
class _HeroAndEquippedSlots extends StatelessWidget {
  final Player player;

  const _HeroAndEquippedSlots({required this.player});

  @override
  Widget build(BuildContext context) {
    const heroSize = 100.0;
    const slotSize = 52.0;
    const gap = 6.0;

    final w0 = player.weaponSlots[0] != null ? player.getItemByKey(player.weaponSlots[0]!) : null;
    final armor = player.armorSlot != null ? player.getItemByKey(player.armorSlot!) : null;
    final w1 = player.weaponSlots[1] != null ? player.getItemByKey(player.weaponSlots[1]!) : null;
    final c0 = player.consumableSlots[0] != null ? player.getItemByKey(player.consumableSlots[0]!) : null;
    final c1 = player.consumableSlots[1] != null ? player.getItemByKey(player.consumableSlots[1]!) : null;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: heroSize,
          height: heroSize,
          decoration: BoxDecoration(
            color: Colors.grey[850],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[700]!),
          ),
          child: Center(
            child: Icon(Icons.person_outline, size: 48, color: Colors.grey[600]),
          ),
        ),
        SizedBox(width: gap * 2),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _EquippedSlotTile(item: w0, size: slotSize, label: 'W'),
                SizedBox(width: gap),
                _EquippedSlotTile(item: armor, size: slotSize, label: 'A'),
                SizedBox(width: gap),
                _EquippedSlotTile(item: w1, size: slotSize, label: 'W'),
              ],
            ),
            SizedBox(height: gap),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _EquippedSlotTile(item: c0, size: slotSize, label: 'C'),
                SizedBox(width: gap),
                _EquippedSlotTile(item: c1, size: slotSize, label: 'C'),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _EquippedSlotTile extends StatelessWidget {
  final ItemModel? item;
  final double size;
  final String label;

  const _EquippedSlotTile({this.item, required this.size, required this.label});

  Widget _buildEquippedSlotContent(ItemModel item) {
    final path = item.itemImagePath;
    final textContent = Center(
      child: Text(
        item.name,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
    if (path != null) {
      return Image.asset(
        path,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => textContent,
      );
    }
    return textContent;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: item != null ? Colors.grey[800] : Colors.grey[850],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[700]!),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: item == null
              ? Center(
                  child: Text(
                    label,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                )
              : _buildEquippedSlotContent(item!),
        ),
      ),
    );
  }
}

class _InventoryGrid extends StatelessWidget {
  final Player player;
  final bool isEquipment;
  final int? selectedSlotIndex;
  final ValueChanged<int> onSlotTap;

  const _InventoryGrid({
    required this.player,
    required this.isEquipment,
    required this.selectedSlotIndex,
    required this.onSlotTap,
  });

  @override
  Widget build(BuildContext context) {
    const crossAxisCount = 5;
    const spacing = 8.0;
    final slotCount = isEquipment ? Player.boardSize : Player.lootSize;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = (constraints.maxWidth - spacing * (crossAxisCount - 1)) /
            crossAxisCount;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: List.generate(slotCount, (index) {
            final item = isEquipment
                ? (player.shouldRenderItemAtSlot(index)
                    ? player.getItemAtSlot(index)
                    : null)
                : (player.shouldRenderLootAtSlot(index)
                    ? player.getLootItemAtSlot(index)
                    : null);
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

  const _SquircleTile(
      {this.item, this.isSelected = false, this.isEquipped = false});

  Widget _buildItemContent(ItemModel item) {
    final textContent = Center(
      child: Text(
        item.name,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
    final path = item.itemImagePath;
    if (path != null) {
      return Image.asset(
        path,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => textContent,
      );
    }
    return textContent;
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final borderColor = isSelected
        ? accent
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
                  child: Icon(Icons.inventory_2_outlined,
                      color: Colors.grey[600], size: 32),
                )
              : _buildItemContent(item!),
        ),
      ),
    );
  }
}

/// Fixed-height panel below the inventory. Always visible; shows selected item details or placeholder.
/// Equip/Unequip button uses app accent (amber).
const double _kItemInfoPanelHeight = 140;

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
      height: _kItemInfoPanelHeight,
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
          : SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
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
                      if (item!.slotType == ItemSlotType.weapon ||
                          item!.slotType == ItemSlotType.armor ||
                          item!.slotType == ItemSlotType.consumable)
                        _EquipChip(
                          item: item!,
                          player: player,
                          onToggled: onToggled,
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (item!.slotType == ItemSlotType.weapon) ...[
                    _InfoRow(
                        'Slot',
                        item!.isTwoHanded
                            ? 'Two-handed (uses 2 slots)'
                            : 'One-handed'),
                    _InfoRow('Damage', '${item!.damage}'),
                    _InfoRow('Cooldown', '${item!.cooldownDisplay}s'),
                  ],
                  if (item!.slotType == ItemSlotType.armor)
                    _InfoRow('Slot', 'Armor (1 slot)'),
                  if (item!.isConsumable && item!.consumableHeal > 0)
                    _InfoRow('Use in combat',
                        'Tap to heal ${item!.consumableHeal} HP (consumed)'),
                  if (item!.cost > 0) _InfoRow('Value', '${item!.cost} gold'),
                ],
              ),
            ),
    );
  }
}

/// Amber (app accent) Equip/Unequip chip in the item panel header. Respects slot limits (2 weapons, 1 armor, 2 consumables).
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
    final accent = Theme.of(context).colorScheme.primary;
    final equipped = player.isEquipped(item.key);
    final canEquip = equipped || player.canEquipMore(item.slotType);
    return Material(
      color: canEquip ? accent : Colors.grey[600],
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
                SnackBar(
                    content: Text('No ${item.slotType.name} slot available')),
              );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(
                      'No ${item.slotType.name} slot available (max ${item.slotType == ItemSlotType.weapon ? "2" : item.slotType == ItemSlotType.consumable ? "2" : "1"})')),
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
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500)),
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
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
