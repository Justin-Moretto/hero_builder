import 'package:flutter/material.dart';

import '../models/item_model.dart';
import '../models/player.dart';

/// Shop screen: back button, gold, and a grid of squircle item tiles.
/// Purchased items go to player inventory.
class ShopScreen extends StatelessWidget {
  final Player player;
  final List<ItemModel> itemsForSale;
  final VoidCallback onBack;
  final VoidCallback? onPurchased;

  const ShopScreen({
    super.key,
    required this.player,
    required this.itemsForSale,
    required this.onBack,
    this.onPurchased,
  });

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
                    onPressed: onBack,
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
                    'Gold: ${player.gold}',
                    style: const TextStyle(
                      color: Colors.amber,
                      fontSize: 19,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.grey),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1,
                ),
                itemCount: itemsForSale.length,
                itemBuilder: (context, index) => _ShopItemTile(
                  item: itemsForSale[index],
                  player: player,
                  onPurchased: onPurchased ?? () {},
                ),
              ),
            ),
          ],
        ),
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
            style: const TextStyle(
              color: Colors.amber,
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
