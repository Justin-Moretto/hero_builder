import 'package:flutter/material.dart';

import '../models/item_model.dart';
import '../models/player.dart';

/// Shop screen: back button, gold, Buy/Sell tabs. Sell only available here (in shop).
/// [onPurchasedItemAt] is called with the index of the bought item so the parent can remove it from stock.
class ShopScreen extends StatefulWidget {
  final Player player;
  final List<ItemModel> itemsForSale;
  final VoidCallback onBack;
  final void Function(int index)? onPurchasedItemAt;
  final VoidCallback? onPurchased;

  const ShopScreen({
    super.key,
    required this.player,
    required this.itemsForSale,
    required this.onBack,
    this.onPurchasedItemAt,
    this.onPurchased,
  });

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  int _tabIndex = 0; // 0 = Buy, 1 = Sell

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.grey[900],
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: widget.onBack,
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    tooltip: 'Back to biome',
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Shop',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Gold: ${widget.player.gold}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 19,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.grey),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  _ShopTab(
                    label: 'Buy',
                    selected: _tabIndex == 0,
                    onTap: () => setState(() => _tabIndex = 0),
                  ),
                  const SizedBox(width: 12),
                  _ShopTab(
                    label: 'Sell',
                    selected: _tabIndex == 1,
                    onTap: () => setState(() => _tabIndex = 1),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _tabIndex == 0
                  ? ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: widget.itemsForSale.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) => _BuyItemTile(
                        item: widget.itemsForSale[index],
                        player: widget.player,
                        onPurchased: () {
                          widget.onPurchasedItemAt?.call(index);
                          widget.onPurchased?.call();
                        },
                      ),
                    )
                  : _SellInventoryList(
                      player: widget.player,
                      onSold: () {
                        setState(() {});
                        widget.onPurchased?.call();
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShopTab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ShopTab({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: selected ? colorScheme.secondary : Colors.grey[800],
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : Colors.grey[300],
              fontSize: 16,
              fontWeight: selected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

/// Shows a popup with full item details and a Buy or Sell button (same behavior as list row).
void _showShopItemDetailDialog(
  BuildContext context, {
  required ItemModel item,
  required Player player,
  bool isSell = false,
  int? sellValue,
  VoidCallback? onSell,
  VoidCallback? onBuy,
}) {
  final isEquipped = isSell && player.isEquipped(item.key);
  final canSell = isSell && !isEquipped;
  final canBuy = !isSell && player.gold >= item.cost && player.hasInventorySpace(1);

  showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Row(
        children: [
          if (item.itemImagePath != null) ...[
            SizedBox(
              width: 48,
              height: 48,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  item.itemImagePath!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(child: Text(item.name)),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.slotType == ItemSlotType.weapon) ...[
              _DetailRow('Slot', item.isTwoHanded ? 'Two-handed (uses 2 slots)' : 'One-handed'),
              _DetailRow('Damage', '${item.damage}'),
              _DetailRow('Cooldown', '${item.cooldownDisplay}s'),
            ],
            if (item.slotType == ItemSlotType.armor)
              _DetailRow('Slot', 'Armor (1 slot)'),
            if (item.isConsumable && item.consumableHeal > 0)
              _DetailRow('Use in combat', 'Tap to heal ${item.consumableHeal} HP (consumed)'),
            if (isSell && sellValue != null)
              _DetailRow('Sell value', '$sellValue gold')
            else if (item.cost > 0)
              _DetailRow('Value', '${item.cost} gold'),
            if (isSell && isEquipped)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text('Equipped — unequip to sell.', style: TextStyle(color: Colors.grey, fontSize: 13)),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('Close'),
        ),
        if (isSell && onSell != null)
          TextButton(
            onPressed: canSell
                ? () {
                    onSell();
                    Navigator.of(ctx).pop();
                  }
                : null,
            child: const Text('Sell'),
          )
        else if (!isSell && onBuy != null)
          TextButton(
            onPressed: canBuy ? onBuy : null,
            child: const Text('Buy'),
          ),
      ],
    ),
  );
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          const SizedBox(width: 16),
          Flexible(child: Text(value, style: const TextStyle(fontSize: 14), textAlign: TextAlign.end)),
        ],
      ),
    );
  }
}

/// Sell tab: list of player inventory items; sell for half value (only in shop).
class _SellInventoryList extends StatelessWidget {
  final Player player;
  final VoidCallback onSold;

  const _SellInventoryList({required this.player, required this.onSold});

