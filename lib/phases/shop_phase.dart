// Placeholder for shop phase UI and logic
// TODO: Implement user interface for buying and upgrading items

import 'package:flutter/material.dart';
import '../models/item_model.dart';
import '../models/player.dart';
import 'dart:async';

class ShopPhase extends StatefulWidget {
  final Player player;
  final List<ItemModel> shopItems;
  final Function(ItemModel) onBuyItem;
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
  final GlobalKey _boardKey = GlobalKey();
  
  // Drag and drop state
  ItemModel? _draggedItem;
  int? _draggedItemIndex;
  Offset? _dragOffset;
  int? _hoveredSlotIndex;
  
  // Message display
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

  // Handle dropping an item on the board
  void _handleDropOnBoard(int targetIndex, ItemModel item, bool isFromShop) {
    setState(() {
      // If this is a board-to-board move, ignore the item being moved
      String? ignoreItemKey = (_draggedItemIndex != null && item == _draggedItem) ? item.key : null;
      
      if (!widget.player.placeItem(item, targetIndex, ignoreItemKey: ignoreItemKey)) {
        _showMessage("Not enough space on the board for this item");
        return;
      }
      
      // Handle cost if from shop
      if (isFromShop) {
        widget.player.gold -= item.cost;
      }
      
      // Clear hover state
      _hoveredSlotIndex = null;
    });
  }

  // Handle starting drag from board
  void _startDragFromBoard(ItemModel item, int index, Offset localPosition) {
    setState(() {
      _draggedItem = item;
      _draggedItemIndex = index;
      _dragOffset = Offset(localPosition.dx, localPosition.dy);
    });
  }

  // Handle ending drag
  void _endDrag() {
    setState(() {
      _draggedItem = null;
      _draggedItemIndex = null;
      _dragOffset = null;
      _hoveredSlotIndex = null;
    });
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
                  
                  // Shop area
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.transparent, width: 3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DragTarget<ItemModel>(
                      onWillAccept: (data) => data != null,
                      onAccept: (data) {
                        setState(() {
                          widget.player.gold += data.cost; // Refund cost
                          // Remove item from board
                          widget.player.removeItem(data.key);
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
                                    'DROP HERE TO SELL',
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
                    child: GestureDetector(
                      onPanUpdate: (details) {
                        if (_draggedItem != null && _dragOffset != null) {
                          // Calculate which slot the dragged item's left edge is hovering over
                          final RenderBox renderBox = _boardKey.currentContext!.findRenderObject() as RenderBox;
                          final localPosition = renderBox.globalToLocal(details.globalPosition);
                          final itemLeftEdge = localPosition.dx - _dragOffset!.dx;
                          final slotWidth = renderBox.size.width / widget.player.board.length;
                          final hoveredSlot = (itemLeftEdge / slotWidth).floor();
                          
                          if (hoveredSlot != _hoveredSlotIndex) {
                            setState(() {
                              _hoveredSlotIndex = hoveredSlot;
                            });
                          }
                        }
                      },
                      child: Container(
                        key: _boardKey,
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
                                children: List.generate(10, (index) => _buildBoardSlot(index)),
                              ),
                            ),
                          ],
                        ),
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

  Widget _buildShopItem(ItemModel item) {
    return Container(
      margin: EdgeInsets.zero,
      child: GestureDetector(
        onPanStart: (details) {
          setState(() {
            _draggedItem = item;
            _dragOffset = details.localPosition;
          });
        },
        onPanEnd: (details) {
          _endDrag();
        },
        child: Draggable<ItemModel>(
          data: item,
          feedback: Material(
            color: Colors.transparent,
            child: _buildItemWidget(item, Colors.blue[600]!),
          ),
          childWhenDragging: _buildItemWidget(item, Colors.grey[600]!),
          child: _buildItemWidget(item, Colors.blue[400]!),
        ),
      ),
    );
  }

  Widget _buildBoardSlot(int index) {
    final item = widget.player.getItemAtSlot(index);
    
    // Check if this slot should render the item (to avoid duplicates for multi-slot items)
    bool shouldShowItem = widget.player.shouldRenderItemAtSlot(index);
    
    // Check if this slot should be highlighted/raised during drag
    String? ignoreItemKey = (_draggedItemIndex != null && _draggedItem != null) ? _draggedItem!.key : null;
    bool shouldHighlight = widget.player.shouldHighlightSlot(index, _draggedItem, _hoveredSlotIndex, ignoreItemKey: ignoreItemKey);
    
    return DragTarget<ItemModel>(
      onWillAccept: (data) => data != null,
      onAccept: (data) {
        // If this is the same item being dragged from the board
        if (_draggedItemIndex != null && data == _draggedItem) {
          // Check if we're dropping to the same position or an adjacent empty space
          if (index == _draggedItemIndex || 
              (index >= _draggedItemIndex! - 1 && index <= _draggedItemIndex! + data.slotsToOccupy)) {
            // Just place it back in the original position without calling _handleDropOnBoard
            widget.player.placeItem(data, _draggedItemIndex!, ignoreItemKey: data.key);
            return;
          }
          
          // Remove the item from its original position for actual moves
          widget.player.removeItem(data.key);
        }
        
        _handleDropOnBoard(index, data, _draggedItemIndex == null);
      },
      onMove: (details) {
        // Drag tracking is now handled at the board level
      },
      builder: (context, candidateData, rejectedData) {
        final ItemModel? slotItem = item;
        final bool showItem = shouldShowItem && slotItem != null;
        return Container(
          width: showItem && slotItem.slotsToOccupy > 1 ? (50 * slotItem.slotsToOccupy).toDouble() : 50,
          height: 70,
          margin: EdgeInsets.zero,
          transform: shouldHighlight ? Matrix4.translationValues(0, -5, 0) : null,
          decoration: BoxDecoration(
            color: showItem
                ? Colors.green[400]
                : candidateData.isNotEmpty
                    ? Colors.green[300]
                    : Colors.green[200],
            border: Border.all(
              color: Colors.white,
              width: 0.2,
            ),
          ),
          child: showItem
              ? GestureDetector(
                  onPanStart: (details) {
                    _startDragFromBoard(slotItem, index, details.localPosition);
                  },
                  onPanEnd: (details) {
                    _endDrag();
                  },
                  child: Draggable<ItemModel>(
                    data: slotItem,
                    feedback: Material(
                      color: Colors.transparent,
                      child: _buildItemWidget(slotItem, Colors.green.shade600),
                    ),
                    childWhenDragging: _buildItemWidget(slotItem, Colors.grey.shade600),
                    child: _buildItemWidget(slotItem, Colors.green.shade400),
                  ),
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

  Widget _buildItemWidget(ItemModel item, Color backgroundColor) {
    return Container(
      width: (50 * item.slotsToOccupy).toDouble(),
      height: 70,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: Colors.white, width: 1),
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
