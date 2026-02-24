import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'data/shop_items.dart';
import 'game/world_state.dart';
import 'models/event_node_model.dart';
import 'models/item_model.dart';
import 'models/player.dart';
import 'phases/combat_screen.dart';
import 'phases/shop_screen.dart';
import 'phases/world_phase.dart';
import 'widgets/character_view.dart';
import 'widgets/game_bottom_bar.dart';
import 'widgets/game_top_bar.dart';
import 'widgets/world_map_overlay.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const HeroBuilderApp());
}

class HeroBuilderApp extends StatelessWidget {
  const HeroBuilderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hero Builder',
      theme: appDarkTheme,
      home: const WorldScreen(),
    );
  }
}

enum AppView { main, map, character }

/// Main screen: top bar, content area (biome / map / character), bottom bar always visible.
class WorldScreen extends StatefulWidget {
  const WorldScreen({super.key});

  @override
  State<WorldScreen> createState() => _WorldScreenState();
}

class _WorldScreenState extends State<WorldScreen> {
  late final WorldState worldState;
  late final Player player;
  AppView _currentView = AppView.main;
  bool _showShop = false;
  bool _showCombat = false;
  EventNodeModel? _combatNode;
  List<ItemModel> _currentShopItems = getRandomShopItems();

  @override
  void initState() {
    super.initState();
    worldState = WorldState();
    player = Player();
  }

  @override
  Widget build(BuildContext context) {
    final showBottomBar = !_showCombat;
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GameTopBar(player: player),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _buildContent(),
              ),
            ),
            if (showBottomBar)
              GameBottomBar(
                selectedIndex: _currentView == AppView.map
                    ? 0
                    : _currentView == AppView.main
                        ? 1
                        : 2,
                onMapPressed: () => setState(() => _currentView = AppView.map),
                onCharacterPressed: () => setState(() => _currentView = AppView.character),
                onCurrentBiomePressed: () => setState(() => _currentView = AppView.main),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (_currentView) {
      case AppView.main:
        if (_showCombat && _combatNode != null) {
          return CombatScreen(
            key: const ValueKey('combat'),
            player: player,
            eventNode: _combatNode!,
            worldState: worldState,
            onVictory: () => setState(() {
              worldState.clearEncounter(_combatNode!.key);
              _showCombat = false;
              _combatNode = null;
            }),
            onDefeat: () => setState(() {
              _showCombat = false;
              _combatNode = null;
              // Stay on main view; defeat dialog offers New run / Quit
            }),
          );
        }
        if (_showShop) {
          return ShopScreen(
            key: const ValueKey('shop'),
            player: player,
            itemsForSale: _currentShopItems,
            onBack: () => setState(() => _showShop = false),
            onPurchased: () => setState(() {}),
          );
        }
        return WorldPhase(
          key: const ValueKey('main'),
          state: worldState,
          onEventTapped: (node) => setState(() {
            if (node.isCombatEncounter) {
              _combatNode = node;
              _showCombat = true;
              _showShop = false;
            } else {
              _currentShopItems = getRandomShopItems();
              _showShop = true;
              _showCombat = false;
              _combatNode = null;
            }
          }),
        );
      case AppView.map:
        return WorldMapView(
          key: const ValueKey('map'),
          state: worldState,
          biomes: worldState.biomes,
          onTravel: () => setState(() {
            _currentView = AppView.main;
            _showShop = false;
          }),
        );
      case AppView.character:
        return CharacterView(
          key: const ValueKey('character'),
          player: player,
        );
    }
  }
}
