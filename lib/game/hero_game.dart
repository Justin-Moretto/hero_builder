import 'package:flame/game.dart';
import '../models/player.dart';
import '../models/item.dart';

enum GamePhase { shop, combat }

class HeroGame extends FlameGame {
  GamePhase phase = GamePhase.shop;
  late Player player;
  List<Item> shopItems = [];

  @override
  Future<void> onLoad() async {
    player = Player();
    _generateShopItems();
  }

  void _generateShopItems() {
    // TODO: Replace with random generation logic
    shopItems = [
      DamageItem.small('Dagger', damage: 2),
      DamageItem.small('Short Sword', damage: 3),
      DamageItem.small('Wand', damage: 1),
    ];
  }

  void buyItem(Item item) {
    if (player.gold >= item.cost && player.hasInventorySpace(item.size)) {
      player.gold -= item.cost;
      player.addToBoard(item);
    }
  }

  void startCombat() {
    phase = GamePhase.combat;
    // TODO: Implement combat resolution
  }

  void endCombat() {
    phase = GamePhase.shop;
    _generateShopItems();
    // TODO: Reward gold based on outcome
  }
}
