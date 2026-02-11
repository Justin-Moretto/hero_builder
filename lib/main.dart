import 'package:flutter/material.dart';

import 'game/world_state.dart';
import 'models/player.dart';
import 'phases/world_phase.dart';
import 'widgets/character_sheet_overlay.dart';
import 'widgets/game_top_bar.dart';

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

/// Initial screen: world map with biome + event nodes + travel. No Flame, loads immediately.
class WorldScreen extends StatefulWidget {
  const WorldScreen({super.key});

  @override
  State<WorldScreen> createState() => _WorldScreenState();
}

class _WorldScreenState extends State<WorldScreen> {
  late final WorldState worldState;
  late final Player player;
  CharacterPanelState _characterPanelState = CharacterPanelState.closed;

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
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GameTopBar(
                player: player,
                onCharacterPressed: () {
                  setState(() {
                    _characterPanelState = _characterPanelState == CharacterPanelState.maximized
                        ? CharacterPanelState.closed
                        : CharacterPanelState.maximized;
                  });
                },
              ),
              Expanded(child: WorldPhase(state: worldState)),
            ],
          ),
          CharacterSheetOverlay(
            panelState: _characterPanelState,
            onPanelStateChanged: (state) => setState(() => _characterPanelState = state),
            player: player,
          ),
        ],
      ),
    );
  }
}
