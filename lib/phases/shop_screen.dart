import 'package:flutter/material.dart';

import '../models/item_model.dart';
import '../models/player.dart';

/// Simple shop screen: back button top left, placeholder items for sale.
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
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Gold: ${player.gold}',
                    style: const TextStyle(
                      color: Colors.amber,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.grey),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    'For sale',
                    style: TextStyle(
                      color: Colors.grey[300],
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  for (final item in itemsForSale) _ShopItemRow(
                    item: item,
                    player: player,
                    onPurchased: onPurchased ?? () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShopItemRow extends StatefulWidget {
  final ItemModel item;
  final Player player;
  final VoidCallback onPurchased;

  const _ShopItemRow({
    required this.item,
    required this.player,
    required this.onPurchased,
  });

  @override
  State<_ShopItemRow> createState() => _ShopItemRowState();
}

class _ShopItemRowState extends State<_ShopItemRow> {
  void _buy() {
    if (widget.player.gold < widget.item.cost) return;
    if (!widget.player.hasInventorySpace(widget.item.slotsToOccupy)) return;
    setState(() {
      widget.player.gold -= widget.item.cost;
      final uniqueKey = '${widget.item.key}_${DateTime.now().millisecondsSinceEpoch}';
      final copy = ItemModel(
        key: uniqueKey,
        name: widget.item.name,
        size: widget.item.size,
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
    final hasSpace = widget.player.hasInventorySpace(widget.item.slotsToOccupy);
    final canBuy = canAfford && hasSpace;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.grey[850],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.item.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.item.cost} gold  •  ${widget.item.slotsToOccupy} slot(s)',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: canBuy ? _buy : null,
              child: const Text('Buy'),
            ),
          ],
        ),
      ),
    );
  }
}
