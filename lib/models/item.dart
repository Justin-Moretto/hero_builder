class Item {
  final String name;
  final int size; // number of tiles this item occupies
  final int damage;
  final int cost;

  const Item({
    required this.name,
    required this.size,
    required this.damage,
    required this.cost,
  });
}

class DamageItem extends Item {
  const DamageItem.small(String name, {required int damage})
      : super(name: name, size: 1, damage: damage, cost: damage * 2);
}
