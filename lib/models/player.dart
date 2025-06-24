import 'item.dart';

class Player {
  int maxHealth = 30;
  int health = 30;
  int gold = 5;
  static const int boardSize = 10;
  static const int stashSize = 10;

  final List<Item?> board = List<Item?>.filled(boardSize, null, growable: false);
  final List<Item?> stash = List<Item?>.filled(stashSize, null, growable: false);

  bool hasInventorySpace(int itemSize) {
    int freeSlots = board.where((item) => item == null).length;
    return freeSlots >= itemSize;
  }

  void addToBoard(Item item) {
    int added = 0;
    for (var i = 0; i < board.length && added < item.size; i++) {
      if (board[i] == null) {
        board[i] = item;
        added++;
      }
    }
  }

  // TODO: Add methods for moving items to stash, upgrading, etc.
}
