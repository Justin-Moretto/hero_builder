import 'dart:math';

import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'game/time_of_day.dart' as game_clock;
import 'game/world_state.dart';
import 'models/biome_model.dart';
import 'models/event_node_model.dart';
import 'models/player.dart';
import 'phases/combat_screen.dart';
import 'phases/main_menu_screen.dart';
import 'phases/shop_screen.dart';
import 'phases/traveling_screen.dart';
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
      home: MainMenuScreen(
        onStartGame: (context) {
          final worldState = WorldState();
          final player = Player();
          worldState.initializeRun();
          worldState.restockAllShops();
          Navigator.of(context).pushReplacement(
            MaterialPageRoute<void>(
              builder: (_) => WorldScreen(
                worldState: worldState,
                player: player,
              ),
            ),
          );
        },
      ),
    );
  }
}

enum AppView { main, map, character }

/// Main screen: top bar, content area (biome / map / character), bottom bar always visible.
/// [worldState] and [player] are created at Start Game and passed from the main menu.
class WorldScreen extends StatefulWidget {
  const WorldScreen({
    super.key,
    required this.worldState,
    required this.player,
  });

  final WorldState worldState;
  final Player player;

  @override
  State<WorldScreen> createState() => _WorldScreenState();
}

class _WorldScreenState extends State<WorldScreen> {
  late final WorldState worldState;
  late final Player player;
  final Random _random = Random();
  AppView _currentView = AppView.main;
  bool _showShop = false;
  bool _showCombat = false;
  EventNodeModel? _combatNode;
  String? _currentShopBiomeKey;
  String? _currentShopNodeKey;

  /// Travel flow: user chose to travel to a biome; we show traveling screen then maybe encounter.
  bool _isTraveling = false;
  String? _travelDestinationBiomeKey;
  String? _travelDestinationName;
  /// After traveling screen finishes, we show a popup; this holds the result until user taps OK.
  TravelEncounterResult? _pendingTravelResult;

  int _day = 1;
  game_clock.TimeOfDay _timeOfDay = game_clock.TimeOfDay.morn;

  @override
  void initState() {
    super.initState();
    worldState = widget.worldState;
    player = widget.player;
  }

