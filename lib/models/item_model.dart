enum ItemSize {
  small,   // 1 slots
  medium,  // 2 slots
  large,   // 3 slots
}

class ItemModel {
  final String key; // unique identifier for the item instance
  final String name;
  final ItemSize size;
  final int damage;
  final int cost;
  final int cooldown;

  const ItemModel({
    required this.key,
    required this.name,
    required this.size,
    this.damage = 1,
    this.cost = 1,
    this.cooldown = 5,
  });

  // Getter to convert size enum to slot count
  int get slotsToOccupy {
    switch (size) {
      case ItemSize.small:
        return 1;
      case ItemSize.medium:
        return 2;
      case ItemSize.large:
        return 3;
    }
  }
}

