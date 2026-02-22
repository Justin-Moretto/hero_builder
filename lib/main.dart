import 'package:flutter/material.dart';

import 'game/world_state.dart';
import 'models/player.dart';
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
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
      ),
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

  @override
  void initState() {
    super.initState();
    worldState = WorldState();
    player = Player();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GameTopBar(player: player),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _buildContent(),
            ),
          ),
          GameBottomBar(
            onMapPressed: () => setState(() => _currentView = AppView.map),
            onCharacterPressed: () => setState(() => _currentView = AppView.character),
            onCurrentBiomePressed: () => setState(() => _currentView = AppView.main),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    switch (_currentView) {
      case AppView.main:
        return WorldPhase(
          key: const ValueKey('main'),
          state: worldState,
        );
      case AppView.map:
        return WorldMapView(
          key: const ValueKey('map'),
          state: worldState,
          biomes: worldState.biomes,
          onTravel: () => setState(() => _currentView = AppView.main),
        );
      case AppView.character:
        return CharacterView(
          key: const ValueKey('character'),
          player: player,
        );
    }
  }
}