  @override
  Widget build(BuildContext context) {
    final showBottomBar = !_showCombat && !_isTraveling;
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GameTopBar(
              player: player,
              day: _day,
              timeOfDay: _timeOfDay,
              currentBiomeName: worldState.getCurrentBiome()?.name,
            ),
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

  void _startTravelToBiome(BiomeModel biome) {
    setState(() {
      _travelDestinationBiomeKey = biome.key;
      _travelDestinationName = biome.name;
      _isTraveling = true;
      _currentView = AppView.main;
      _showShop = false;
    });
  }

  void _advanceHour() {
    if (_timeOfDay.isNight) {
      _timeOfDay = game_clock.TimeOfDay.morn;
      _day++;
      worldState.restockAllShops();
    } else {
      _timeOfDay = _timeOfDay.next;
    }
  }

  void _showInnRestDialog() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Inn'),
        content: const Text(
          'Would you like to rest? Restores your health, costs 6 gold, and advances the hour.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (player.gold < 6) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(
                    content: Text('Not enough gold. You need 6 gold to rest.'),
                  ),
                );
                return;
              }
              Navigator.of(ctx).pop();
              setState(() {
                player.gold -= 6;
                player.health = player.maxHealth;
                _advanceHour();
              });
            },
            child: const Text('Rest (6 gold)'),
          ),
        ],
      ),
    );
  }

  void _onTravelComplete(TravelEncounterResult result) {
    setState(() {
      _advanceHour();
      _pendingTravelResult = result;
      // Apply arrival for non-combat so we're already in the new biome; keep
      // _isTraveling true so the popup shows over the travel screen.
      switch (result.type) {
        case TravelEncounter.none:
          if (_travelDestinationBiomeKey != null) {
            worldState.travelToBiome(_travelDestinationBiomeKey!);
            _travelDestinationBiomeKey = null;
            _travelDestinationName = null;
          }
          break;
        case TravelEncounter.foundGold:
          if (_travelDestinationBiomeKey != null) {
            player.gold += result.goldAmount;
            worldState.travelToBiome(_travelDestinationBiomeKey!);
            _travelDestinationBiomeKey = null;
            _travelDestinationName = null;
          }
          break;
        case TravelEncounter.slime:
          // Don't travel yet; we'll arrive after combat victory.
          break;
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _showTravelResultDialog();
    });
  }

  void _showTravelResultDialog() {
    final result = _pendingTravelResult;
    final destKey = _travelDestinationBiomeKey;
    final destName = _travelDestinationName ?? 'your destination';
    if (result == null || destKey == null) return;

    String title;
    String message;
    switch (result.type) {
      case TravelEncounter.none:
        title = 'Arrival';
        message = 'The journey was uneventful. You have arrived at $destName.';
        break;
      case TravelEncounter.slime:
        title = 'Encounter!';
        message = 'A slime blocks your path! Defeat it to continue to $destName.';
        break;
      case TravelEncounter.foundGold:
        title = 'Found Gold';
        message = 'You found ${result.goldAmount} gold on the road! You have arrived at $destName.';
        break;
    }

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _applyTravelResult(result, destKey);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _applyTravelResult(TravelEncounterResult result, String destKey) {
    setState(() {
      _pendingTravelResult = null;
      _isTraveling = false;
      switch (result.type) {
        case TravelEncounter.none:
        case TravelEncounter.foundGold:
          // Already applied in _onTravelComplete.
          break;
        case TravelEncounter.slime:
          _combatNode = worldState.eventNodes
              .firstWhere((n) => n.key == 'encounter_slime');
          _showCombat = true;
          _showShop = false;
          break;
      }
    });
  }

  void _onCombatVictory() {
    setState(() {
      worldState.clearEncounter(_combatNode!.key);
      _showCombat = false;
      final destKey = _travelDestinationBiomeKey;
      _combatNode = null;
      if (destKey != null) {
        worldState.travelToBiome(destKey);
        _travelDestinationBiomeKey = null;
        _travelDestinationName = null;
      }
    });
  }

  Widget _buildContent() {
    switch (_currentView) {
      case AppView.main:
        if (_isTraveling &&
            _travelDestinationName != null &&
            _travelDestinationBiomeKey != null) {
          return TravelingScreen(
            key: const ValueKey('traveling'),
            destinationName: _travelDestinationName!,
            random: _random,
            timeOfDay: _timeOfDay,
            onComplete: _onTravelComplete,
          );
        }
        if (_showCombat && _combatNode != null) {
          return CombatScreen(
            key: const ValueKey('combat'),
            player: player,
            eventNode: _combatNode!,
            worldState: worldState,
            onVictory: _onCombatVictory,
            onDefeat: () => setState(() {
              _showCombat = false;
              _combatNode = null;
              _travelDestinationBiomeKey = null;
              _travelDestinationName = null;
            }),
          );
        }
        if (_showShop &&
            _currentShopBiomeKey != null &&
            _currentShopNodeKey != null) {
          final shopStock = worldState.getShopStock(
            _currentShopBiomeKey!,
            _currentShopNodeKey!,
          );
          return ShopScreen(
            key: const ValueKey('shop'),
            player: player,
            itemsForSale: shopStock,
            onBack: () => setState(() => _showShop = false),
            onPurchasedItemAt: (index) {
              setState(() {
                final list = worldState.getShopStock(
                  _currentShopBiomeKey!,
                  _currentShopNodeKey!,
                );
                if (index >= 0 && index < list.length) list.removeAt(index);
              });
            },
          );
        }
        return WorldPhase(
          key: const ValueKey('main'),
          state: worldState,
          onEventTapped: (node) {
            if (node.key == 'inn') {
              _showInnRestDialog();
              return;
            }
            setState(() {
              if (node.isCombatEncounter) {
                _combatNode = node;
                _showCombat = true;
                _showShop = false;
              } else {
                _currentShopBiomeKey = worldState.currentBiomeKey;
                _currentShopNodeKey = node.key;
                _showShop = true;
                _showCombat = false;
                _combatNode = null;
              }
            });
          },
        );
      case AppView.map:
        return WorldMapView(
          key: const ValueKey('map'),
          state: worldState,
          biomes: worldState.biomes,
          onTravelToBiome: _startTravelToBiome,
        );
      case AppView.character:
        return CharacterView(
          key: const ValueKey('character'),
          player: player,
        );
    }
  }
}
