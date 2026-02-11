import 'item_model.dart';

class Player {
  int maxHealth = 30;
  int health = 30;
  int maxEnergy = 10;
  int energy = 10;
  int gold = 5;
  static const int boardSize = 10;
  static const int stashSize = 10;

  /// Board: index -> item key or null if empty. Will be redone with new inventory.
  final List<String?> board = List.filled(boardSize, null, growable: false);

  final Map<String, ItemModel> items = {};

  bool hasInventorySpace(int itemSize) {
    int free = board.where((key) => key == null).length;
    return free >= itemSize;
  }

  void addToBoard(ItemModel item) {
    int added = 0;
    for (var i = 0; i < board.length && added < item.slotsToOccupy; i++) {
      if (board[i] == null) {
        board[i] = item.key;
        items[item.key] = item;
        added++;
      }
    }
  }

  ItemModel? getItemAtSlot(int index) {
    if (index < 0 || index >= board.length) return null;
    final key = board[index];
    return key != null ? items[key] : null;
  }

  ItemModel? getItemByKey(String key) => items[key];

  void removeItemFromBoard(String itemKey) {
    for (int i = 0; i < board.length; i++) {
      if (board[i] == itemKey) board[i] = null;
    }
    items.remove(itemKey);
  }

  void placeItemAtSlot(ItemModel item, int startIndex) {
    for (int i = 0; i < item.slotsToOccupy && startIndex + i < board.length; i++) {
      board[startIndex + i] = item.key;
    }
    items[item.key] = item;
  }

  void clearSlots(int startIndex, int count) {
    for (int i = 0; i < count && startIndex + i < board.length; i++) {
      final key = board[startIndex + i];
      if (key != null) items.remove(key);
      board[startIndex + i] = null;
    }
  }

  bool hasEnoughSpace(int itemSize) => hasInventorySpace(itemSize);

  bool _isEmpty(int index) => index >= 0 && index < board.length && board[index] == null;

  int? findNearestEmptySpace(int startIndex, {int? preferredDirection}) {
    if (_isEmpty(startIndex)) return startIndex;
    List<int> adjacentIndices = [];
    if (startIndex - 1 >= 0) adjacentIndices.add(startIndex - 1);
    if (startIndex + 1 < board.length) adjacentIndices.add(startIndex + 1);
    if (preferredDirection != null) {
      adjacentIndices.sort((a, b) {
        int aDir = a > startIndex ? 1 : -1;
        int bDir = b > startIndex ? 1 : -1;
        if (aDir == preferredDirection && bDir != preferredDirection) return -1;
        if (aDir != preferredDirection && bDir == preferredDirection) return 1;
        return 0;
      });
    }
    for (final i in adjacentIndices) {
      if (_isEmpty(i)) return i;
    }
    for (int distance = 2; distance < board.length; distance++) {
      if (preferredDirection != null) {
        if (preferredDirection > 0 && startIndex + distance < board.length && _isEmpty(startIndex + distance)) {
          return startIndex + distance;
        }
        if (preferredDirection < 0 && startIndex - distance >= 0 && _isEmpty(startIndex - distance)) {
          return startIndex - distance;
        }
        if (preferredDirection > 0 && startIndex - distance >= 0 && _isEmpty(startIndex - distance)) {
          return startIndex - distance;
        }
        if (preferredDirection < 0 && startIndex + distance < board.length && _isEmpty(startIndex + distance)) {
          return startIndex + distance;
        }
      } else {
        if (startIndex - distance >= 0 && _isEmpty(startIndex - distance)) return startIndex - distance;
        if (startIndex + distance < board.length && _isEmpty(startIndex + distance)) return startIndex + distance;
      }
    }
    return null;
  }

  bool bumpItemsToMakeSpace(int targetIndex, int itemSize, {String? ignoreItemKey}) {
    List<ItemModel> itemsToBump = [];
    List<int> bumpIndices = [];
    for (int i = 0; i < itemSize; i++) {
      final idx = targetIndex + i;
      if (idx < board.length && board[idx] != null && board[idx] != ignoreItemKey) {
        final item = getItemAtSlot(idx);
        if (item != null) {
          itemsToBump.add(item);
          bumpIndices.add(idx);
        }
      }
    }
    if (itemsToBump.isEmpty) return true;
    for (int i = 0; i < itemsToBump.length; i++) {
      int? newSpace = findNearestEmptySpace(bumpIndices[i]);
      if (newSpace == null) return false;
      placeItemAtSlot(itemsToBump[i], newSpace);
      clearSlots(bumpIndices[i], 1);
    }
    return true;
  }

  bool placeItem(ItemModel item, int targetIndex, {String? ignoreItemKey}) {
    if (!bumpItemsToMakeSpace(targetIndex, item.slotsToOccupy, ignoreItemKey: ignoreItemKey)) return false;
    placeItemAtSlot(item, targetIndex);
    return true;
  }

  void removeItem(String itemKey) => removeItemFromBoard(itemKey);

  bool shouldHighlightSlot(int index, ItemModel? draggedItem, int? hoveredIndex, {String? ignoreItemKey}) {
    if (draggedItem == null || hoveredIndex == null) return false;
    if (index >= hoveredIndex && index < hoveredIndex + draggedItem.slotsToOccupy) {
      final key = board[index];
      if (key != null && key != ignoreItemKey) return true;
    }
    return false;
  }

  bool shouldRenderItemAtSlot(int index) {
    final key = board[index];
    if (key == null) return false;
    for (int i = 0; i < board.length; i++) {
      if (board[i] == key) return i == index;
    }
    return false;
  }

  int? getFirstSlotIndexForItem(String itemKey) {
    for (int i = 0; i < board.length; i++) {
      if (board[i] == itemKey) return i;
    }
    return null;
  }
}
