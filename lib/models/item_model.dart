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
  }) : slotType = slotType ?? (isConsumable ? ItemSlotType.consumable : (damage > 0 ? ItemSlotType.weapon : ItemSlotType.armor));

  /// Cooldown formatted to one decimal place.
  String get cooldownDisplay => cooldown.toStringAsFixed(1);
}
