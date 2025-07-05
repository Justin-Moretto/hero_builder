import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame/game.dart';
import 'game/hero_game.dart';
import 'phases/shop_phase.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Force landscape orientation
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  
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
      home: const GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late HeroGame game;

  @override
  void initState() {
    super.initState();
    game = HeroGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget(
        game: game,
        overlayBuilderMap: {
          'shop': (context, game) => ShopPhase(
            player: (game as HeroGame).player,
            shopItems: (game as HeroGame).shopItems,
            onBuyItem: (game as HeroGame).buyItem,
            onStartCombat: (game as HeroGame).startCombat,
          ),
        },
      ),
    );
  }
}
