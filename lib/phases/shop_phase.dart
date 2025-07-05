// Placeholder for shop phase UI and logic
// TODO: Implement user interface for buying and upgrading items

import 'package:flutter/material.dart';
import '../models/item.dart';
import '../models/player.dart';
import 'dart:async';

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
  String? _message;
  Timer? _messageTimer;

  @override
  void dispose() {
    _messageTimer?.cancel();
    super.dispose();
  }

  void _showMessage(String message) {
    setState(() {
      _message = message;
    });
    _messageTimer?.cancel();
    _messageTimer = Timer(const Duration(seconds: 2), () {
      setState(() {
        _message = null;
      });
    });
  }

  // Find the nearest empty space starting from a given index, preferring a specific direction
  int? _findNearestEmptySpace(int startIndex, {int? preferredDirection}) {
    if (widget.player.board[startIndex] == null) {
      return startIndex; // Already empty
    }
    
    // Check adjacent spaces first
    List<int> adjacentIndices = [];
    if (startIndex - 1 >= 0) adjacentIndices.add(startIndex - 1);
    if (startIndex + 1 < widget.player.board.length) adjacentIndices.add(startIndex + 1);
    
    // If we have a preferred direction, prioritize that direction
    if (preferredDirection != null) {
      adjacentIndices.sort((a, b) {
        int aDirection = a > startIndex ? 1 : -1;
        int bDirection = b > startIndex ? 1 : -1;
        if (aDirection == preferredDirection && bDirection != preferredDirection) return -1;
        if (aDirection != preferredDirection && bDirection == preferredDirection) return 1;
        return 0;
      });
    }
    
    // Check adjacent spaces first
    for (int index in adjacentIndices) {
      if (widget.player.board[index] == null) {
        return index;
      }
    }
    
    // If no adjacent space, expand outward
    List<int> indicesToCheck = [];
    for (int distance = 2; distance < widget.player.board.length; distance++) {
      // Check in preferred direction first, then opposite
      if (preferredDirection != null) {
        if (preferredDirection > 0 && startIndex + distance < widget.player.board.length) {
          indicesToCheck.add(startIndex + distance);
        }
        if (preferredDirection < 0 && startIndex - distance >= 0) {
          indicesToCheck.add(startIndex - distance);
        }
        if (preferredDirection > 0 && startIndex - distance >= 0) {
          indicesToCheck.add(startIndex - distance);
        }
        if (preferredDirection < 0 && startIndex + distance < widget.player.board.length) {
          indicesToCheck.add(startIndex + distance);
        }
      } else {
        // No preferred direction, check both sides
        if (startIndex - distance >= 0) {
          indicesToCheck.add(startIndex - distance);
        }
        if (startIndex + distance < widget.player.board.length) {
          indicesToCheck.add(startIndex + distance);
        }
      }
    }
    
    // Check each index for empty space
    for (int index in indicesToCheck) {
      if (widget.player.board[index] == null) {
        return index;
      }
    }
    
    return null; // No empty space found
  }

  // Move tiles to make space for a new item at targetIndex
  bool _makeSpaceForItem(int targetIndex, {int? preferredDirection}) {
    if (widget.player.board[targetIndex] == null) {
      return true; // Already empty
    }
    
    // Find nearest empty space with preferred direction
    int? emptySpace = _findNearestEmptySpace(targetIndex, preferredDirection: preferredDirection);
    if (emptySpace == null) {
      return false; // No space available
    }
    
    // Calculate the direction to move tiles
    int direction = emptySpace > targetIndex ? 1 : -1;
    
    // Start from the empty space and work backwards to create a chain of movements
    int currentIndex = emptySpace;
    
    // Move tiles from the target position toward the empty space
    while (currentIndex != targetIndex) {
      int previousIndex = currentIndex - direction;
      if (previousIndex >= 0 && previousIndex < widget.player.board.length) {
        widget.player.board[currentIndex] = widget.player.board[previousIndex];
        widget.player.board[previousIndex] = null;
        currentIndex = previousIndex;
      } else {
        break;
      }
    }
    
    return true;
  }

  // Check if there's any space available on the board
  bool _hasSpaceOnBoard() {
    return widget.player.board.any((item) => item == null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Stack(
        children: [
          SafeArea(
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
          // Message overlay
          if (_message != null)
            Positioned(
              top: 50,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.red[800],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Text(
                    _message!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
        ],
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
          // Check if it's a new item from shop
          bool isNewItem = !widget.player.board.contains(data);
          
          if (isNewItem) {
            // Check if there's any space on the board
            if (!_hasSpaceOnBoard()) {
              _showMessage("Not enough space on the board for this item");
              return; // Don't make purchase, item stays in shop
            }
            
            // For shop items, default to left direction (-1)
            if (_makeSpaceForItem(index, preferredDirection: -1)) {
              widget.player.gold -= 1; // Cost 1 gold
              widget.player.board[index] = data;
            } else {
              _showMessage("Not enough space on the board for this item");
            }
          } else {
            // It's a move operation from board to board
            int originalIndex = widget.player.board.indexOf(data);
            if (originalIndex != -1 && originalIndex != index) {
              // Calculate the direction the item came from
              int direction = index > originalIndex ? 1 : -1;
              
              // Remove item from original position
              widget.player.board[originalIndex] = null;
              
              // Try to make space for the moved item, preferring the direction it came from
              if (_makeSpaceForItem(index, preferredDirection: direction)) {
                widget.player.board[index] = data;
              } else {
                // If we can't make space, put the item back where it was
                widget.player.board[originalIndex] = data;
                _showMessage("Not enough space on the board for this item");
              }
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
