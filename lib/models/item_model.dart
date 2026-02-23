class ItemModel {
  final String key; // unique identifier for the item instance
  final String name;
  final int damage;
  final int cost;
  /// Cooldown in seconds (e.g. 1.5).
  final double cooldown;

  const ItemModel({
    required this.key,
    required this.name,
    this.damage = 1,
    this.cost = 1,
    this.cooldown = 1.0,
  });

  /// Cooldown formatted to one decimal place.
  String get cooldownDisplay => cooldown.toStringAsFixed(1);
}
