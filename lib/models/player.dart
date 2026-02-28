import 'item_model.dart';

/// Which of the 5 loadout slots (W, A, W, C, C) for drag-to-equip.
enum LoadoutSlot {
  weapon0,
  weapon1,
  armor,
  consumable0,
  consumable1,
}

class Player {
  int maxHealth = 30;
  int health = 30;
  int maxEnergy = 10;
  int energy = 10;
  int gold = 80;
  static const int boardSize = 10;
  static const int stashSize = 10;
  static const int lootSize = 10;

  /// Equipment tab: index -> item key or null if empty.
  final List<String?> board = List.filled(boardSize, null, growable: false);

  /// Loot tab: extra storage (e.g. drops). Same items map.
  final List<String?> loot = List.filled(lootSize, null, growable: false);

  final Map<String, ItemModel> items = {};

  /// Equipment slots: 2 weapon (one-handed each, or 1 two-handed uses both), 1 armor, 2 consumable.
  final List<String?> weaponSlots = [null, null];
  String? armorSlot;
  final List<String?> consumableSlots = [null, null];

  bool hasInventorySpace(int itemSize) {
    final freeBoard = board.where((key) => key == null).length;
    final freeLoot = loot.where((key) => key == null).length;
    return (freeBoard + freeLoot) >= itemSize;
  }

  ItemModel? getLootItemAtSlot(int index) {
    if (index < 0 || index >= loot.length) return null;
    final key = loot[index];
    return key != null ? items[key] : null;
  }

  bool shouldRenderLootAtSlot(int index) => index >= 0 && index < loot.length && loot[index] != null;

  void addToLoot(ItemModel item) {
    for (var i = 0; i < loot.length; i++) {
      if (loot[i] == null) {
        loot[i] = item.key;
        items[item.key] = item;
        return;
      }
    }
  }

