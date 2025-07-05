// Placeholder for shop phase UI and logic
// TODO: Implement user interface for buying and upgrading items

import 'package:flutter/material.dart';
import '../models/item.dart';
import '../models/player.dart';

class ShopPhase extends StatefulWidget {
  final Player player;
  final List<Item> shopItems;
  final Function(Item) onBuyItem;
  final VoidCallback onStartCombat;

  const ShopPhase({
    super.key,
    required this.player,
    required this.shopItems,
    required this.onBuyItem,
    required this.onStartCombat,
  });

  @override
  State<ShopPhase> createState() => _ShopPhaseState();
}

class _ShopPhaseState extends State<ShopPhase> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Column(
            children: [
              // Gold and health display
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Gold: ${widget.player.gold}',
                    style: const TextStyle(
                      color: Colors.yellow,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Health: ${widget.player.health}',
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              
              // Shop area - fixed size container
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.transparent, width: 3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DragTarget<Item>(
                  onWillAccept: (data) => data != null,
                  onAccept: (data) {
                    setState(() {
                      widget.player.gold += 1; // Refund 1 gold
                      // Remove item from board
                      for (int i = 0; i < widget.player.board.length; i++) {
                        if (widget.player.board[i] == data) {
                          widget.player.board[i] = null;
                          break;
                        }
                      }
                    });
                  },
                  builder: (context, candidateData, rejectedData) {
                    return Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.blue[800],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: candidateData.isNotEmpty ? Colors.yellow : Colors.transparent,
                          width: 3,
                        ),
                      ),
                      child: Column(
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 4.0, bottom: 4.0),
                            child: Text(
                              'SHOP',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: widget.shopItems.map((item) => _buildShopItem(item)).toList(),
                          ),
                          if (candidateData.isNotEmpty)
                            const Padding(
                              padding: EdgeInsets.only(top: 4.0),
                              child: Text(
                                'DROP HERE TO SELL FOR +1 GOLD',
                                style: TextStyle(
                                  color: Colors.yellow,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              
              const SizedBox(height: 6),
              
              // Player board
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green[800],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 4.0, bottom: 4.0),
                        child: Text(
                          'YOUR BOARD',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(10, (index) => _buildBoardTile(index)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 6),
              
              // Start combat button
              ElevatedButton(
                onPressed: widget.onStartCombat,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                ),
                child: const Text(
                  'START COMBAT',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShopItem(Item item) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 1),
      child: Draggable<Item>(
        data: item,
        feedback: _buildItemWidget(item, Colors.blue[600]!),
        childWhenDragging: _buildItemWidget(item, Colors.grey[600]!),
        child: _buildItemWidget(item, Colors.blue[400]!),
      ),
    );
  }

  Widget _buildBoardTile(int index) {
    final item = widget.player.board[index];
    
    return DragTarget<Item>(
      onWillAccept: (data) => data != null,
      onAccept: (data) {
        setState(() {
          // If it's a new item from shop, cost 1 gold
          if (!widget.player.board.contains(data)) {
            widget.player.gold -= 1;
            widget.player.board[index] = data;
          } else {
            // It's a move operation - find the original position and move the item
            int originalIndex = widget.player.board.indexOf(data);
            if (originalIndex != -1) {
              // Remove item from original position
              widget.player.board[originalIndex] = null;
              // Place item in new position
              widget.player.board[index] = data;
            }
          }
        });
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
          width: 50,
          height: 70,
          margin: const EdgeInsets.symmetric(horizontal: 1),
          decoration: BoxDecoration(
            color: item != null 
                ? Colors.green[400] 
                : candidateData.isNotEmpty 
                    ? Colors.green[300] 
                    : Colors.green[200],
            border: Border.all(color: Colors.white, width: 2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: item != null 
              ? Draggable<Item>(
                  data: item,
                  feedback: _buildItemWidget(item, Colors.green[600]!),
                  childWhenDragging: _buildItemWidget(item, Colors.grey[600]!),
                  child: _buildItemWidget(item, Colors.green[400]!),
                )
              : Center(
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
        );
      },
    );
  }

  Widget _buildItemWidget(Item item, Color backgroundColor) {
    return Container(
      width: 50,
      height: 70,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: Colors.white, width: 2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            item.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            '${item.damage}',
            style: const TextStyle(
              color: Colors.red,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
