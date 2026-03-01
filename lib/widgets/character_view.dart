import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/widgets/widgets.dart';

import '../models/item_model.dart';
import '../models/player.dart';
import '../phases/shop_screen.dart';

/// Full-screen character and inventory view. Tabs: Equipment and Loot. Inventory is a grid of squircle item tiles.
/// Tapping an item selects it; selected item shows accent border and details in a fixed-size panel below.
class CharacterView extends StatefulWidget {
  final Player player;
  final bool isInShop;

  const CharacterView({super.key, required this.player, this.isInShop = false});

  @override
  State<CharacterView> createState() => _CharacterViewState();
}

class _CharacterViewState extends State<CharacterView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  /// Item key of the currently selected item (survives reorder).
  String? _selectedItemKey;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      setState(() => _selectedItemKey = null);
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  ItemModel? get _selectedItem {
    if (_selectedItemKey == null) return null;
    return widget.player.getItemByKey(_selectedItemKey!);
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
                    onTap: (_) => setState(() => _selectedItemKey = null),
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
                      final eqKeys = widget.player.board
                          .where((k) => k != null)
                          .cast<String>()
                          .toList();
                      final lootKeys = widget.player.loot
                          .where((k) => k != null)
                          .cast<String>()
                          .toList();
                      final maxItems = eqKeys.length > lootKeys.length
                          ? eqKeys.length
                          : lootKeys.length;
                      final rowCount = maxItems == 0
                          ? 1
                          : (maxItems + crossAxisCount - 1) ~/ crossAxisCount;
                      const gridVerticalPadding = 12.0;
                      final contentHeight =
                          rowCount * tileSize + (rowCount - 1) * spacing;
                      final gridHeight =
                          contentHeight + 2 * gridVerticalPadding;
                      final eqSelectedIndex = eqKeys.contains(_selectedItemKey)
                          ? eqKeys.indexOf(_selectedItemKey!)
                          : null;
                      final lootSelectedIndex =
                          lootKeys.contains(_selectedItemKey)
                              ? lootKeys.indexOf(_selectedItemKey!)
                              : null;
                      return SizedBox(
                        height: gridHeight,
                        child: TabBarView(
                          controller: _tabController,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            _InventoryGrid(
                              player: widget.player,
                              isEquipment: true,
                              crossAxisCount: crossAxisCount,
                              spacing: spacing,
                              gridHeight: gridHeight,
                              tileSize: tileSize,
                              selectedSlotIndex: _tabController.index == 0
                                  ? eqSelectedIndex
                                  : null,
                              onSlotTap: (index) {
                                setState(() {
                                  final key = eqKeys[index];
                                  _selectedItemKey =
                                      _selectedItemKey == key ? null : key;
                                });
                              },
                              onDragStarted: (index) => setState(
                                  () => _selectedItemKey = eqKeys[index]),
                              onReorderDone: () => setState(() {}),
                            ),
                            _InventoryGrid(
                              player: widget.player,
                              isEquipment: false,
                              crossAxisCount: crossAxisCount,
                              spacing: spacing,
                              gridHeight: gridHeight,
                              tileSize: tileSize,
                              selectedSlotIndex: _tabController.index == 1
                                  ? lootSelectedIndex
                                  : null,
                              onSlotTap: (index) {
                                setState(() {
                                  final key = lootKeys[index];
                                  _selectedItemKey =
                                      _selectedItemKey == key ? null : key;
                                });
                              },
                              onDragStarted: (index) => setState(
                                  () => _selectedItemKey = lootKeys[index]),
                              onReorderDone: () => setState(() {}),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  _SelectedItemBar(
                    item: _selectedItem,
                    selectedItemKey: _selectedItemKey,
                    player: widget.player,
                    isInShop: widget.isInShop,
                    onAction: () => setState(() {}),
                    onItemRemoved: () =>
                        setState(() => _selectedItemKey = null),
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

/// Hero image with the 5 equipped slots (display only). Equip/unequip via the item panel chip.
class _HeroAndEquippedSlots extends StatelessWidget {
  final Player player;

  const _HeroAndEquippedSlots({required this.player});

  @override
  Widget build(BuildContext context) {
    const heroSize = 100.0;
    const slotSize = 52.0;
    const gap = 6.0;

    final w0 = player.weaponSlots[0] != null
        ? player.getItemByKey(player.weaponSlots[0]!)
        : null;
    final armor = player.armorSlot != null
        ? player.getItemByKey(player.armorSlot!)
        : null;
    final w1 = player.weaponSlots[1] != null
        ? player.getItemByKey(player.weaponSlots[1]!)
        : null;
    final c0 = player.consumableSlots[0] != null
        ? player.getItemByKey(player.consumableSlots[0]!)
        : null;
    final c1 = player.consumableSlots[1] != null
        ? player.getItemByKey(player.consumableSlots[1]!)
        : null;

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
          child: ClipRRect(
            borderRadius: BorderRadius.circular(11),
            child: Image.asset(
              '${ItemModel.itemImagesPrefix}hero.png',
              fit: BoxFit.cover,
              width: heroSize,
              height: heroSize,
              errorBuilder: (_, __, ___) => Center(
                child: Icon(Icons.person_outline, size: 48, color: Colors.grey[600]),
              ),
            ),
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
                    style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                  ),
                )
              : _buildEquippedSlotContent(item!),
        ),
      ),
    );
  }
}

/// Amber halo (glow only) for selection and drag. Single shadow, modest size so it doesn't stack or clip.
final _kAmberHaloShadows = [
  BoxShadow(
    color: Colors.amber.withValues(alpha: 0.55),
    blurRadius: 9,
    spreadRadius: 2,
    offset: Offset.zero,
  ),
];

/// Drag feedback: glow only, no fill. Single stable instance so the package never stacks copies.
final _kDragFeedbackDecoration = BoxDecoration(
  color: Colors.transparent,
  borderRadius: BorderRadius.circular(20),
  boxShadow: _kAmberHaloShadows,
);

class _InventoryGrid extends StatelessWidget {
  final Player player;
  final bool isEquipment;
  final int crossAxisCount;
  final double spacing;
  final double gridHeight;
  final double tileSize;
  final int? selectedSlotIndex;
  final ValueChanged<int> onSlotTap;
  final ValueChanged<int>? onDragStarted;
  final VoidCallback? onReorderDone;

  const _InventoryGrid({
    required this.player,
    required this.isEquipment,
    required this.crossAxisCount,
    required this.spacing,
    required this.gridHeight,
    required this.tileSize,
    required this.selectedSlotIndex,
    required this.onSlotTap,
    this.onDragStarted,
    this.onReorderDone,
  });

  @override
  Widget build(BuildContext context) {
    final sourceList = isEquipment ? player.board : player.loot;
    final allKeys = sourceList.where((k) => k != null).cast<String>().toList();

    if (allKeys.isEmpty) {
      return SizedBox(height: gridHeight, width: double.infinity);
    }

    final children = List<Widget>.generate(
      allKeys.length,
      (i) {
        final key = allKeys[i];
        final item = player.getItemByKey(key)!;
        return KeyedSubtree(
          key: ValueKey(key),
          child: GestureDetector(
            onTap: () => onSlotTap(i),
            child: _SquircleTile(
              item: item,
              isSelected: selectedSlotIndex == i,
              isEquipped: player.isEquipped(key),
            ),
          ),
        );
      },
    );

    return SizedBox(
      height: gridHeight,
      child: ReorderableBuilder<String>(
        longPressDelay: const Duration(milliseconds: 225),
        onReorder: (reorderedListFunction) {
          final newOrder = reorderedListFunction(allKeys);
          if (isEquipment) {
            player.setBoardCompactOrder(newOrder);
          } else {
            player.setLootCompactOrder(newOrder);
          }
          onReorderDone?.call();
        },
        onDragStarted: onDragStarted,
        feedbackScaleFactor: 1.08,
        dragChildBoxDecoration: _kDragFeedbackDecoration,
        builder: (reorderedChildren) => GridView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: spacing,
            crossAxisSpacing: spacing,
            childAspectRatio: 1,
          ),
          children: reorderedChildren,
        ),
        children: children,
      ),
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
    final borderColor = isEquipped ? Colors.orange : Colors.grey[700]!;

    return Container(
      decoration: BoxDecoration(
        color: item != null ? Colors.grey[800] : Colors.grey[850],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: isSelected ? _kAmberHaloShadows : null,
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

/// Bar below the inventory: selected item name + Info, Trash, Sell (Sell only when isInShop).
class _SelectedItemBar extends StatelessWidget {
  final ItemModel? item;
  final String? selectedItemKey;
  final Player player;
  final bool isInShop;
  final VoidCallback onAction;
  final VoidCallback? onItemRemoved;

  const _SelectedItemBar({
    this.item,
    this.selectedItemKey,
    required this.player,
    required this.isInShop,
    required this.onAction,
    this.onItemRemoved,
  });

  bool get _itemOnBoard =>
      selectedItemKey != null && player.board.contains(selectedItemKey);
  bool get _itemOnLoot =>
      selectedItemKey != null && player.loot.contains(selectedItemKey);

  void _trash() {
    if (selectedItemKey == null) return;
    if (_itemOnBoard) {
      player.removeItemFromBoard(selectedItemKey!);
    } else if (_itemOnLoot) {
      player.removeItemFromLoot(selectedItemKey!);
    }
    onItemRemoved?.call();
    onAction();
  }

  void _sell() {
    if (item == null || selectedItemKey == null || !isInShop) return;
    if (player.isEquipped(item!.key)) return;
    final sellValue = item!.cost ~/ 2;
    player.gold += sellValue;
    if (_itemOnBoard) {
      player.removeItemFromBoard(selectedItemKey!);
    } else if (_itemOnLoot) {
      player.removeItemFromLoot(selectedItemKey!);
    }
    onItemRemoved?.call();
    onAction();
  }

  void _toggleEquip(BuildContext context) {
    if (item == null) return;
    final equipped = player.isEquipped(item!.key);
    if (equipped) {
      player.setEquipped(item!.key, false);
    } else if (player.canEquipMore(item!.slotType)) {
      final ok = player.setEquipped(item!.key, true);
      if (!ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'No ${item!.slotType.name} slot available (max ${item!.slotType == ItemSlotType.weapon ? "2" : item!.slotType == ItemSlotType.consumable ? "2" : "1"})',
            ),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No ${item!.slotType.name} slot available (max ${item!.slotType == ItemSlotType.weapon ? "2" : item!.slotType == ItemSlotType.consumable ? "2" : "1"})',
          ),
        ),
      );
    }
    onAction();
  }

  static const _chipPadding = EdgeInsets.symmetric(horizontal: 12, vertical: 8);

  Widget _actionChip(
    BuildContext context, {
    required VoidCallback? onPressed,
    required IconData icon,
    required String label,
    Color? foregroundColor,
    Color? borderColor,
  }) {
    final color = foregroundColor ?? Colors.grey[300];
    final border = borderColor ?? Colors.grey[600]!;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: _chipPadding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: onPressed != null ? border : Colors.grey[700]!),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon,
                  size: 18,
                  color: onPressed != null ? color : Colors.grey[600]),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: onPressed != null ? color : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final canShowEquip = item != null &&
        (item!.slotType == ItemSlotType.weapon ||
            item!.slotType == ItemSlotType.armor ||
            item!.slotType == ItemSlotType.consumable);
    final equipped = item != null && player.isEquipped(item!.key);
    final canEquip =
        canShowEquip && (equipped || player.canEquipMore(item!.slotType));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[700]!),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              item?.name ?? 'Select an item',
              style: TextStyle(
                color: item != null ? Colors.white : Colors.grey[500],
                fontSize: 16,
                fontWeight: item != null ? FontWeight.w600 : FontWeight.normal,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          _actionChip(
            context,
            onPressed: item != null
                ? () => showItemInfoDialog(context, item: item!, player: player)
                : null,
            icon: Icons.info_outline,
            label: 'Info',
          ),
          const SizedBox(width: 6),
          _actionChip(
            context,
            onPressed: item != null ? _trash : null,
            icon: Icons.delete_outline,
            label: 'Trash',
            foregroundColor: Colors.red[300],
            borderColor: Colors.red[700],
          ),
          if (canShowEquip) ...[
            const SizedBox(width: 6),
            _actionChip(
              context,
              onPressed: canEquip ? () => _toggleEquip(context) : null,
              icon: equipped ? Icons.check_circle : Icons.add_circle_outline,
              label: equipped ? 'Unequip' : 'Equip',
              foregroundColor: accent,
              borderColor: accent,
            ),
          ],
          if (isInShop) ...[
            const SizedBox(width: 6),
            _actionChip(
              context,
              onPressed:
                  item != null && !player.isEquipped(item!.key) ? _sell : null,
              icon: Icons.sell_outlined,
              label: item != null ? 'Sell (${item!.cost ~/ 2})' : 'Sell',
              foregroundColor: accent,
              borderColor: accent,
            ),
          ],
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