  void addToBoard(ItemModel item) {
    for (var i = 0; i < board.length; i++) {
      if (board[i] == null) {
        board[i] = item.key;
        items[item.key] = item;
        return;
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
    _unequipFromSlots(itemKey);
  }

  void removeItemFromLoot(String itemKey) {
    for (int i = 0; i < loot.length; i++) {
      if (loot[i] == itemKey) loot[i] = null;
    }
    items.remove(itemKey);
    _unequipFromSlots(itemKey);
  }

  void _unequipFromSlots(String itemKey) {
    for (int i = 0; i < weaponSlots.length; i++) {
      if (weaponSlots[i] == itemKey) weaponSlots[i] = null;
    }
    if (armorSlot == itemKey) armorSlot = null;
    for (int i = 0; i < consumableSlots.length; i++) {
      if (consumableSlots[i] == itemKey) consumableSlots[i] = null;
    }
  }

  void placeItemAtSlot(ItemModel item, int startIndex) {
    if (startIndex >= 0 && startIndex < board.length) {
      board[startIndex] = item.key;
      items[item.key] = item;
    }
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
    if (!bumpItemsToMakeSpace(targetIndex, 1, ignoreItemKey: ignoreItemKey)) return false;
    placeItemAtSlot(item, targetIndex);
    return true;
  }

  void removeItem(String itemKey) => removeItemFromBoard(itemKey);

  /// Swap two board slots (for reorder). No-op if either index out of range.
  void swapBoardSlots(int i, int j) {
    if (i == j || i < 0 || i >= board.length || j < 0 || j >= board.length) return;
    final a = board[i];
    board[i] = board[j];
    board[j] = a;
  }

  /// Swap two loot slots (for reorder). No-op if either index out of range.
  void swapLootSlots(int i, int j) {
    if (i == j || i < 0 || i >= loot.length || j < 0 || j >= loot.length) return;
    final a = loot[i];
    loot[i] = loot[j];
    loot[j] = a;
  }

  /// Move one board slot to another; other items shift (home-screen style). No-op if indices invalid.
  void moveBoardSlot(int from, int to) {
    if (from == to || from < 0 || from >= board.length || to < 0 || to >= board.length) return;
    final key = board[from];
    board[from] = null;
    if (from < to) {
      for (int i = from; i < to; i++) board[i] = board[i + 1];
    } else {
      for (int i = from; i > to; i--) board[i] = board[i - 1];
    }
    board[to] = key;
  }

  /// Move one loot slot to another; other items shift. No-op if indices invalid.
  void moveLootSlot(int from, int to) {
    if (from == to || from < 0 || from >= loot.length || to < 0 || to >= loot.length) return;
    final key = loot[from];
    loot[from] = null;
    if (from < to) {
      for (int i = from; i < to; i++) loot[i] = loot[i + 1];
    } else {
      for (int i = from; i > to; i--) loot[i] = loot[i - 1];
    }
    loot[to] = key;
  }

  /// Reorder equipment by compact list indices (only non-null items). No empty slots in UI.
  void reorderBoardCompact(int oldIndex, int newIndex) {
    final list = board.where((k) => k != null).cast<String>().toList();
    if (list.isEmpty || oldIndex == newIndex || oldIndex < 0 || oldIndex >= list.length || newIndex < 0 || newIndex >= list.length) return;
    final key = list.removeAt(oldIndex);
    list.insert(newIndex, key);
    for (int i = 0; i < board.length; i++) {
      board[i] = i < list.length ? list[i] : null;
    }
  }

  /// Reorder loot by compact list indices (only non-null items).
  void reorderLootCompact(int oldIndex, int newIndex) {
    final list = loot.where((k) => k != null).cast<String>().toList();
    if (list.isEmpty || oldIndex == newIndex || oldIndex < 0 || oldIndex >= list.length || newIndex < 0 || newIndex >= list.length) return;
    final key = list.removeAt(oldIndex);
    list.insert(newIndex, key);
    for (int i = 0; i < loot.length; i++) {
      loot[i] = i < list.length ? list[i] : null;
    }
  }

  /// Set equipment order from compact list (writes into board).
  void setBoardCompactOrder(List<String> orderedKeys) {
    for (int i = 0; i < board.length; i++) {
      board[i] = i < orderedKeys.length ? orderedKeys[i] : null;
    }
  }

  /// Set loot order from compact list (writes into loot).
  void setLootCompactOrder(List<String> orderedKeys) {
    for (int i = 0; i < loot.length; i++) {
      loot[i] = i < orderedKeys.length ? orderedKeys[i] : null;
    }
  }

  /// Equip an item into a specific loadout slot. Returns true if equipped.
  bool equipToLoadoutSlot(String itemKey, LoadoutSlot slot) {
    final item = items[itemKey];
    if (item == null) return false;
    switch (slot) {
      case LoadoutSlot.weapon0:
      case LoadoutSlot.weapon1:
        if (item.slotType != ItemSlotType.weapon) return false;
        if (item.isTwoHanded) {
          weaponSlots[0] = itemKey;
          weaponSlots[1] = itemKey;
          return true;
        }
        final idx = slot == LoadoutSlot.weapon0 ? 0 : 1;
        weaponSlots[idx] = itemKey;
        return true;
      case LoadoutSlot.armor:
        if (item.slotType != ItemSlotType.armor) return false;
        armorSlot = itemKey;
        return true;
      case LoadoutSlot.consumable0:
      case LoadoutSlot.consumable1:
        if (item.slotType != ItemSlotType.consumable) return false;
        final idx = slot == LoadoutSlot.consumable0 ? 0 : 1;
        consumableSlots[idx] = itemKey;
        return true;
    }
  }


  bool shouldHighlightSlot(int index, ItemModel? draggedItem, int? hoveredIndex, {String? ignoreItemKey}) {
    if (draggedItem == null || hoveredIndex == null) return false;
    if (index == hoveredIndex) {
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

  bool isEquipped(String itemKey) {
    return weaponSlots.contains(itemKey) || armorSlot == itemKey || consumableSlots.contains(itemKey);
  }

  /// Try to equip an item into its slot type. Returns true if equipped.
  bool setEquipped(String itemKey, bool equipped) {
    final item = items[itemKey];
    if (item == null) return false;
    if (!equipped) {
      _unequipFromSlots(itemKey);
      return true;
    }
    switch (item.slotType) {
      case ItemSlotType.weapon:
        if (item.isTwoHanded) {
          weaponSlots[0] = itemKey;
          weaponSlots[1] = itemKey;
          return true;
        }
        int empty = weaponSlots.indexOf(null);
        if (empty >= 0) {
          weaponSlots[empty] = itemKey;
          return true;
        }
        // Both slots full: if they're the same key (two-handed), replace with this one-handed
        if (weaponSlots[0] == weaponSlots[1] && weaponSlots[0] != null) {
          weaponSlots[0] = itemKey;
          weaponSlots[1] = null;
          return true;
        }
        return false;
      case ItemSlotType.armor:
        armorSlot = itemKey;
        return true;
      case ItemSlotType.consumable:
        final empty = consumableSlots.indexOf(null);
        if (empty >= 0) {
          consumableSlots[empty] = itemKey;
          return true;
        }
        return false;
    }
  }

  /// Equipped weapons (deduplicated: two-handed appears once). For combat.
  List<ItemModel> getEquippedWeapons() {
    final keys = <String>{};
    for (final k in weaponSlots) {
      if (k != null) keys.add(k);
    }
    return keys.map((k) => items[k]).whereType<ItemModel>().where((i) => i.damage > 0).toList();
  }

  /// Equipped consumables. For combat.
  List<ItemModel> getEquippedConsumables() {
    final list = <ItemModel>[];
    for (final k in consumableSlots) {
      if (k != null) {
        final item = items[k];
        if (item != null) list.add(item);
      }
    }
    return list;
  }

  /// All equipped items (weapons + armor + consumables) for UI display.
  List<ItemModel> getEquippedItems() {
    final list = <ItemModel>[];
    for (final k in weaponSlots) {
      if (k != null) {
        final item = items[k];
        if (item != null && !list.any((e) => e.key == k)) list.add(item);
      }
    }
    if (armorSlot != null) {
      final item = items[armorSlot];
      if (item != null) list.add(item);
    }
    for (final k in consumableSlots) {
      if (k != null) {
        final item = items[k];
        if (item != null) list.add(item);
      }
    }
    return list;
  }

  /// Whether another item of this slot type can be equipped (slot limit).
  bool canEquipMore(ItemSlotType slotType) {
    switch (slotType) {
      case ItemSlotType.weapon:
        if (weaponSlots.any((k) => k == null)) return true;
        if (weaponSlots[0] == weaponSlots[1] && weaponSlots[0] != null) return true;
        return false;
      case ItemSlotType.armor:
        return true;
      case ItemSlotType.consumable:
        return consumableSlots.any((k) => k == null);
    }
  }
}
