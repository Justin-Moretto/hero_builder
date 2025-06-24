import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'game/hero_game.dart';

void main() {
  final game = HeroGame();
  runApp(GameWidget(game: game));
}
