/// Slot type for equipment: determines which slots an item can occupy.
enum ItemSlotType {
  weapon,
  armor,
  consumable,
}

class ItemModel {
  final String key; // unique identifier for the item instance
  final String name;
  final int damage;
  final int cost;
  /// Cooldown in seconds (e.g. 1.5). Zero for consumables (tap-to-use).
  final double cooldown;
  /// If true, appears in combat when equipped; tap consumes and applies effect (e.g. heal).
  final bool isConsumable;
  /// When [isConsumable], HP restored on use. 0 means no heal.
  final int consumableHeal;
  /// Which equipment slot type this item uses (weapon / armor / consumable).
  final ItemSlotType slotType;
  /// If true (weapons only), this item uses both weapon slots (two-handed). Otherwise one-handed.
  final bool isTwoHanded;
  /// Template key for asset lookup (e.g. "dagger"). Set when buying so instance key "dagger_123" still maps to dagger.png.
  final String? assetKey;

  const ItemModel({
    required this.key,
    required this.name,
    this.damage = 1,
    this.cost = 1,
    this.cooldown = 1.0,
    this.isConsumable = false,
    this.consumableHeal = 0,
    ItemSlotType? slotType,
    this.isTwoHanded = false,
    this.assetKey,
  }) : slotType = slotType ?? (isConsumable ? ItemSlotType.consumable : (damage > 0 ? ItemSlotType.weapon : ItemSlotType.armor));

  /// Cooldown formatted to one decimal place.
  String get cooldownDisplay => cooldown.toStringAsFixed(1);

  /// Path to item image under assets/images/items/, or null if no asset key. Use with Image.asset and errorBuilder fallback.
  static const String itemImagesPrefix = 'assets/images/items/';

  String? get itemImagePath {
    final k = assetKey ?? key;
    if (k.isEmpty) return null;
    return '$itemImagesPrefix$k.png';
  }
}
