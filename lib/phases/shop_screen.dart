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
                  ? GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 1,
                      ),
                      itemCount: widget.itemsForSale.length,
                      itemBuilder: (context, index) => _ShopItemTile(
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[700]!),
      ),
      child: Row(
        children: [
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
    );
  }
}

class _ShopItemTile extends StatefulWidget {
  final ItemModel item;
  final Player player;
  final VoidCallback onPurchased;

  const _ShopItemTile({
    required this.item,
    required this.player,
    required this.onPurchased,
  });

  @override
  State<_ShopItemTile> createState() => _ShopItemTileState();
}

class _ShopItemTileState extends State<_ShopItemTile> {
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

    return _SquircleCard(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            widget.item.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          if (isWeapon)
            Text(
              '${widget.item.damage} dmg • ${widget.item.cooldownDisplay}s',
              style: TextStyle(color: Colors.grey[400], fontSize: 14),
            ),
          const SizedBox(height: 4),
          Text(
            '${widget.item.cost} gold',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: canBuy ? _buy : null,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              minimumSize: Size.zero,
            ),
            child: const Text('Buy'),
          ),
        ],
      ),
    );
  }
}

/// Rounded square (squircle-style) container for grid items.
class _SquircleCard extends StatelessWidget {
  final Widget child;

  const _SquircleCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[700]!, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: child,
        ),
      ),
    );
  }
}