  @override
  Widget build(BuildContext context) {
    final items = <ItemModel>[];
    for (final key in player.board) {
      if (key != null) {
        final item = player.getItemByKey(key);
        if (item != null) items.add(item);
      }
    }
    if (items.isEmpty) {
      return Center(
        child: Text(
          'No items to sell',
          style: TextStyle(color: Colors.grey[400], fontSize: 16),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = items[index];
        final sellValue = item.cost ~/ 2;
        return _SellItemTile(
          item: item,
          sellValue: sellValue,
          player: player,
          onSold: onSold,
        );
      },
    );
  }
}

class _SellItemTile extends StatelessWidget {
  final ItemModel item;
  final int sellValue;
  final Player player;
  final VoidCallback onSold;

  const _SellItemTile({
    required this.item,
    required this.sellValue,
    required this.player,
    required this.onSold,
  });

  @override
  Widget build(BuildContext context) {
    final isEquipped = player.isEquipped(item.key);
    final sellValue = item.cost ~/ 2;
    return InkWell(
      onTap: () => _showShopItemDetailDialog(
        context,
        item: item,
        player: player,
        isSell: true,
        sellValue: sellValue,
        onSell: () {
          player.gold += sellValue;
          player.removeItemFromBoard(item.key);
          onSold();
        },
      ),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey[850],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[700]!),
        ),
        child: Row(
          children: [
            if (item.itemImagePath != null)
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      item.itemImagePath!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    ),
                  ),
                ),
              ),
            if (isEquipped)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Tooltip(
                message: 'Equipped',
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          Expanded(
            child: Text(
              item.name,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            '$sellValue gold',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 12),
          TextButton(
            onPressed: isEquipped
                ? null
                : () {
                    player.gold += sellValue;
                    player.removeItemFromBoard(item.key);
                    onSold();
                  },
            style: TextButton.styleFrom(
              foregroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            ),
            child: const Text('Sell'),
          ),
        ],
      ),
    ),
  );
  }
}

/// Buy tab: one row per item (image, name, stats, cost, Buy), scrollable list.
class _BuyItemTile extends StatefulWidget {
  final ItemModel item;
  final Player player;
  final VoidCallback onPurchased;

  const _BuyItemTile({
    required this.item,
    required this.player,
    required this.onPurchased,
  });

  @override
  State<_BuyItemTile> createState() => _BuyItemTileState();
}

class _BuyItemTileState extends State<_BuyItemTile> {
  void _buy() {
    if (widget.player.gold < widget.item.cost) return;
    if (!widget.player.hasInventorySpace(1)) return;
    setState(() {
      widget.player.gold -= widget.item.cost;
      final uniqueKey = '${widget.item.key}_${DateTime.now().millisecondsSinceEpoch}';
      final copy = ItemModel(
        key: uniqueKey,
        name: widget.item.name,
        damage: widget.item.damage,
        cost: widget.item.cost,
        cooldown: widget.item.cooldown,
        isConsumable: widget.item.isConsumable,
        consumableHeal: widget.item.consumableHeal,
        slotType: widget.item.slotType,
        isTwoHanded: widget.item.isTwoHanded,
        assetKey: widget.item.assetKey ?? widget.item.key,
      );
      widget.player.addToBoard(copy);
    });
    widget.onPurchased();
  }

  @override
  Widget build(BuildContext context) {
    final canAfford = widget.player.gold >= widget.item.cost;
    final hasSpace = widget.player.hasInventorySpace(1);
    final canBuy = canAfford && hasSpace;
    final isWeapon = widget.item.damage > 0;
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () => _showShopItemDetailDialog(
        context,
        item: widget.item,
        player: widget.player,
        onBuy: () {
          _buy();
          if (context.mounted) Navigator.of(context).pop();
        },
      ),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey[850],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[700]!),
        ),
        child: Row(
          children: [
            if (widget.item.itemImagePath != null)
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      widget.item.itemImagePath!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    ),
                  ),
                ),
              ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.item.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (isWeapon) ...[
                    const SizedBox(height: 2),
                    Text(
                      '${widget.item.damage} dmg • ${widget.item.cooldownDisplay}s',
                      style: TextStyle(color: Colors.grey[400], fontSize: 13),
                    ),
                  ],
                ],
              ),
            ),
            Text(
              '${widget.item.cost} gold',
              style: TextStyle(
                color: colorScheme.primary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 12),
            TextButton(
              onPressed: canBuy ? _buy : null,
              style: TextButton.styleFrom(
                foregroundColor: colorScheme.secondary,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              ),
              child: const Text('Buy'),
            ),
          ],
        ),
      ),
    );
  }
}
